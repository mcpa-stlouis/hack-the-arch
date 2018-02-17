# HackTheArch Dockerfile
# VERSION 2.1

FROM ruby:2.5-alpine
MAINTAINER Paul Jordan <paullj1@gmail.com>

HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -kf https://localhost/ || exit 1

RUN apk --no-cache add --update \
        build-base \
        nodejs \
        curl \
        sqlite-dev \
        postgresql-dev \
        postgresql-client

WORKDIR /opt/hta
VOLUME /opt/hta
ADD Gemfile Gemfile.lock ./
RUN bundle install
ADD . ./

EXPOSE 3000
