### Pre-Requisites
This guide will help you setup a docker network for running the HackTheArch
platform.  First, make sure your private/public key pair are in the `certs`
directory. Then, from the root directory, with your docker-machine running:


1. Build and launch the HTA image:
```
docker-compose up -d
```

2. Build the database:
```
docker-compose run web rake db:migrate
```

3. Seed the database:
```
docker-compose run web rake db:seed
```

HackTheArch should now be browsable on your docker-machine's IP!
