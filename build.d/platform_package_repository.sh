#!/bin/sh

PLATFORM_PACKAGE_REPOSITORY="$GITHUB_ENDPOINT/platform-package-repository.git"
echo "Step 4: cloning platform-package-repository $PLATFORM_PACKAGE_REPOSITORY in $PWD" >> $LOG_FILE
if [ ! -d "$PWD/platform-package-repository" ]; then
	git clone $PLATFORM_PACKAGE_REPOSITORY
	if [ ! -d "$PWD/platform-package-repository" ]; then
		echo "Error clonning platform-package-repository" >> $LOG_FILE
		exit 1
	fi
else
	echo "	getting $BRANCH for platform-package-repository" >> $LOG_FILE
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
	echo "	Error building platform-package-repository" >> $LOG_FILE
	exit 1
else
	echo "	Build done: package-repository-$VERSION.tar.gz" >> $LOG_FILE
fi
sha512sum package-repository-$VERSION.tar.gz > package-repository-$VERSION.tar.gz.sha512.txt
mkdir -p "$RELEASE_PATH/packages/platform/releases/package-repository"
mv package-repository-$VERSION.tar.gz $RELEASE_PATH/packages/platform/releases/package-repository/package-repository-$VERSION.tar.gz
mv package-repository-$VERSION.tar.gz.sha512.txt $RELEASE_PATH/packages/platform/releases/package-repository/package-repository-$VERSION.tar.gz.sha512.txt
cd ../../..
