# HackTheArch Dockerfile
# VERSION 1.0

FROM ruby:2.3
MAINTAINER Paul Jordan <paullj1@gmail.com>

HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f https://localhost:3000/ || exit 1

ARG secret

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        nodejs \
        postgresql-client \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /hta
WORKDIR /hta
ADD Gemfile /hta/Gemfile
RUN bundle install
ADD . /hta
RUN chown -R $USER:$USER .

EXPOSE 3000
