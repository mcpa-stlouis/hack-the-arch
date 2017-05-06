### Docker-Compose

This guide will help you setup a docker network for running the HackTheArch
platform.  First, make sure your private/public key pair are in the `certs`
directory (instructions for creating a self-signed cert are there as well).

Then, set the desired variables in `.env` (most importantly `SECRET_KEY_BASE`,
you can run: `bundle exec rails secret` to get a sufficient key).

Finally, from the root directory, with your docker-machine running:


1. Build and launch the HTA image:

```
docker-compose up -d
```

2. Build the database:

```
docker-compose run web rails db:migrate
```

3. Seed the database:

```
docker-compose run web rails db:seed
```

4. Pre-Compile assets:

```
docker-compose run web rails assets:precompile
```

HackTheArch should now be browsable on your docker-machine's IP!
