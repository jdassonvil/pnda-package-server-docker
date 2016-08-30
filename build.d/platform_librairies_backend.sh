#!/bin/sh

PLATFORM_LIBRARIES="$GITHUB_ENDPOINT/platform-libraries.git" 
echo "Step 7: cloning platform-libraries $PLATFORM_LIBRARIES in $PWD" >> $LOG_FILE
if [ ! -d "$PWD/platform-libraries" ]; then
	git clone $PLATFORM_LIBRARIES
	if [ ! -d "$PWD/platform-libraries" ]; then
		echo "Error clonning platform-libraries" >> $LOG_FILE
		exit 1
	fi
else
	echo "	getting $BRANCH for platform-libraries" >> $LOG_FILE
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
  echo "	SPARK_HOME is already set as $SPARK_HOME" >> $LOG_FILE
fi
python setup.py bdist_egg
cd dist
if [ ! -f platformlibs-$VERSION-py2.7.egg ]; then
	echo "	Error building platform-libraries" >> $LOG_FILE
	exit 1
else
	echo "	Build done: platformlibs-$VERSION-py2.7.egg" >> $LOG_FILE
fi
sha512sum platformlibs-$VERSION-py2.7.egg > platformlibs-$VERSION-py2.7.egg.sha512.txt
mkdir -p "$RELEASE_PATH/packages/platform/releases/platform-libraries"
mv platformlibs-$VERSION-py2.7.egg $RELEASE_PATH/packages/platform/releases/platform-libraries/platformlibs-$VERSION-py2.7.egg
mv platformlibs-$VERSION-py2.7.egg.sha512.txt $RELEASE_PATH/packages/platform/releases/platform-libraries/platformlibs-$VERSION-py2.7.egg.sha512.txt
cd ../..
