#!/bin/sh

init_package_server() {
  if [ -z $PACKAGE_SERVER_IP ]; then
    echo "Missing target package server"
    echo "Define PACKAGE_SERVER_IP environment variable"
    exit 1
  fi

  export PACKAGE_SERVER="http://$PACKAGE_SERVER_IP:3535"
}

init_github_endpoint() {
  if [ -z $GITHUB_ENDPOINT ]; then
    echo "Missing Git Hub endpoint server"
    echo "Define GITHUB_ENDPOINT environment variable"
    exit 1
  fi
}
