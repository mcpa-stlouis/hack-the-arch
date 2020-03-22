package main

import (
  "crypto/sha1"
  "encoding/base64"
  "encoding/hex"
  "flag"
  "fmt"
  "io"
  "log"
  "net/http"
  "os"
  "strings"
  "time"

	"golang.org/x/net/context"
  "github.com/docker/docker/api/types"
  "github.com/docker/docker/api/types/filters"
  "github.com/docker/docker/api/types/swarm"
  "github.com/docker/docker/client"
  "github.com/docker/docker/pkg/stdcopy"
  "github.com/gorilla/handlers"
  "github.com/gorilla/mux"
  "golang.org/x/net/websocket"
)

var port =   flag.String("p", "8888", "Port for server")
var daemon = flag.String("d", "unix:///docker.sock", "Docker daemon host")

var cacert = flag.String("cacert", "/run/secrets/SERVER_CRT", "CA Cert or Client certificate")
var cert =   flag.String("cert", "/run/secrets/CLIENT_CRT", "Server's certificate")
var key =    flag.String("key", "/run/secrets/CLIENT_KEY", "Server's private key")

var dev =    flag.Bool("dev", false, "Development mode for Docker Desktop")

func main() {
  flag.Parse()

  r := mux.NewRouter()
  r.Handle("/status", StatusHandler).Methods("GET")
  r.Handle("/vnc", handlers.LoggingHandler(os.Stdout, VncHandler)).Methods("GET")
  r.Handle("/xterm", handlers.LoggingHandler(os.Stdout, XtermHandler)).Methods("GET")
  r.PathPrefix("/exec/").Handler(handlers.LoggingHandler(os.Stdout, websocket.Handler(ExecContainer)))
  r.PathPrefix("/").Handler(http.FileServer(http.Dir("./static/"))).Methods("GET")

  http.ListenAndServe(":"+*port, r)

}

var StatusHandler = http.HandlerFunc(func(w http.ResponseWriter, r *http.Request){
  w.Write([]byte("Ok"))
})

var VncHandler = http.HandlerFunc(func(w http.ResponseWriter, r *http.Request){
  http.ServeFile(w, r, "vnc.html")
})

var XtermHandler = http.HandlerFunc(func(w http.ResponseWriter, r *http.Request){
  http.ServeFile(w, r, "index.html")
})

