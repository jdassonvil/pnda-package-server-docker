#!/bin/sh

echo "Step 9: Building Kafka manager" >> $LOG_FILE
VERSION=1.3.1.6
KAFKA_MANAGER="$PWD/kafka-manager-${VERSION}"
if [ ! -d $KAFKA_MANAGER ]; then
  echo "downloading kafka manager $VERSION in $PWD" >> $LOG_FILE
  wget https://github.com/yahoo/kafka-manager/archive/${VERSION}.tar.gz
  tar xzf ${VERSION}.tar.gz
else
  echo "	KAFKA_MANAGER is already set as $KAFKA_MANAGER" >> $LOG_FILE
fi
if [ ! -f .sbt/0.13/local.sbt ]; then
	mkdir -p .sbt/0.13
	echo 'scalacOptions ++= Seq("-Xmax-classfile-name","100")' >> .sbt/0.13/local.sbt
fi
cd $KAFKA_MANAGER
sbt clean dist
cd target/universal/
if [ ! -f kafka-manager-${VERSION}.zip ]; then
	echo "	Error building kafka manager" >> $LOG_FILE
	exit 1
else
	echo "	Build done: kafka-manager-${VERSION}.zip" >> $LOG_FILE
fi
sha512sum kafka-manager-${VERSION}.zip > kafka-manager-${VERSION}.zip.sha512.txt
mkdir -p "$RELEASE_PATH/packages/platform/releases/kafka-manager"
mv kafka-manager-${VERSION}.zip $RELEASE_PATH/packages/platform/releases/kafka-manager/kafka-manager-${VERSION}.zip
mv kafka-manager-${VERSION}.zip.sha512.txt $RELEASE_PATH/packages/platform/releases/kafka-manager/kafka-manager-${VERSION}.zip.sha512.txt
cd ../../..
