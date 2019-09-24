# Webconsole Dockerfile v1.0
# Build stage
FROM debian:buster as builder
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get upgrade -yy \
  && apt-get install -yy \
    automake \
    build-essential \
    ca-certificates \
    curl \
    git  \
    libwrap0-dev \
    linux-libc-dev \
    pkg-config \
  && apt-get clean

ADD build.sh /
ENV MUSL_VERSION      1.1.23
ENV SOCAT_VERSION     1.7.3.3
ENV NCURSES_VERSION   6.1
ENV READLINE_VERSION  7.0
ENV OPENSSL_VERSION   1.0.2t
RUN /build.sh

# Package stage
FROM scratch as package
COPY --from=builder /socat-*/socat /

ENTRYPOINT ["/socat"]

