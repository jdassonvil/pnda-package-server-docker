#!/bin/sh

source "$(dirname "$0")"/common.sh

init_package_server
init_github_endpoint

PLATFORM_LIBRARIES="$GITHUB_ENDPOINT/platform-libraries.git" 

echo "Cloning platform-libraries $PLATFORM_LIBRARIES in $PWD"
if [ ! -d "$PWD/platform-libraries" ]; then
	git clone $PLATFORM_LIBRARIES
	if [ ! -d "$PWD/platform-libraries" ]; then
		echo "Error clonning platform-libraries"
		exit 1
	fi
else
	echo "	getting $BRANCH for platform-libraries"
fi
cd platform-libraries
git checkout $BRANCH
git pull origin $BRANCH --tags
VERSION=$(git describe --abbrev=0 --tags | sed -e 's#.*/##')
if( [ -z "$VERSION" ] || [ "$VERSION" = "lis" ] ) then
	VERSION="latest"
fi
export VERSION=$VERSION
echo "VERSION=$VERSION" > VERSION
SPARK_HOME="$PWD/../spark-1.5.0-bin-hadoop2.6"
SPARK_VERSION='1.5.0'
HADOOP_VERSION='2.6'

if [ ! -d $SPARK_HOME ]; then
  cd ..
  echo "	downloading spark 1.5.0 in $PWD" >> $LOG_FILE
  curl http://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz --output ./spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz
  tar -xvzf spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz
  cd platform-libraries
else
  echo "	SPARK_HOME is already set as $SPARK_HOME"
fi
python setup.py bdist_egg
cd dist
if [ ! -f platformlibs-$VERSION-py2.7.egg ]; then
	echo "	Error building platform-libraries"
	exit 1
else
	echo "	Build done: platformlibs-$VERSION-py2.7.egg"
fi
sha512sum platformlibs-$VERSION-py2.7.egg > platformlibs-$VERSION-py2.7.egg.sha512.txt

# Publish to package server

echo "curl -X POST --data-binary @platformlibs-$VERSION-py2.7.egg $PACKAGE_SERVER/packages/platform/releases/platform-libraries/platformlibs-$VERSION-py2.7.egg"
curl -X POST --data-binary @platformlibs-$VERSION-py2.7.egg $PACKAGE_SERVER/packages/platform/releases/platform-libraries/platformlibs-$VERSION-py2.7.egg

echo "curl -X POST --data-binary @platformlibs-$VERSION-py2.7.egg.sha512.txt $PACKAGE_SERVER/packages/platform/releases/platform-libraries/platformlibs-$VERSION-py2.7.egg.sha512.txt"
curl -X POST --data-binary @platformlibs-$VERSION-py2.7.egg.sha512.txt $PACKAGE_SERVER/packages/platform/releases/platform-libraries/platformlibs-$VERSION-py2.7.egg.sha512.txt
