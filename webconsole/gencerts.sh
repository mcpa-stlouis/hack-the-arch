#!/bin/sh
for FILENAME in client server; do
  openssl genrsa -out $FILENAME.key 1024
  openssl req -new -key $FILENAME.key -x509 -days 36500 -out $FILENAME.crt -batch -subj '/O=Cydefe/C=US/CN=*'
  cat $FILENAME.key $FILENAME.crt >$FILENAME.pem
  chmod 600 $FILENAME.key $FILENAME.pem
done

cat server.crt | docker secret create SERVER_CRT -
cat server.pem | docker secret create SERVER_PEM -
cat client.crt | docker secret create CLIENT_CRT -
cat client.key | docker secret create CLIENT_KEY -
rm server.* client.*

