#!/bin/sh

PLATFORM_TESTING="$GITHUB_ENDPOINT/platform-testing.git"
PACKAGE_SERVER="http://192.168.1.205:3535"

echo "Step 1: cloning platform-testing $PLATFORM_TESTING in $PWD"

if [ ! -d "$PWD/platform-testing" ]; then
	echo "	cloning $BRANCH for platform-testing"
	git clone $PLATFORM_TESTING
	if [ ! -d "$PWD/platform-testing" ]; then
		echo "Error clonning platform-testing"
		exit 1
	fi
else
	echo "	getting $BRANCH for platform-testing"
fi
cd platform-testing
git checkout $BRANCH
git pull origin $BRANCH --tags
VERSION=$(git describe --abbrev=0 --tags | sed -e 's#.*/##')
if( [ -z "$VERSION" ] || [ "$VERSION" = "lis" ] ) then
	VERSION="latest"
fi
echo "VERSION=$VERSION" > VERSION
mvn versions:set -DnewVersion=$VERSION
mvn clean package
cd target
if [ ! -f platform-testing-cdh-$VERSION.tar.gz ]; then
	echo "	Error building platform-testing"
	exit 1
else
	echo "	Build done: platform-testing-cdh-$VERSION.tar.gz"
fi

sha512sum platform-testing-cdh-$VERSION.tar.gz > platform-testing-cdh-$VERSION.tar.gz.sha512.txt
sha512sum platform-testing-general-$VERSION.tar.gz > platform-testing-general-$VERSION.tar.gz.sha512.txt

# Publish to package server

for file in platform-testing-cdh platform-testing-general
do
  echo "curl -X POST --data-binary @$file-$VERSION.tar.gz $PACKAGE_SERVER/packages/platform/releases/platform-testing/$file-$VERSION.tar.gz"
  curl -X POST --data-binary @$file-$VERSION.tar.gz $PACKAGE_SERVER/packages/platform/releases/platform-testing/$file-$VERSION.tar.gz
  echo "curl -X POST -o $file-$VERSION.tar.gz.sha512.txt $PACKAGE_SERVER/packages/platform/releases/platform-testing/$file-$VERSION.tar.gz.sha512.txt"
  curl -X POST --data-binary @$file-$VERSION.tar.gz.sha512.txt $PACKAGE_SERVER/packages/platform/releases/platform-testing/$file-$VERSION.tar.gz.sha512.txt
done
