FROM ubuntu:16.04

RUN apt-get update && apt-get install -y apt-transport-https ca-certificates

RUN echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list

RUN apt-get update -y 
RUN apt-get install --allow-unauthenticated -y sbt
RUN apt-get install -y wget git nodejs npm gradle curl python-setuptools

RUN ln -s /usr/bin/nodejs /usr/bin/node

RUN npm install -g grunt

RUN wget https://archive.apache.org/dist/maven/maven-3/3.2.5/binaries/apache-maven-3.2.5-bin.tar.gz && \
    tar zxf apache-maven-3.2.5-bin.tar.gz && \
    mv apache-maven-3.2.5 /usr/share/ && \
    ln -s /usr/share/apache-maven-3.2.5/bin/mvn /etc/alternatives/mvn && \
    ln -s /etc/alternatives/mvn /usr/bin

ENV BRANCH master

WORKDIR /tmp

# Run Command
ENTRYPOINT ["/bin/bash"]
