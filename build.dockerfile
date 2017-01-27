FROM ubuntu:16.04

RUN apt-get update && apt-get install -y apt-transport-https ca-certificates

RUN echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list

RUN apt-get update -y 
RUN apt-get install --allow-unauthenticated -y sbt
RUN apt-get install -y wget git nodejs npm gradle curl python-setuptools

RUN ln -s /usr/bin/nodejs /usr/bin/node

RUN npm install -g grunt

ENV BRANCH master

WORKDIR /tmp

# Run Command
ENTRYPOINT ["/bin/bash"]
