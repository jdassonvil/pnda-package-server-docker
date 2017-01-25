packages_server:
  base_uri: http://localhost:3535

docker:
  install_docker_py: False

docker-pkg:
  lookup:
    config:
      - DOCKER_OPTS="--insecure-registry localhost:5000"
