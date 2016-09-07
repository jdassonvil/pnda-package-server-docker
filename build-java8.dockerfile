FROM java:8

RUN apt-get update && apt-get install -y apt-transport-https

RUN echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 642AC823

RUN apt-get update -y && apt-get install -y wget git sbt

RUN wget https://archive.apache.org/dist/maven/maven-3/3.2.5/binaries/apache-maven-3.2.5-bin.tar.gz && \
    tar zxf apache-maven-3.2.5-bin.tar.gz && \
    mv apache-maven-3.2.5 /usr/share/ && \
    ln -s /usr/share/apache-maven-3.2.5/bin/mvn /etc/alternatives/mvn && \
    ln -s /etc/alternatives/mvn /usr/bin


ENV GITHUB_ENDPOINT https://github.com/pndaproject
ENV BRANCH master

WORKDIR /tmp

# Run Command
CMD ["/bin/bash"]
