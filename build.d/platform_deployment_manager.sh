#!/bin/sh

source "$(dirname "$0")"/common.sh

init_package_server
init_github_endpoint

PLATFORM_DEPLOYMENT_MANAGER="$GITHUB_ENDPOINT/platform-deployment-manager.git"

echo "Cloning platform-deployment-manager $PLATFORM_DEPLOYMENT_MANAGER in $PWD"
if [ ! -d "$PWD/platform-deployment-manager" ]; then
	echo "	clonning $BRANCH for platform-deployment-manager"
	git clone $PLATFORM_DEPLOYMENT_MANAGER
	if [ ! -d "$PWD/platform-deployment-manager" ]; then
		echo "Error clonning platform-deployment-manager"
		exit 1
	fi
else
	echo "	getting $BRANCH for platform-deployment-manager"
fi
cd platform-deployment-manager
git checkout $BRANCH
git pull origin $BRANCH --tags

VERSION=$(git describe --abbrev=0 --tags | sed -e 's#.*/##')
if( [ -z "$VERSION" ] || [ "$VERSION" = "lis" ] ) then
	VERSION="latest"
fi
echo "VERSION=$VERSION" > VERSION
cd api
mvn versions:set -DnewVersion=$VERSION
mvn clean package
cd target
if [ ! -f deployment-manager-$VERSION.tar.gz ]; then
	echo "	Error building platform-deployment-manager"
	exit 1
else
	echo "	Build done: deployment-manager-$VERSION.tar.gz"
fi
sha512sum deployment-manager-$VERSION.tar.gz > deployment-manager-$VERSION.tar.gz.sha512.txt

# Publish to package server

echo "curl -X POST --data-binary @deployment-manager-$VERSION.tar.gz $PACKAGE_SERVER/packages/platform/releases/deployment-manager/deployment-manager-$VERSION.tar.gz"
curl -X POST --data-binary @deployment-manager-$VERSION.tar.gz $PACKAGE_SERVER/packages/platform/releases/deployment-manager/deployment-manager-$VERSION.tar.gz
echo "curl -X POST --data-binary @deployment-manager-$VERSION.tar.gz.sha512.txt $PACKAGE_SERVER/packages/platform/releases/deployment-manager/deployment-manager-$VERSION.tar.gz.sha512.txt"
curl -X POST --data-binary @deployment-manager-$VERSION.tar.gz.sha512.txt $PACKAGE_SERVER/packages/platform/releases/deployment-manager/deployment-manager-$VERSION.tar.gz.sha512.txt
