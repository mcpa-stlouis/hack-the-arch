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
  "net/url"
  "strings"
  "time"

  "github.com/davecgh/go-spew/spew"
  "github.com/docker/docker/api/types"
  "github.com/docker/docker/api/types/filters"
  "github.com/docker/docker/api/types/swarm"
  "github.com/docker/docker/client"
	"golang.org/x/net/context"
  "golang.org/x/net/websocket"
)

var port = flag.String("port", "8888", "Port for server")
var daemon = flag.String("daemon", "unix:///docker.sock", "Docker daemon host")
var dev = flag.Bool("dev", false, "Development mode for Docker Desktop")

func main() {
  flag.Parse()

  http.Handle("/exec/", websocket.Handler(ExecContainer))
  http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {

    log.Printf("[%s] -- %s %s\n", r.RemoteAddr, r.Method, r.URL)

    if r.URL.String() == "/xterm/xterm.css" {
      http.ServeFile(w, r, "xterm.css")
    } else if r.URL.String() == "/xterm/xterm.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "xterm.js")
    } else {
      http.ServeFile(w, r, "index.html")
    }

  })

  if err := http.ListenAndServe(":"+*port, nil); err != nil {
    panic(err)
  }
}

func ExecContainer(websock *websocket.Conn) {
  // Params will be: url/base64: "hash,problem_id,user_id"
  url_params := websock.Request().URL.Path[len("/exec/"):]

  // Un-URL the params
  encoded_params, err := url.QueryUnescape(url_params)
  if err != nil {
    log.Print("Error URL decoding parameters: ", err)
    log.Print("Params: ", url_params)
    return
  }

  // Base64 decode params
	decoded_params, err := base64.StdEncoding.DecodeString(encoded_params)
	if err != nil {
    log.Print("Error base64 decoding parameters: ", err)
    log.Print("Params: ", encoded_params)
		return
	}

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
  log.Print("Authorized request!  Connecting to container...")

  // This was a valid request, wait up to five minutes to be ready...
  var tasks []swarm.Task
  websock.Write([]byte("Initializing assessment.."))
  for i := 0; i < 60; i++ {

    // Identify task to get container host
    task_filters := filters.NewArgs(
      filters.Arg("desired-state", "running"),
      filters.Arg("service", "hta-entrypoint-"+user_id))

    tasks, err = cli.TaskList(ctx, types.TaskListOptions {
      Filters: task_filters,
    })

    if err != nil || len(tasks) > 1 {
      log.Fatal(err)
      panic("This shouldn't happen... more than one running task with name 'hta-entrypoint-"+user_id+"' is running.")
      return
    } else if len(tasks) != 1 || tasks[0].Status.State != "running" {
      websock.Write([]byte("."))
      time.Sleep(5 * time.Second)
    } else {
      break
    }
  }
  websock.Write([]byte("\r\n"))

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
      client.WithTLSClientConfig("/run/secrets/SERVER_CRT", "/run/secrets/CLIENT_CRT", "/run/secrets/CLIENT_KEY"))

    if err != nil {
      panic(err)
    }
  }

  // Exec cmd against container on remote host
  response,err := r_cli.ContainerExecCreate(ctx,
    tasks[0].Status.ContainerStatus.ContainerID,
    types.ExecConfig {
      AttachStdin: true,
      AttachStdout: true,
      AttachStderr: true,
      Tty: true,
      Cmd: []string{"/bin/sh"},
    })
  if err != nil {
    log.Print(err)
    return
  }

  err = AttachExec(ctx, r_cli, response.ID, websock)
  if err != nil {
    log.Print(err)
  }

  fmt.Println("Connection!")
  fmt.Println(websock)
  spew.Dump(websock)
}

/* Function makes web request
*/
func AttachExec(ctx context.Context, cli *client.Client,
                id string, websocket *websocket.Conn) error {

  hijack, err := cli.ContainerExecAttach(ctx, id, types.ExecStartCheck{
    Detach: false,
    Tty: true,
  })
  if err != nil {
    return err
  }
  defer hijack.Close()

  var receiveStdout chan error

  if websocket != nil {
    go func() (err error) {
      if websocket != nil {
        _, err = io.Copy(websocket, hijack.Reader)
      }
      return err
    }()
  }

  go func() error {
    if websocket != nil {
      io.Copy(hijack.Conn, websocket)
    }

    if conn, ok := hijack.Conn.(interface {
      CloseWrite() error
    }); ok {
      if err := conn.CloseWrite(); err != nil {
      }
    }
    return nil
  }()

  if websocket != nil {
    if err := <-receiveStdout; err != nil {
      return err
    }
  }
  spew.Dump(hijack.Reader)
  go func() {
    for {
      fmt.Println(hijack.Reader)
      spew.Dump(hijack.Reader)
    }
  }()

  return nil
}