func ExecContainer(websock *websocket.Conn) {
  // Params will be: url/base64: "hash,session_id,user_id,assessment_id"
  url_params := websock.Request().URL.Query()

  // VNC or Exec:
  decoded_params, err := base64.StdEncoding.DecodeString(strings.Join(url_params["exec"], " "))
  if err != nil {
    log.Print("Error base64 decoding parameters: ", err)
    log.Print("Params: ", url_params)
    return
  }

  // Base64 decode params
  param_array := strings.Split(string(decoded_params), ",")
  hash := param_array[0]
  problem_id := param_array[1]
  user_id := param_array[2]

  // Build Docker CLI context for localhost
	ctx := context.Background()
  cli, err := client.NewClientWithOpts(client.WithHost(*daemon), client.WithVersion("1.37"))
	if err != nil {
		panic(err)
	}
  defer cli.Close()

  // Get services
	svc_filter := filters.NewArgs(
    filters.Arg("label", "problem_id="+problem_id),
    filters.Arg("label", "user_id="+user_id),
    filters.Arg("name", "hta-entrypoint-"+user_id))

  services, err := cli.ServiceList(ctx, types.ServiceListOptions {
    Filters: svc_filter,
  })

	if err != nil || len(services) == 0 {
    log.Print("Error getting services, or none are running...", err)
    return
  }

  // Validate request
  hash_check := sha1.New()
	io.WriteString(hash_check, user_id)
  io.WriteString(hash_check, services[0].ID)
  hash_validate := hex.EncodeToString(hash_check.Sum(nil))

  if strings.Compare(hash, hash_validate) != 0 {
    log.Print("Unauthorized request")
    return
  }

  shell := true
  exec_cfg := types.ExecConfig {
    AttachStdin: true,
    AttachStdout: true,
    AttachStderr: true,
    Tty: true,
    Cmd: strings.Fields("/bin/sh"),
  }

  if len(url_params["vnc"]) > 0 {
    log.Print("VNC Session Starting")
    entry := "/usr/bin/socat tcp-connect:"
    entry += strings.Join(url_params["vhost"],"") + ":"
    entry += strings.Join(url_params["vport"],"") + " -"
    log.Printf("Executing: '%s'", entry)

    exec_cfg.Cmd = strings.Fields(entry)
    exec_cfg.Tty = false
    exec_cfg.AttachStderr = false
    shell = false

  } else if val, ok := services[0].Spec.Labels["entry"]; ok {
    log.Printf("Using entry point other than /bin/sh: %s", val)
    exec_cfg.Cmd = strings.Fields(val)
  }

  log.Print("Authorized request!  Connecting to container...")

  // This was a valid request, wait up to five minutes to be ready...
  var tasks []swarm.Task

  if shell {
    websock.Write([]byte("Initializing assessment.."))
  }

  for i := 0; i < 60; i++ {

    // Identify task to get container host
    task_filters := filters.NewArgs(
      filters.Arg("desired-state", "running"),
      filters.Arg("service", "hta-entrypoint-"+user_id))

    tasks, err = cli.TaskList(ctx, types.TaskListOptions {
      Filters: task_filters,
    })

    if err != nil || len(tasks) > 1 {
      panic("This shouldn't happen... more than one running task with name 'hta-entrypoint-"+user_id+"' is running.")
      return
    } else if len(tasks) != 1 || tasks[0].Status.State != "running" {
      if shell {
        websock.Write([]byte("."))
      }
      time.Sleep(5 * time.Second)
    } else {
      break
    }
  }

  if shell {
    websock.Write([]byte("\r\n"))
  }

  // Get Node running this task
  node, _, err := cli.NodeInspectWithRaw(ctx, tasks[0].NodeID)
  if err != nil {
    log.Print("Couldn't get Node Information: ", err)
    return
  }

  // Make a new CLI context for this node
  var r_cli *client.Client
  if *dev {
    r_cli = cli
  } else {
    host := "tcp://"+node.Description.Hostname+":2376"
    r_cli, err = client.NewClientWithOpts(client.WithHost(host),
      client.WithVersion("1.37"),
      client.WithTLSClientConfig(*cacert, *cert, *key))

    if err != nil {
      panic(err)
    }
    defer r_cli.Close()
  }

  // Exec cmd against container on remote host
  response,err := r_cli.ContainerExecCreate(ctx,
    tasks[0].Status.ContainerStatus.ContainerID,
    exec_cfg)
  if err != nil {
    log.Print(err)
    return
  }

  if err = AttachExec(ctx, r_cli, response.ID, websock, shell); err != nil {
    log.Print(err)
  }

  fmt.Println("Connection!")
  fmt.Println(websock)
}

/* Function makes web request
*/
func AttachExec(ctx context.Context, cli *client.Client,
                id string, websock *websocket.Conn, shell bool) error {

  hijack, err := cli.ContainerExecAttach(ctx, id, types.ExecStartCheck{
    Detach: false,
    Tty: shell,
  })
  if err != nil {
    return err
  }
  defer hijack.Close()

  var receiveStdout chan error

  if websock != nil {
    go func() (err error) {
      if websock != nil {
        if shell {
          _, err = io.Copy(websock, hijack.Reader)
        } else {
          websock.PayloadType = websocket.BinaryFrame
          _, err = stdcopy.StdCopy(websock, nil, hijack.Reader)
        }
      }
      return err
    }()
  }

  go func() error {
    if websock != nil {
      io.Copy(hijack.Conn, websock)
    }

    if conn, ok := hijack.Conn.(interface {
      CloseWrite() error
    }); ok {
      if err := conn.CloseWrite(); err != nil {
      }
    }
    return nil
  }()

  if websock != nil {
    if err := <-receiveStdout; err != nil {
      return err
    }
  }
  go func() {
    for {
      fmt.Println(hijack.Reader)
    }
  }()

  return nil
}
