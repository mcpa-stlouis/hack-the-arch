
group "default" {
  targets = ["web", "webconsole", "socat_static"]
}

target "web" {
  context = "./"
  dockerfile = "Dockerfile"
  output = ["type=registry"]
  driver = "docker-container"
  tags = ["docker.io/paullj1/hackthearch"]
  platforms = ["linux/amd64", "linux/arm64", "linux/arm/v6", "linux/arm/v7"]
}

target "webconsole" {
  context = "./webconsole/webconsole/"
  dockerfile = "Dockerfile"
  output = ["type=registry"]
  driver = "docker-container"
  tags = ["docker.io/paullj1/webconsole"]
  platforms = ["linux/amd64", "linux/arm64"]
}

target "socat_static" {
  context = "./webconsole/socat_static/"
  dockerfile = "Dockerfile"
  output = ["type=registry"]
  driver = "docker-container"
  tags = ["docker.io/paullj1/socat_static"]
  platforms = ["linux/amd64", "linux/arm64", "linux/arm/v6", "linux/arm/v7"]
}

