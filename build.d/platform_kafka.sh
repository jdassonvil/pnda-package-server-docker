#!/bin/sh

source "$(dirname "$0")"/common.sh

init_package_server
init_github_endpoint

echo "Building Kafka manager"

VERSION=1.3.1.6
KAFKA_MANAGER="$PWD/kafka-manager-${VERSION}"

if [ ! -d $KAFKA_MANAGER ]; then
  echo "downloading kafka manager $VERSION in $PWD"
  wget https://github.com/yahoo/kafka-manager/archive/${VERSION}.tar.gz
  tar xzf ${VERSION}.tar.gz
else
  echo "	KAFKA_MANAGER is already set as $KAFKA_MANAGER"
fi
if [ ! -f .sbt/0.13/local.sbt ]; then
	mkdir -p .sbt/0.13
	echo 'scalacOptions ++= Seq("-Xmax-classfile-name","100")' >> .sbt/0.13/local.sbt
fi
cd $KAFKA_MANAGER
sbt clean dist
cd target/universal/

if [ ! -f kafka-manager-${VERSION}.zip ]; then
	echo "	Error building kafka manager"
	exit 1
else
	echo "	Build done: kafka-manager-${VERSION}.zip"
fi

sha512sum kafka-manager-${VERSION}.zip > kafka-manager-${VERSION}.zip.sha512.txt

# Publish to package server
echo "curl -X POST --data-binary @kafka-manager-${VERSION}.zip $PACKAGE_SERVER/packages/platform/releases/kafka-manager/kafka-manager-${VERSION}.zip"
curl -X POST --data-binary @kafka-manager-${VERSION}.zip $PACKAGE_SERVER/packages/platform/releases/kafka-manager/kafka-manager-${VERSION}.zip
echo "curl -X POST --data-binary @kafka-manager-${VERSION}.zip.sha512.txt $PACKAGE_SERVER/packages/platform/releases/kafka-manager/kafka-manager-${VERSION}.zip.sha512.txt"
curl -X POST --data-binary @kafka-manager-${VERSION}.zip.sha512.txt $PACKAGE_SERVER/packages/platform/releases/kafka-manager/kafka-manager-${VERSION}.zip.sha512.txt
