# HackTheArch Dockerfile
# VERSION 2.2

FROM ruby:2.6-alpine
MAINTAINER Paul Jordan <paullj1@gmail.com>

HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://localhost:3000/ || exit 1

RUN apk --no-cache add --update \
        build-base \
        nodejs \
        curl \
        sqlite-dev \
        postgresql-dev \
        postgresql-client

WORKDIR /hta
ADD Gemfile Gemfile.lock ./
RUN bundle install
ADD . ./
RUN chown -R root:root ./* \
  && chmod -R a+r ./* \
  && mkdir tmp logs \
  && touch logs/production.log \
  && chmod 777 . tmp logs Gemfile.lock logs/production.log

USER nobody
EXPOSE 3000
ENTRYPOINT ["bundle", "exec"]
CMD ["puma", "-C", "/hta/config/puma.rb", "-b", "tcp://0.0.0.0:3000"]
