#!/bin/sh

PLATFORM_GOBBLIN="$GITHUB_ENDPOINT/gobblin.git" 
echo "Step 8: cloning gobblin $PLATFORM_GOBBLIN in $PWD" >> $LOG_FILE
if [ ! -d "$PWD/gobblin" ]; then
	git clone $PLATFORM_GOBBLIN
	if [ ! -d "$PWD/gobblin" ]; then
		echo "Error clonning gobblin" >> $LOG_FILE
		exit 1
	fi
else
	echo "	getting $BRANCH for gobblin" >> $LOG_FILE
fi
cd gobblin
git checkout PNDA
git pull origin PNDA
VERSION=$(git describe --abbrev=0 --tags | sed -e 's#.*/##')
if( [ -z "$VERSION" ] || [ "$VERSION" = "lis" ] ) then
	VERSION="latest"
fi
echo "VERSION=$VERSION" > VERSION

JAVA_HOME="$PWD/../jdk1.8.0_74"
HADOOP_VERSION=2.6.0-cdh5.4.9
if [ ! -d $JAVA_HOME ]; then
  cd ..
  echo "downloading jdk 8 from Oracle in $PWD" >> $LOG_FILE
  curl -b oraclelicense=accept-securebackup-cookie -L http://download.oracle.com/otn-pub/java/jdk/8u74-b02/jdk-8u74-linux-x64.tar.gz | tar xz --no-same-owner
  cd gobblin
else
  echo "	JAVA_HOME is already set as $JAVA_HOME" >> $LOG_FILE
fi
export PATH=$JAVA_HOME/bin:$PATH
./gradlew build -Pversion=${VERSION} -PuseHadoop2 -PhadoopVersion=${HADOOP_VERSION}
PNDA_RELEASE_NAME=gobblin-distribution-${VERSION}.tar.gz
if [ ! -f $PNDA_RELEASE_NAME ]; then
	echo "	Error building gobblin" >> $LOG_FILE
	exit 1
else
	echo "	Build done: $PNDA_RELEASE_NAME" >> $LOG_FILE
fi
sha512sum ${PNDA_RELEASE_NAME} > ${PNDA_RELEASE_NAME}.sha512.txt

# Publish to package server

echo "curl -X POST --data-binary @${PNDA_RELEASE_NAME}.tar.gz $PACKAGE_SERVER/packages/platform/releases/gobblin/${PNDA_RELEASE_NAME}.tar.gz"
curl -X POST --data-binary @${PNDA_RELEASE_NAME}.tar.gz $PACKAGE_SERVER/packages/platform/releases/gobblin/${PNDA_RELEASE_NAME}.tar.gz
echo "curl -X POST --data-binary @${PNDA_RELEASE_NAME}.tar.gz.sha512.txt $PACKAGE_SERVER/packages/platform/releases/gobblin/${PNDA_RELEASE_NAME}.tar.gz.sha512.txt"
curl -X POST --data-binary @${PNDA_RELEASE_NAME}.tar.gz.sha512.txt $PACKAGE_SERVER/packages/platform/releases/gobblin/${PNDA_RELEASE_NAME}.tar.gz.sha512.txt
