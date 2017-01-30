docker-containers:
  lookup:
    jenkins:
      image: jdassonvil/jenkins-docker:latest
      runoptions:
        - "-p 8080:8080"
        - "-p 50000:50000"
        - "--rm"
        - "-u root"
        - "-v /var/jenkins_home:/var/jenkins_home"
        - "-v /var/run/docker.sock:/var/run/docker.sock"
        - "-v /tmp:/tmp"
