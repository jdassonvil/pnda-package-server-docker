#!/bin/sh

PLATFORM_CONSOLE_BACKEND="$GITHUB_ENDPOINT/platform-console-backend.git" 
echo "Step 6: cloning platform-console-backend $PLATFORM_CONSOLE_BACKEND in $PWD" >> $LOG_FILE
if [ ! -d "$PWD/platform-console-backend" ]; then
	git clone $PLATFORM_CONSOLE_BACKEND
	if [ ! -d "$PWD/platform-console-backend" ]; then
		echo "Error clonning platform-console-backend" >> $LOG_FILE
		exit 1
	fi
else
	echo "	getting $BRANCH for platform-console-backend" >> $LOG_FILE
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
	echo "	Error building platform-console-backend-data-logger" >> $LOG_FILE
	exit 1
else
	echo "	Build done: console-backend-data-logger-$VERSION.tar.gz" >> $LOG_FILE
fi
sha512sum console-backend-data-logger-$VERSION.tar.gz > console-backend-data-logger-$VERSION.tar.gz.sha512.txt
mkdir -p "$RELEASE_PATH/packages/platform/releases/console"
mv console-backend-data-logger-$VERSION.tar.gz $RELEASE_PATH/packages/platform/releases/console/console-backend-data-logger-$VERSION.tar.gz
mv console-backend-data-logger-$VERSION.tar.gz.sha512.txt $RELEASE_PATH/packages/platform/releases/console/console-backend-data-logger-$VERSION.tar.gz.sha512.txt
cd ..
cp -R console-backend-utils console-backend-data-manager/
mkdir -p console-backend-data-manager/conf
echo "Version  $VERSION" >> console-backend-data-manager/MANIFEST
cd console-backend-data-manager
npm install
echo "{ \"name\": \"console-backend-data-manager\", \"version\": \"$VERSION\" }" > package-version.json
grunt package --verbose
if [ ! -f console-backend-data-manager-$VERSION.tar.gz ]; then
	echo "	Error building platform-console-backend-data-manager" >> $LOG_FILE
	exit 1
else
	echo "	Build done: console-backend-data-manager-$VERSION.tar.gz" >> $LOG_FILE
fi
sha512sum console-backend-data-manager-$VERSION.tar.gz > console-backend-data-manager-$VERSION.tar.gz.sha512.txt
mv console-backend-data-manager-$VERSION.tar.gz $RELEASE_PATH/packages/platform/releases/console/console-backend-data-manager-$VERSION.tar.gz
mv console-backend-data-manager-$VERSION.tar.gz.sha512.txt $RELEASE_PATH/packages/platform/releases/console/console-backend-data-manager-$VERSION.tar.gz.sha512.txt
cd ../..

