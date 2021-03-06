#!/bin/sh

source "$(dirname "$0")"/common.sh

init_package_server
init_github_endpoint

PLATFORM_CONSOLE_BACKEND="$GITHUB_ENDPOINT/platform-console-backend.git" 

echo "Cloning platform-console-backend $PLATFORM_CONSOLE_BACKEND in $PWD"
if [ ! -d "$PWD/platform-console-backend" ]; then
	git clone $PLATFORM_CONSOLE_BACKEND
	if [ ! -d "$PWD/platform-console-backend" ]; then
		echo "Error clonning platform-console-backend"
		exit 1
	fi
else
	echo "	getting $BRANCH for platform-console-backend"
fi
cd platform-console-backend
git checkout $BRANCH
git pull origin $BRANCH --tags
VERSION=$(git describe --abbrev=0 --tags | sed -e 's#.*/##')
if( [ -z "$VERSION" ] || [ "$VERSION" = "lis" ] ) then
	VERSION="latest"
fi
echo "VERSION=$VERSION" > VERSION
cp -R console-backend-utils console-backend-data-logger/
echo "Version  $VERSION" >> console-backend-data-logger/MANIFEST
cd console-backend-data-logger
npm install
echo "{ \"name\": \"console-backend-data-logger\", \"version\": \"$VERSION\" }" > package-version.json
grunt --verbose package
if [ ! -f console-backend-data-logger-$VERSION.tar.gz ]; then
	echo "	Error building platform-console-backend-data-logger"
	exit 1
else
	echo "	Build done: console-backend-data-logger-$VERSION.tar.gz"
fi
sha512sum console-backend-data-logger-$VERSION.tar.gz > console-backend-data-logger-$VERSION.tar.gz.sha512.txt

# Publish to package server
echo "curl -X POST  --data-binary @console-backend-data-logger-$VERSION.tar.gz $PACKAGE_SERVER/packages/platform/releases/console/console-backend-data-logger-$VERSION.tar.gz \n"
curl -X POST --data-binary @console-backend-data-logger-$VERSION.tar.gz $PACKAGE_SERVER/packages/platform/releases/console/console-backend-data-logger-$VERSION.tar.gz
echo "curl -X POST --data-binary @console-backend-data-logger-$VERSION.tar.gz.sha512.txt $PACKAGE_SERVER/packages/platform/console/console-backend-data-logger-$VERSION.tar.gz.sha512.txt \n"
curl -X POST --data-binary @console-backend-data-logger-$VERSION.tar.gz.sha512.txt $PACKAGE_SERVER/packages/platform/releases/console/console-backend-data-logger-$VERSION.tar.gz.sha512.txt

cd ..


cp -R console-backend-utils console-backend-data-manager/
mkdir -p console-backend-data-manager/conf
echo "Version  $VERSION" >> console-backend-data-manager/MANIFEST
cd console-backend-data-manager
npm install
echo "{ \"name\": \"console-backend-data-manager\", \"version\": \"$VERSION\" }" > package-version.json
grunt package --verbose
if [ ! -f console-backend-data-manager-$VERSION.tar.gz ]; then
	echo "	Error building platform-console-backend-data-manager"
	exit 1
else
	echo "	Build done: console-backend-data-manager-$VERSION.tar.gz"
fi

sha512sum console-backend-data-manager-$VERSION.tar.gz > console-backend-data-manager-$VERSION.tar.gz.sha512.txt

# Publish to package server

echo "curl -X POST --data-binary @console-backend-data-manager-$VERSION.tar.gz $PACKAGE_SERVER/packages/platform/releases/console/console-backend-data-manager-$VERSION.tar.gz"
curl -X POST --data-binary @console-backend-data-manager-$VERSION.tar.gz $PACKAGE_SERVER/packages/platform/releases/console/console-backend-data-manager-$VERSION.tar.gz
echo "curl -X POST --data-binary @console-backend-data-manager-$VERSION.tar.gz.sha512.txt $PACKAGE_SERVER/packages/platform/releases/console/console-backend-data-manager-$VERSION.tar.gz.sha512.txt"
curl -X POST --data-binary @console-backend-data-manager-$VERSION.tar.gz.sha512.txt $PACKAGE_SERVER/packages/platform/releases/console/console-backend-data-manager-$VERSION.tar.gz.sha512.txt
