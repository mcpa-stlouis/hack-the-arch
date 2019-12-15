### Docker-Compose

This guide will help you setup a docker swarm environment for running the
HackTheArch platform.  Note that this compose file does not include a reverse
proxy, and to simplify things, does not provide TLS/SSL.  We *highly* suggest
you deploy HackTheArch with TLS!  Using a reverse proxy can do this for you.
Something like [nginx](http://nginx.org), or [Caddy](https://caddyserver.com)
will work just fine.

Moving on, to make sure the environment is setup for your deployment, copy
`.env_sample` to `.env` and set desired variables in it (most importantly
`SECRET_KEY_BASE`, you can run: `bundle exec rails secret` to get a sufficient
key, but a long random string is just fine).

Finally, from the root directory: 

1. Deploy the stack

```
docker stack deploy -c prod-stack.yml hackthearch
```

2. Build the database (find the node that's hosting the hta service), then
   against the container on that node:
```
docker exec -it web /bin/sh
rails db:migrate
rails db:seed
rails assets:precompile
```

HackTheArch should now be browsable on port 3000 on any node in your swarm!
