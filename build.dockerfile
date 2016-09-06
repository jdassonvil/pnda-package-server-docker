FROM ubuntu:14.04

RUN apt-get update --fix-missing
RUN apt-get install -y apt-transport-https

RUN echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 642AC823

RUN apt-get update -y && apt-get install -y wget git nodejs npm gradle curl python-setuptools sbt

RUN ln -s /usr/bin/nodejs /usr/bin/node

RUN npm install grunt

ENV GITHUB_ENDPOINT https://github.com/pndaproject
ENV BRANCH master

WORKDIR /tmp

# Run Command
CMD ["/bin/bash"]
