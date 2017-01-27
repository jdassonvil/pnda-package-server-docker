#!/bin/sh

source "$(dirname "$0")"/common.sh

init_package_server
init_github_endpoint

PLATFORM_PACKAGE_REPOSITORY="$GITHUB_ENDPOINT/platform-package-repository.git"

echo "Cloning platform-package-repository $PLATFORM_PACKAGE_REPOSITORY in $PWD"
if [ ! -d "$PWD/platform-package-repository" ]; then
	git clone $PLATFORM_PACKAGE_REPOSITORY
	if [ ! -d "$PWD/platform-package-repository" ]; then
		echo "Error clonning platform-package-repository"
		exit 1
	fi
else
	echo "	getting $BRANCH for platform-package-repository"
fi
cd platform-package-repository
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
if [ ! -f package-repository-$VERSION.tar.gz ]; then
	echo "	Error building platform-package-repository"
	exit 1
else
	echo "	Build done: package-repository-$VERSION.tar.gz"
fi
sha512sum package-repository-$VERSION.tar.gz > package-repository-$VERSION.tar.gz.sha512.txt

# Publish to package server
echo "curl -X POST  --data-binary @package-repository-$VERSION.tar.gz $PACKAGE_SERVER/packages/platform/releases/package-repository/package-repository-$VERSION.tar.gz \n"
curl -X POST  --data-binary @package-repository-$VERSION.tar.gz $PACKAGE_SERVER/packages/platform/releases/package-repository/package-repository-$VERSION.tar.gz
echo "curl -X POST --data-binary @package-repository-$VERSION.tar.gz.sha512.txt $PACKAGE_SERVER/packages/platform/releases/package-repository/package-repository-$VERSION.tar.gz.sha512.txt \n"
curl -X POST --data-binary @package-repository-$VERSION.tar.gz.sha512.txt $PACKAGE_SERVER/packages/platform/releases/package-repository/package-repository-$VERSION.tar.gz.sha512.txt
