# Webconsole Dockerfile v1.0
# Build stage
FROM golang:1.12-alpine as builder
MAINTAINER Paul Jordan <paullj1@gmail.com>

RUN apk update && apk add --no-cache upx git

COPY webconsole.go .
RUN go get -d -v \
      github.com/docker/docker/api \
      github.com/docker/docker/pkg/stdcopy \
      golang.org/x/net/websocket

RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" webconsole.go \
  && upx --brute webconsole

# Package stage
FROM scratch as package
COPY --from=builder /go/webconsole ./
ADD assets.tar.gz /

ENTRYPOINT ["./webconsole"]
CMD ["--port", "8888", "--daemon", "unix:///docker.sock"]
