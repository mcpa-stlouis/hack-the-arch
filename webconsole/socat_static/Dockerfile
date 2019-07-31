# Webconsole Dockerfile v1.0
# Build stage
FROM debian:buster as builder
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get upgrade -yy \
  && apt-get install -yy \
    automake \
    build-essential \
    curl \
    git  \
    pkg-config \
    libwrap0-dev \
    linux-libc-dev \
  && apt-get clean

ADD build.sh /
ENV MUSL_VERSION      1.1.22
ENV SOCAT_VERSION     1.7.3.2
ENV NCURSES_VERSION   6.1
ENV READLINE_VERSION  7.0
ENV OPENSSL_VERSION   1.0.2k
RUN /build.sh

# Package stage
FROM scratch as package
COPY --from=builder /socat-*/socat /

ENTRYPOINT ["/socat"]

