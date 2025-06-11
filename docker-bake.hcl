group "default" {
  targets = ["default"]
}

variable "VERSION" {
  default = "latest"
}

target "_base" {
  context = "."
  dockerfile = "Dockerfile"
}

target "default" {
  inherits = ["_base"]
  target = "production"
  args = {
    NODE_MAJOR = "22"
    DB_ADAPTER = "postgres"
    DB_USERNAME = "postgres"
    DB_PASSWORD = "changeme"
  }
  output = [{ type = "registry" }]
  tags = [
    "vxnexus-registry.intra.inist.fr:8083/opidor/dmpopidor:${VERSION}",
  ]
}
