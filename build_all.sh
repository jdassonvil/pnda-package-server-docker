#!/bin/sh

echo "Starting build script"

repo_url=$1

if [ -z $repo_url ]; then
  echo "Syntax: build.sh <package repository url>"
  exit 1
fi

for file in build.d/platform*
do
  filename=$(echo $file | cut -d '/' -f 2 | cut -d '.' -f 1)
  /bin/sh build.sh $filename $repo_url 
done
