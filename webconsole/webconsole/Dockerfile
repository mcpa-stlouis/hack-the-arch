# Webconsole Dockerfile v1.0
# Build stage
FROM golang:1.11.4 as builder
MAINTAINER Paul Jordan <paullj1@gmail.com>

COPY webconsole.go .
RUN go get -d -v \
      github.com/davecgh/go-spew/spew \
      github.com/docker/docker/api \
      golang.org/x/net/websocket 
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o webconsole .

# Package stage
FROM scratch as package
COPY --from=builder /go/webconsole ./
ADD xterm.css xterm.js index.html ./

EXPOSE 8888
ENTRYPOINT ["./webconsole"]
CMD ["--port", "8888", "--daemon", "unix:///docker.sock"]
