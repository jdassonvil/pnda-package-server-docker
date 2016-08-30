#!/bin/sh

if [ -z "$LOG_FILE" ]; then
	export LOG_FILE=/var/www/html/output.log
fi
echo "Starting build script" > $LOG_FILE

if [ -z "$GITHUB_ENDPOINT" ]; then
    echo "Need a GitHub endpoint - GITHUB_ENDPOINT" >> $LOG_FILE
    exit 1
fi  

if [ -z "$BRANCH" ]; then
    echo "Need a branch - BRANCH" >> $LOG_FILE
    exit 1
fi 

echo "Using GitHub endpoint: $GITHUB_ENDPOINT" >> $LOG_FILE
echo "Using branch: $BRANCH" >> $LOG_FILE

export RELEASE_PATH="/var/www/html/$BRANCH"
#RELEASE_PATH="$PWD/$BRANCH"
echo "Set RELEASE_PATH: $RELEASE_PATH" >> $LOG_FILE


for file in build.d/*
do
  /bin/bash $file
done
