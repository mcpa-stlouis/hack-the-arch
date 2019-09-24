#!/bin/bash

set -e
set -o pipefail

function build_musl() {
    cd /musl-${MUSL_VERSION}
    ./configure 2>&1 > /var/log/build.log
    make -j4 2>&1 > /var/log/build.log
    make install 2>&1 > /var/log/build.log
}

function build_ncurses() {
    cd /ncurses-${NCURSES_VERSION}
    CC='/usr/local/musl/bin/musl-gcc -static' CFLAGS='-fPIC' ./configure \
        --disable-shared \
        --enable-static 2>&1 > /var/log/build.log
}

function build_readline() {

    cd /readline-${READLINE_VERSION}
    ln -s /readline-${READLINE_VERSION} /readline

    # Build
    CC='/usr/local/musl/bin/musl-gcc -static' \
        CFLAGS='-fPIC' \
        ./configure --disable-shared --enable-static 2>&1 > /var/log/build.log
    make -j4 2>&1 > /var/log/build.log
    make install-static 2>&1 > /var/log/build.log
}

function build_openssl() {

    # Configure
    cd /openssl-${OPENSSL_VERSION}
    UNAME=`uname -m`
    case "$UNAME" in
      *aarch64*) BUILD_ARCH="linux-aarch64" ;;
      *armv6l*) BUILD_ARCH="linux-armv4" ;;
      *armv7l*) BUILD_ARCH="linux-armv4" ;;
      *x86_64*) BUILD_ARCH="linux-x86_64" ;;
      *) echo '[!] Unable to build OpenSSL!' ; exit -1 ;;
    esac

    CC='/usr/local/musl/bin/musl-gcc -static' \
        CFLAGS='-fPIC' \
        ./Configure no-shared $BUILD_ARCH 2>&1 > /var/log/build.log

    # Build
    make -j4 2>&1 > /var/log/build.log
    echo "[!] ** Finished building OpenSSL"
}

function build_socat() {

    # NOTE: `NETDB_INTERNAL` is non-POSIX, and thus not defined by MUSL.
    # We define it this way manually.
    cd /socat-${SOCAT_VERSION}
    CC='/usr/local/musl/bin/musl-gcc -static' \
        CFLAGS="-fPIC -DWITH_OPENSSL -I/ -I/openssl-${OPENSSL_VERSION}/include -I/readline-${READLINE_VERSION} -DNETDB_INTERNAL=-1" \
        CPPFLAGS="-DWITH_OPENSSL -I/ -I/openssl-${OPENSSL_VERSION}/include -I/readline -DNETDB_INTERNAL=-1" \
        LDFLAGS="-L/readline -L/ncurses-${NCURSES_VERSION}/lib -L/openssl-${OPENSSL_VERSION}" \
        ./configure 2>&1 > /var/log/build.log
    make -j4 2>&1 > /var/log/build.log
    strip socat
}

function doit() {

    echo "[+] Downloading assets.."
    cd /
    curl -ksSL http://www.musl-libc.org/releases/musl-${MUSL_VERSION}.tar.gz | tar zxf -
    curl -ksSL https://ftp.gnu.org/pub/gnu/ncurses/ncurses-${NCURSES_VERSION}.tar.gz | tar zxf - 
    curl -ksSL ftp://ftp.cwru.edu/pub/bash/readline-${READLINE_VERSION}.tar.gz | tar zxf -
    curl -ksSL https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz | tar zxf -
    curl -ksSL http://www.dest-unreach.org/socat/download/socat-${SOCAT_VERSION}.tar.gz | tar zxf -

    echo "[+] Building musl libc"
    build_musl
    echo "[+] Building ncurses"
    build_ncurses
    echo "[+] Building readlin"
    build_readline
    echo "[+] Building openssl"
    build_openssl
    echo "[+] Building socat"
    build_socat

    cp /socat-${SOCAT_VERSION}/socat /
    echo "[!] ** Finished **"
}

doit
