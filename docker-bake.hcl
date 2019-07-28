
group "default" {
  targets = ["web", "webconsole", "webconsole_proxy"]
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

target "webconsole_proxy" {
  context = "./webconsole/webconsole_proxy/"
  dockerfile = "Dockerfile"
  output = ["type=registry"]
  driver = "docker-container"
  tags = ["docker.io/paullj1/webconsole_proxy"]
  platforms = ["linux/amd64", "linux/arm64", "linux/arm/v6", "linux/arm/v7"]
}

