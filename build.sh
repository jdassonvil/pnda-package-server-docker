#!/bin/sh

package=$1
repo_url=$2

if [ -z $package ] || [ -z $repo_url ]; then
  echo "Syntax: build.sh <package name> <package repository url> [env] [github endpoint]"
  exit 1
fi

if [ -z $3 ]; then
  env="build"
else
  env="build-$3"
fi

if [ -z $4 ]; then
  github="https://github.com/pndaproject"
else
  github=$4
fi

image_name="pnda/$env"
image=$(docker images --format "table {{.Repository}}:{{.Tag}}" | grep $image_name)

if [ -z "$image" ]; then 
  echo "Build environment missing"
  build_cmd="docker build -t $image_name -f $env.dockerfile ."
  echo $build_cmd

  test=$($build_cmd 2>&1)
  if [ $? -ne 0 ]; then
    echo "Failed to build environment container"
  fi
fi

docker run -e PACKAGE_SERVER_IP=$repo_url -e GITHUB_ENDPOINT=$github \
  --rm -v $PWD/build.d:/opt $image_name /opt/$package.sh $repo_url
