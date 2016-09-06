#!/bin/sh

PLATFORM_CONSOLE_FRONTEND="$GITHUB_ENDPOINT/platform-console-frontend.git" >> $LOG_FILE
PACKAGE_SERVER="http://192.168.1.205:3535"

echo "Cloning platform-console-frontend $PLATFORM_CONSOLE_FRONTEND in $PWD" >> $LOG_FILE

if [ ! -d "$PWD/platform-console-frontend" ]; then
	git clone $PLATFORM_CONSOLE_FRONTEND
	if [ ! -d "$PWD/platform-console-frontend" ]; then
		echo "Error clonning platform-console-frontend" >> $LOG_FILE
		exit 1
	fi
else
	echo "	getting $BRANCH for platform-console-frontend" >> $LOG_FILE
fi

cd platform-console-frontend
git checkout $BRANCH
git pull origin $BRANCH --tags
VERSION=$(git describe --abbrev=0 --tags | sed -e 's#.*/##')
if( [ -z "$VERSION" ] || [ "$VERSION" = "lis" ] ) then
	VERSION="latest"
fi
echo "VERSION=$VERSION" > VERSION
echo "Version  $VERSION" >> MANIFEST
echo "Git hash $GIT_COMMIT" > MANIFEST
cd console-frontend
npm install

echo "{ \"name\": \"console-frontend\", \"version\": \"$VERSION\" }" > package-version.json
grunt package
if [ ! -f console-frontend-$VERSION.tar.gz ]; then
	echo "	Error building platform-console-frontend" >> $LOG_FILE
	exit 1
else
	echo "	Build done: console-frontend-$VERSION.tar.gz" >> $LOG_FILE
fi

sha512sum console-frontend-$VERSION.tar.gz > console-frontend-$VERSION.tar.gz.sha512.txt

mv console-frontend-$VERSION.tar.gz $RELEASE_PATH/packages/platform/releases/console/console-frontend-$VERSION.tar.gz
mv console-frontend-$VERSION.tar.gz.sha512.txt $RELEASE_PATH/packages/platform/releases/console/console-frontend-$VERSION.tar.gz.sha512.txt

echo "curl -X POST --data-binary @console-frontend-$VERSION.tar.gz $PACKAGE_SERVER/packages/platform/releases/console/console-frontend-$VERSION.tar.gz"
curl -X POST --data-binary @console-frontend-$VERSION.tar.gz $PACKAGE_SERVER/packages/platform/releases/console/console-frontend-$VERSION.tar.gz
echo "curl -X POST --data-binary @console-frontend-$VERSION.tar.gz.sha512.txt $PACKAGE_SERVER/packages/platform/releases/console/console-frontend-$VERSION.tar.gz.sha512.txt"
curl -X POST --data-binary @console-frontend-$VERSION.tar.gz.sha512.txt $PACKAGE_SERVER/packages/platform/releases/console/console-frontend-$VERSION.tar.gz.sha512.txt
