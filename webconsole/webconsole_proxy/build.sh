#!/bin/bash

set -e
set -o pipefail

function build_musl() {
    cd /

    # Download
    curl -LO http://www.musl-libc.org/releases/musl-${MUSL_VERSION}.tar.gz
    tar zxvf musl-${MUSL_VERSION}.tar.gz
    cd musl-${MUSL_VERSION}

    # Build
    ./configure
    make -j4
    make install
}

function build_ncurses() {
    cd /

    # Download
    curl -LO https://ftp.gnu.org/pub/gnu/ncurses/ncurses-${NCURSES_VERSION}.tar.gz
    tar zxvf ncurses-${NCURSES_VERSION}.tar.gz
    cd ncurses-${NCURSES_VERSION}

    # Build
    CC='/usr/local/musl/bin/musl-gcc -static' CFLAGS='-fPIC' ./configure \
        --disable-shared \
        --enable-static
}

function build_readline() {
    cd /

    # Download
    curl -LO ftp://ftp.cwru.edu/pub/bash/readline-${READLINE_VERSION}.tar.gz
    tar xzvf readline-${READLINE_VERSION}.tar.gz
    cd readline-${READLINE_VERSION}
    ln -s /readline-${READLINE_VERSION} /readline

    # Build
    CC='/usr/local/musl/bin/musl-gcc -static' \
        CFLAGS='-fPIC' \
        ./configure --disable-shared --enable-static
    make -j4
    make install-static
}

function build_openssl() {
    cd /

    # Download
    curl -LO https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
    tar zxvf openssl-${OPENSSL_VERSION}.tar.gz
    cd openssl-${OPENSSL_VERSION}

    # Configure
    CC='/usr/local/musl/bin/musl-gcc -static' \
        CFLAGS='-fPIC' \
        ./Configure no-shared linux-x86_64

    # Build
    make -j4
    echo "** Finished building OpenSSL"
}

function build_socat() {
    cd /

    # Download
    curl -LO http://www.dest-unreach.org/socat/download/socat-${SOCAT_VERSION}.tar.gz
    tar xzvf socat-${SOCAT_VERSION}.tar.gz
    cd socat-${SOCAT_VERSION}

    # Build
    # NOTE: `NETDB_INTERNAL` is non-POSIX, and thus not defined by MUSL.
    # We define it this way manually.
    CC='/usr/local/musl/bin/musl-gcc -static' \
        CFLAGS="-fPIC -DWITH_OPENSSL -I/ -I/openssl-${OPENSSL_VERSION}/include -I/readline-${READLINE_VERSION} -DNETDB_INTERNAL=-1" \
        CPPFLAGS="-DWITH_OPENSSL -I/ -I/openssl-${OPENSSL_VERSION}/include -I/readline -DNETDB_INTERNAL=-1" \
        LDFLAGS="-L/readline -L/ncurses-${NCURSES_VERSION}/lib -L/openssl-${OPENSSL_VERSION}" \
        ./configure
    make -j4
    strip socat
}

function doit() {
    build_musl
    build_ncurses
    build_readline
    build_openssl
    build_socat

    cp /socat-${SOCAT_VERSION}/socat /
    echo "** Finished **"
}

doit
