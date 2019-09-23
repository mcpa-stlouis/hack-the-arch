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
  "strings"
  "time"

	"golang.org/x/net/context"
  "github.com/docker/docker/api/types"
  "github.com/docker/docker/api/types/filters"
  "github.com/docker/docker/api/types/swarm"
  "github.com/docker/docker/client"
  "github.com/docker/docker/pkg/stdcopy"
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

  http.Handle("/exec/", websocket.Handler(ExecContainer))
  http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {

    log.Printf("[%s] -- %s %s\n", r.RemoteAddr, r.Method, r.URL)

    // xtermJS Assets:
    if r.URL.String() == "/xterm/xterm.css" {
      http.ServeFile(w, r, "/web/xtermjs/xterm.css")
    } else if r.URL.String() == "/xterm/xterm.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/xtermjs/xterm.js")

    // noVNC Assets:
    } else if r.URL.Path == "/vnc.html" {
      http.ServeFile(w, r, "/web/vnc.html")
    } else if r.URL.Path == "/core/display.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc//web/novnc//web/novnc/core/display.js")
    } else if r.URL.Path == "/core/inflator.js" {
      http.ServeFile(w, r, "/web/novnc/core/inflator.js")
      w.Header().Set("Content-Type", "application/javascript")
    } else if r.URL.Path == "/core/util/eventtarget.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/core/util/eventtarget.js")
    } else if r.URL.Path == "/core/util/events.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/core/util/events.js")
    } else if r.URL.Path == "/core/util/logging.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/core/util/logging.js")
    } else if r.URL.Path == "/core/util/polyfill.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/core/util/polyfill.js")
    } else if r.URL.Path == "/core/util/cursor.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/core/util/cursor.js")
    } else if r.URL.Path == "/core/util/strings.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/core/util/strings.js")
    } else if r.URL.Path == "/core/util/browser.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/core/util/browser.js")
    } else if r.URL.Path == "/core/input/util.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/core/input/util.js")
    } else if r.URL.Path == "/core/input/domkeytable.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/core/input/domkeytable.js")
    } else if r.URL.Path == "/core/input/vkeys.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/core/input/vkeys.js")
    } else if r.URL.Path == "/core/input/keysymdef.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/core/input/keysymdef.js")
    } else if r.URL.Path == "/core/input/xtscancodes.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/core/input/xtscancodes.js")
    } else if r.URL.Path == "/core/input/keysym.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/core/input/keysym.js")
    } else if r.URL.Path == "/core/input/keyboard.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/core/input/keyboard.js")
    } else if r.URL.Path == "/core/input/mouse.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/core/input/mouse.js")
    } else if r.URL.Path == "/core/input/fixedkeys.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/core/input/fixedkeys.js")
    } else if r.URL.Path == "/core/encodings.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/core/encodings.js")
    } else if r.URL.Path == "/core/base64.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/core/base64.js")
    } else if r.URL.Path == "/core/websock.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/core/websock.js")
    } else if r.URL.Path == "/core/des.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/core/des.js")
    } else if r.URL.Path == "/core/decoders/hextile.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/core/decoders/hextile.js")
    } else if r.URL.Path == "/core/decoders/rre.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/core/decoders/rre.js")
    } else if r.URL.Path == "/core/decoders/tightpng.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/core/decoders/tightpng.js")
    } else if r.URL.Path == "/core/decoders/raw.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/core/decoders/raw.js")
    } else if r.URL.Path == "/core/decoders/tight.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/core/decoders/tight.js")
    } else if r.URL.Path == "/core/decoders/copyrect.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/core/decoders/copyrect.js")
    } else if r.URL.Path == "/core/rfb.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/core/rfb.js")
    } else if r.URL.Path == "/app/ui.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/app/ui.js")
    } else if r.URL.Path == "/app/locale" {
      http.ServeFile(w, r, "/web/novnc/app/locale")
    } else if r.URL.Path == "/app/locale/tr.json" {
      http.ServeFile(w, r, "/web/novnc/app/locale/tr.json")
    } else if r.URL.Path == "/app/locale/nl.json" {
      http.ServeFile(w, r, "/web/novnc/app/locale/nl.json")
    } else if r.URL.Path == "/app/locale/zh_CN.json" {
      http.ServeFile(w, r, "/web/novnc/app/locale/zh_CN.json")
    } else if r.URL.Path == "/app/locale/ja.json" {
      http.ServeFile(w, r, "/web/novnc/app/locale/ja.json")
    } else if r.URL.Path == "/app/locale/de.json" {
      http.ServeFile(w, r, "/web/novnc/app/locale/de.json")
    } else if r.URL.Path == "/app/locale/ru.json" {
      http.ServeFile(w, r, "/web/novnc/app/locale/ru.json")
    } else if r.URL.Path == "/app/locale/pl.json" {
      http.ServeFile(w, r, "/web/novnc/app/locale/pl.json")
    } else if r.URL.Path == "/app/locale/el.json" {
      http.ServeFile(w, r, "/web/novnc/app/locale/el.json")
    } else if r.URL.Path == "/app/locale/ko.json" {
      http.ServeFile(w, r, "/web/novnc/app/locale/ko.json")
    } else if r.URL.Path == "/app/locale/cs.json" {
      http.ServeFile(w, r, "/web/novnc/app/locale/cs.json")
    } else if r.URL.Path == "/app/locale/zh_TW.json" {
      http.ServeFile(w, r, "/web/novnc/app/locale/zh_TW.json")
    } else if r.URL.Path == "/app/locale/sv.json" {
      http.ServeFile(w, r, "/web/novnc/app/locale/sv.json")
    } else if r.URL.Path == "/app/locale/es.json" {
      http.ServeFile(w, r, "/web/novnc/app/locale/es.json")
    } else if r.URL.Path == "/app/webutil.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/app/webutil.js")
    } else if r.URL.Path == "/app/images/connect.svg" {
      http.ServeFile(w, r, "/web/novnc/app/images/connect.svg")
    } else if r.URL.Path == "/app/images/fullscreen.svg" {
      http.ServeFile(w, r, "/web/novnc/app/images/fullscreen.svg")
    } else if r.URL.Path == "/app/images/tab.svg" {
      http.ServeFile(w, r, "/web/novnc/app/images/tab.svg")
    } else if r.URL.Path == "/app/images/mouse_none.svg" {
      http.ServeFile(w, r, "/web/novnc/app/images/mouse_none.svg")
    } else if r.URL.Path == "/app/images/disconnect.svg" {
      http.ServeFile(w, r, "/web/novnc/app/images/disconnect.svg")
    } else if r.URL.Path == "/app/images/mouse_middle.svg" {
      http.ServeFile(w, r, "/web/novnc/app/images/mouse_middle.svg")
    } else if r.URL.Path == "/app/images/power.svg" {
      http.ServeFile(w, r, "/web/novnc/app/images/power.svg")
    } else if r.URL.Path == "/app/images/drag.svg" {
      http.ServeFile(w, r, "/web/novnc/app/images/drag.svg")
    } else if r.URL.Path == "/app/images/handle.svg" {
      http.ServeFile(w, r, "/web/novnc/app/images/handle.svg")
    } else if r.URL.Path == "/app/images/keyboard.svg" {
      http.ServeFile(w, r, "/web/novnc/app/images/keyboard.svg")
    } else if r.URL.Path == "/app/images/clipboard.svg" {
      http.ServeFile(w, r, "/web/novnc/app/images/clipboard.svg")
    } else if r.URL.Path == "/app/images/settings.svg" {
      http.ServeFile(w, r, "/web/novnc/app/images/settings.svg")
    } else if r.URL.Path == "/app/images/ctrl.svg" {
      http.ServeFile(w, r, "/web/novnc/app/images/ctrl.svg")
    } else if r.URL.Path == "/app/images/mouse_left.svg" {
      http.ServeFile(w, r, "/web/novnc/app/images/mouse_left.svg")
    } else if r.URL.Path == "/app/images/warning.svg" {
      http.ServeFile(w, r, "/web/novnc/app/images/warning.svg")
    } else if r.URL.Path == "/app/images/info.svg" {
      http.ServeFile(w, r, "/web/novnc/app/images/info.svg")
    } else if r.URL.Path == "/app/images/expander.svg" {
      http.ServeFile(w, r, "/web/novnc/app/images/expander.svg")
    } else if r.URL.Path == "/app/images/esc.svg" {
      http.ServeFile(w, r, "/web/novnc/app/images/esc.svg")
    } else if r.URL.Path == "/app/images/icons/novnc-76x76.png" {
      http.ServeFile(w, r, "/web/novnc/app/images/icons/novnc-76x76.png")
    } else if r.URL.Path == "/app/images/icons/novnc-32x32.png" {
      http.ServeFile(w, r, "/web/novnc/app/images/icons/novnc-32x32.png")
    } else if r.URL.Path == "/app/images/icons/novnc-64x64.png" {
      http.ServeFile(w, r, "/web/novnc/app/images/icons/novnc-64x64.png")
    } else if r.URL.Path == "/app/images/icons/novnc-144x144.png" {
      http.ServeFile(w, r, "/web/novnc/app/images/icons/novnc-144x144.png")
    } else if r.URL.Path == "/app/images/icons/novnc-icon-sm.svg" {
      http.ServeFile(w, r, "/web/novnc/app/images/icons/novnc-icon-sm.svg")
    } else if r.URL.Path == "/app/images/icons/novnc-72x72.png" {
      http.ServeFile(w, r, "/web/novnc/app/images/icons/novnc-72x72.png")
    } else if r.URL.Path == "/app/images/icons/novnc-96x96.png" {
      http.ServeFile(w, r, "/web/novnc/app/images/icons/novnc-96x96.png")
    } else if r.URL.Path == "/app/images/icons/novnc-24x24.png" {
      http.ServeFile(w, r, "/web/novnc/app/images/icons/novnc-24x24.png")
    } else if r.URL.Path == "/app/images/icons/novnc-60x60.png" {
      http.ServeFile(w, r, "/web/novnc/app/images/icons/novnc-60x60.png")
    } else if r.URL.Path == "/app/images/icons/novnc-48x48.png" {
      http.ServeFile(w, r, "/web/novnc/app/images/icons/novnc-48x48.png")
    } else if r.URL.Path == "/app/images/icons/novnc-120x120.png" {
      http.ServeFile(w, r, "/web/novnc/app/images/icons/novnc-120x120.png")
    } else if r.URL.Path == "/app/images/icons/novnc-192x192.png" {
      http.ServeFile(w, r, "/web/novnc/app/images/icons/novnc-192x192.png")
    } else if r.URL.Path == "/app/images/icons/novnc-icon.svg" {
      http.ServeFile(w, r, "/web/novnc/app/images/icons/novnc-icon.svg")
    } else if r.URL.Path == "/app/images/icons/novnc-152x152.png" {
      http.ServeFile(w, r, "/web/novnc/app/images/icons/novnc-152x152.png")
    } else if r.URL.Path == "/app/images/icons/novnc-16x16.png" {
      http.ServeFile(w, r, "/web/novnc/app/images/icons/novnc-16x16.png")
    } else if r.URL.Path == "/app/images/ctrlaltdel.svg" {
      http.ServeFile(w, r, "/web/novnc/app/images/ctrlaltdel.svg")
    } else if r.URL.Path == "/app/images/windows.svg" {
      http.ServeFile(w, r, "/web/novnc/app/images/windows.svg")
    } else if r.URL.Path == "/app/images/toggleextrakeys.svg" {
      http.ServeFile(w, r, "/web/novnc/app/images/toggleextrakeys.svg")
    } else if r.URL.Path == "/app/images/handle_bg.svg" {
      http.ServeFile(w, r, "/web/novnc/app/images/handle_bg.svg")
    } else if r.URL.Path == "/app/images/alt.svg" {
      http.ServeFile(w, r, "/web/novnc/app/images/alt.svg")
    } else if r.URL.Path == "/app/images/error.svg" {
      http.ServeFile(w, r, "/web/novnc/app/images/error.svg")
    } else if r.URL.Path == "/app/images/mouse_right.svg" {
      http.ServeFile(w, r, "/web/novnc/app/images/mouse_right.svg")
    } else if r.URL.Path == "/app/sounds/bell.oga" {
      http.ServeFile(w, r, "/web/novnc/app/sounds/bell.oga")
    } else if r.URL.Path == "/app/sounds/bell.mp3" {
      http.ServeFile(w, r, "/web/novnc/app/sounds/bell.mp3")
    } else if r.URL.Path == "/app/styles/Orbitron700.ttf" {
      http.ServeFile(w, r, "/web/novnc/app/styles/Orbitron700.ttf")
    } else if r.URL.Path == "/app/styles/base.css" {
      http.ServeFile(w, r, "/web/novnc/app/styles/base.css")
    } else if r.URL.Path == "/app/styles/Orbitron700.woff" {
      http.ServeFile(w, r, "/web/novnc/app/styles/Orbitron700.woff")
    } else if r.URL.Path == "/app/error-handler.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/app/error-handler.js")
    } else if r.URL.Path == "/app/localization.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/app/localization.js")
    } else if r.URL.Path == "/vendor/pako/lib" {
      http.ServeFile(w, r, "/web/novnc/vendor/pako/lib")
    } else if r.URL.Path == "/vendor/pako/lib/utils" {
      http.ServeFile(w, r, "/web/novnc/vendor/pako/lib/utils")
    } else if r.URL.Path == "/vendor/pako/lib/utils/common.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/vendor/pako/lib/utils/common.js")
    } else if r.URL.Path == "/vendor/pako/lib/zlib" {
      http.ServeFile(w, r, "/web/novnc/vendor/pako/lib/zlib")
    } else if r.URL.Path == "/vendor/pako/lib/zlib/constants.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/vendor/pako/lib/zlib/constants.js")
    } else if r.URL.Path == "/vendor/pako/lib/zlib/inflate.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/vendor/pako/lib/zlib/inflate.js")
    } else if r.URL.Path == "/vendor/pako/lib/zlib/deflate.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/vendor/pako/lib/zlib/deflate.js")
    } else if r.URL.Path == "/vendor/pako/lib/zlib/crc32.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/vendor/pako/lib/zlib/crc32.js")
    } else if r.URL.Path == "/vendor/pako/lib/zlib/zstream.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/vendor/pako/lib/zlib/zstream.js")
    } else if r.URL.Path == "/vendor/pako/lib/zlib/inffast.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/vendor/pako/lib/zlib/inffast.js")
    } else if r.URL.Path == "/vendor/pako/lib/zlib/adler32.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/vendor/pako/lib/zlib/adler32.js")
    } else if r.URL.Path == "/vendor/pako/lib/zlib/inftrees.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/vendor/pako/lib/zlib/inftrees.js")
    } else if r.URL.Path == "/vendor/pako/lib/zlib/trees.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/vendor/pako/lib/zlib/trees.js")
    } else if r.URL.Path == "/vendor/pako/lib/zlib/gzheader.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/vendor/pako/lib/zlib/gzheader.js")
    } else if r.URL.Path == "/vendor/pako/lib/zlib/messages.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/vendor/pako/lib/zlib/messages.js")
    } else if r.URL.Path == "/vendor/promise.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/vendor/promise.js")
    } else if r.URL.Path == "/vendor/browser-es-module-loader" {
      http.ServeFile(w, r, "/web/novnc/vendor/browser-es-module-loader")
    } else if r.URL.Path == "/vendor/browser-es-module-loader/dist" {
      http.ServeFile(w, r, "/web/novnc/vendor/browser-es-module-loader/dist")
    } else if r.URL.Path == "/vendor/browser-es-module-loader/dist/babel-worker.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/vendor/browser-es-module-loader/dist/babel-worker.js")
    } else if r.URL.Path == "/vendor/browser-es-module-loader/dist/browser-es-module-loader.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/vendor/browser-es-module-loader/dist/browser-es-module-loader.js")
    } else if r.URL.Path == "/vendor/browser-es-module-loader/dist/browser-es-module-loader.js.map" {
      http.ServeFile(w, r, "/web/novnc/vendor/browser-es-module-loader/dist/browser-es-module-loader.js.map")
    } else if r.URL.Path == "/vendor/browser-es-module-loader/README.md" {
      http.ServeFile(w, r, "/web/novnc/vendor/browser-es-module-loader/README.md")
    } else if r.URL.Path == "/vendor/browser-es-module-loader/rollup.config.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/vendor/browser-es-module-loader/rollup.config.js")
    } else if r.URL.Path == "/vendor/browser-es-module-loader/src" {
      http.ServeFile(w, r, "/web/novnc/vendor/browser-es-module-loader/src")
    } else if r.URL.Path == "/vendor/browser-es-module-loader/src/babel-worker.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/vendor/browser-es-module-loader/src/babel-worker.js")
    } else if r.URL.Path == "/vendor/browser-es-module-loader/src/browser-es-module-loader.js" {
      w.Header().Set("Content-Type", "application/javascript")
      http.ServeFile(w, r, "/web/novnc/vendor/browser-es-module-loader/src/browser-es-module-loader.js")
    } else {
      http.ServeFile(w, r, "/web/index.html")
    }

  })

  if err := http.ListenAndServe(":"+*port, nil); err != nil {
    panic(err)
  }
}

func ExecContainer(websock *websocket.Conn) {

  // Params will be: url/base64: "hash,session_id,user_id"
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
  session_id := param_array[1]
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
