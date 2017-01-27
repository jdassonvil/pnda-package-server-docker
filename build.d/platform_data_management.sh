#!/bin/sh

source "$(dirname "$0")"/common.sh

init_package_server
init_github_endpoint

PLATFORM_DATA_MANAGEMENT="$GITHUB_ENDPOINT/platform-data-mgmnt.git" 

echo "Cloning platform-data-mgmnt $PLATFORM_DATA_MANAGEMENT in $PWD"
git clone $PLATFORM_DATA_MANAGEMENT
if [ ! -d "$PWD/platform-data-mgmnt" ]; then
	echo "	cloning $BRANCH for platform-data-mgmnt"
	git clone $PLATFORM_DATA_MANAGEMENT
	if [ ! -d "$PWD/platform-data-mgmnt" ]; then
		echo "Error clonning platform-data-mgmnt"
		exit 1
	fi
else
	echo "	getting $BRANCH for platform-data-mgmnt"
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
	echo "	Error building data-service"
	exit 1
else
	echo "	Build done: data-service-$VERSION.tar.gz"
fi

sha512sum data-service-$VERSION.tar.gz > data-service-$VERSION.tar.gz.sha512.txt

echo "curl -X POST --data-binary @data-service-$VERSION.tar.gz $PACKAGE_SERVER/packages/platform/releases/data-service/data-service-$VERSION.tar.gz"
curl -X POST --data-binary @data-service-$VERSION.tar.gz $PACKAGE_SERVER/packages/platform/releases/data-service/data-service-$VERSION.tar.gz
echo "curl -X POST --data-binary @data-service-$VERSION.tar.gz.sha512.txt $PACKAGE_SERVER/packages/platform/releases/data-service/data-service-$VERSION.tar.gz.sha512.txt"
curl -X POST --data-binary @data-service-$VERSION.tar.gz.sha512.txt $PACKAGE_SERVER/packages/platform/releases/data-service/data-service-$VERSION.tar.gz.sha512.txt

cd ../..

cd hdfs-cleaner
mvn versions:set -DnewVersion=$VERSION
mvn clean package
cd target
if [ ! -f hdfs-cleaner-$VERSION.tar.gz ]; then
	echo "	Error building hdfs-cleaner" >> $LOG_FILE
	exit 1
else
	echo "	Build done: hdfs-cleaner-$VERSION.tar.gz"
fi

sha512sum hdfs-cleaner-$VERSION.tar.gz > hdfs-cleaner-$VERSION.tar.gz.sha512.txt

echo "curl -X POST --data-binary @hdfs-cleaner-$VERSION.tar.gz $PACKAGE_SERVER/packages/platform/releases/hdfs-cleaner/hdfs-cleaner-$VERSION.tar.gz"
curl -X POST --data-binary @hdfs-cleaner-$VERSION.tar.gz $PACKAGE_SERVER/packages/platform/releases/hdfs-cleaner/hdfs-cleaner-$VERSION.tar.gz
echo "curl -X POST --data-binary @hdfs-cleaner-$VERSION.tar.gz.sha512.txt $PACKAGE_SERVER/packages/platform/releases/hdfs-cleaner/hdfs-cleaner-$VERSION.tar.gz.sha512.txt"
curl -X POST --data-binary @hdfs-cleaner-$VERSION.tar.gz.sha512.txt $PACKAGE_SERVER/packages/platform/releases/hdfs-cleaner/hdfs-cleaner-$VERSION.tar.gz.sha512.txt
