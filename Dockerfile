# HackTheArch Dockerfile
# VERSION 3.0

################################################################################
# Builder
################################################################################
FROM ruby:3-alpine as builder
RUN apk add --no-cache --update \
        build-base \
        curl-dev \
        sqlite-dev \
        nodejs \
        libpq \
        postgresql \
        imagemagick \
        libxml2-dev \
        postgresql-dev \
        postgresql-client

WORKDIR /src
COPY Gemfile* ./
RUN bundle install --with production -j4 --retry 3 \
  && rm -rf /usr/local/bundle/cache/*.gem \
  && find /usr/local/bundle/gems/ -name "*.c" -delete \
  && find /usr/local/bundle/gems/ -name "*.o" -delete

ADD . ./
RUN mkdir -p ./tmp/cache ./log

################################################################################
# Production
################################################################################
FROM ruby:3-alpine as prod
MAINTAINER Paul Jordan <paullj1@gmail.com>

RUN apk add --no-cache --update \
        imagemagick \
        nodejs \
        postgresql-client \
        tzdata \
  && addgroup -g 1000 -S app \
  && adduser -u 1000 -S app -G app

WORKDIR /app
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder --chown=app:app /src ./

HEALTHCHECK --interval=30s --timeout=3s \
  CMD echo -e 'require "net/http"\nexit(Net::HTTP.get_response(URI("http://127.0.0.1:3000/")).code.to_i < 400)' | ruby

USER app
CMD [ "bundle", "exec", "puma", "-C", "/app/config/puma.rb" ]
EXPOSE 3000
