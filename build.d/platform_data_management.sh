#!/bin/sh

PLATFORM_DATA_MANAGEMENT="$GITHUB_ENDPOINT/platform-data-mgmnt.git" 
echo "Step 2: cloning platform-data-mgmnt $PLATFORM_DATA_MANAGEMENT in $PWD" >> $LOG_FILE
git clone $PLATFORM_DATA_MANAGEMENT
if [ ! -d "$PWD/platform-data-mgmnt" ]; then
	echo "	cloning $BRANCH for platform-data-mgmnt" >> $LOG_FILE
	git clone $PLATFORM_DATA_MANAGEMENT
	if [ ! -d "$PWD/platform-data-mgmnt" ]; then
		echo "Error clonning platform-data-mgmnt" >> $LOG_FILE
		exit 1
	fi
else
	echo "	getting $BRANCH for platform-data-mgmnt" >> $LOG_FILE
fi
cd platform-data-mgmnt
git checkout $BRANCH
git pull origin $BRANCH --tags
VERSION=$(git describe --abbrev=0 --tags | sed -e 's#.*/##')
if( [ -z "$VERSION" ] || [ "$VERSION" = "lis" ] ) then
	VERSION="latest"
fi
echo "VERSION=$VERSION" > VERSION
cd data-service
mvn versions:set -DnewVersion=$VERSION
mvn clean package
cd target
if [ ! -f data-service-$VERSION.tar.gz ]; then
	echo "	Error building data-service" >> $LOG_FILE
	exit 1
else
	echo "	Build done: data-service-$VERSION.tar.gz" >> $LOG_FILE
fi
sha512sum data-service-$VERSION.tar.gz > data-service-$VERSION.tar.gz.sha512.txt
mkdir -p "$RELEASE_PATH/packages/platform/releases/data-service"
mv data-service-$VERSION.tar.gz $RELEASE_PATH/packages/platform/releases/data-service/data-service-$VERSION.tar.gz
mv data-service-$VERSION.tar.gz.sha512.txt $RELEASE_PATH/packages/platform/releases/data-service/data-service-$VERSION.tar.gz.sha512.txt
cd ../..

cd hdfs-cleaner
mvn versions:set -DnewVersion=$VERSION
mvn clean package
cd target
if [ ! -f hdfs-cleaner-$VERSION.tar.gz ]; then
	echo "	Error building hdfs-cleaner" >> $LOG_FILE
	exit 1
else
	echo "	Build done: hdfs-cleaner-$VERSION.tar.gz" >> $LOG_FILE
fi
sha512sum hdfs-cleaner-$VERSION.tar.gz > hdfs-cleaner-$VERSION.tar.gz.sha512.txt
mkdir -p "$RELEASE_PATH/packages/platform/releases/hdfs-cleaner"
mv hdfs-cleaner-$VERSION.tar.gz $RELEASE_PATH/packages/platform/releases/hdfs-cleaner/hdfs-cleaner-$VERSION.tar.gz
mv hdfs-cleaner-$VERSION.tar.gz.sha512.txt $RELEASE_PATH/packages/platform/releases/hdfs-cleaner/hdfs-cleaner-$VERSION.tar.gz.sha512.txt
cd ../../..
