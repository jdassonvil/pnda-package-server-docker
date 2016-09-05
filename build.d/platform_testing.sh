#!/bin/sh

PLATFORM_TESTING="$GITHUB_ENDPOINT/platform-testing.git"
PACKAGE_SERVER="http://pnda-build:3535"

echo "Step 1: cloning platform-testing $PLATFORM_TESTING in $PWD" >> $LOG_FILE

if [ ! -d "$PWD/platform-testing" ]; then
	echo "	cloning $BRANCH for platform-testing" >> $LOG_FILE
	git clone $PLATFORM_TESTING
	if [ ! -d "$PWD/platform-testing" ]; then
		echo "Error clonning platform-testing" >> $LOG_FILE
		exit 1
	fi
else
	echo "	getting $BRANCH for platform-testing" >> $LOG_FILE
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
	echo "	Error building platform-testing" >> $LOG_FILE
	exit 1
else
	echo "	Build done: platform-testing-cdh-$VERSION.tar.gz" >> $LOG_FILE
fi
sha512sum platform-testing-cdh-$VERSION.tar.gz > platform-testing-cdh-$VERSION.tar.gz.sha512.txt
sha512sum platform-testing-general-$VERSION.tar.gz > platform-testing-general-$VERSION.tar.gz.sha512.txt
mkdir -p "$RELEASE_PATH/packages/platform/releases/platform-testing"


curl -X POST -o platform-testing-cdh-$VERSION.tar.gz $PACKAGE_SERVER/packages/platform/releases/platform-testing/platform-testing-cdh-$VERSION.tar.gz
curl -X POST -o platform-testing-general-$VERSION.tar.gz $PACKAGE_SERVER/packages/platform/releases/platform-testing/platform-testing-general-$VERSION.tar.gz
curl -X POST -o platform-testing-cdh-$VERSION.tar.gz.sha512.txt $PACKAGE_SERVER/packages/platform/releases/platform-testing/platform-testing-cdh-$VERSION.tar.gz.sha512.txt
curl -X POST -o platform-testing-general-$VERSION.tar.gz.sha512.txt $RELEASE_PATH/packages/platform/releases/platform-testing/platform-testing-general-$VERSION.tar.gz.sha512.txt
