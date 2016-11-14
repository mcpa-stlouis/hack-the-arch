# SSL Certificates
In order to run HackTheArch in a Docker container or locally, you'll need to
place your certificate files in this directory (or create links to them).

To generate a self-signed certificate (courtesy of [tadast](https://gist.github.com/tadast/9932075):
```
openssl genrsa -des3 -out server.orig.key 2048
openssl rsa -in server.orig.key -out server.key
openssl req -new -key server.key -out server.csr
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
echo "127.0.0.1 localhost.ssl" | sudo tee -a /private/etc/hosts
```

