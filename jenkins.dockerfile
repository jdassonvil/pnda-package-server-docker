FROM jenkins:2.32.1

USER root
RUN apt-get update && apt-get install -y apt-transport-https ca-certificates software-properties-common

RUN curl -fsSL https://yum.dockerproject.org/gpg | apt-key add - && \
  add-apt-repository "deb https://apt.dockerproject.org/repo/ debian-$(lsb_release -cs) main" && \
  apt-get update && apt-get -y install docker-engine

USER jenkins
