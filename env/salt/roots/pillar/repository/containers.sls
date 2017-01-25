docker-containers:
  lookup:
    pkgserver:
      image: jdassonvil/go-pkgserver:latest
      runoptions:
        - "-p 3535:3535"
        - "--rm"
        - "-v pkgserver-data:/resources" 
    registry:
      image: registry:2
      runoptions:
        - "-p 5000:5000"
        - "--rm"
        - "-v regsitry-data:/var/lib/registry"
