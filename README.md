# PNDA Package Server Docker

This is a fork of the pnda package server repository. The build scripts are split into smaller unit, one for each component to build. The build is achieved through a docker image environment which contains every package required.

## Requirements

The scripts are designed to run inside a [Docker](https://www.docker.com) container. See the instructions for [installing Docker](https://docs.docker.com/engine/installation).

The scripts were tested using a host machine running [Ubuntu](http://www.ubuntu.com)

1. 14.04 LTS with 8 GB of memory & Docker version 1.8.3
2. 16.04 LTS with 10 GB of memory & Docker version 1.12.1, build 23cf638

The scripts may work in other UNIX environments as well. See the [Questions & Answers](http://pndaproject.io/qa) site for further information.

## Running the package server

You can use the resources from `/env` to start a package server. Configuration management is achieved through Salt so you have the option to reuse the Salt recipes, to use vagrant to deploy it on Virtual Box or to use terraform to deploy on openstack (more cloud provider might be supported in the future).

In addition to the package server those scripts will also install a jenkins instance and a docker image registry on the target machine.

## Building the packages

You need to have a package server up and running prior to start the build process.

To build a single package use the `build.sh` script:
```
$ ./build.sh <script name> <ip pacakge server>
```
Where the first parameter is the name of the script in the `build.d` directory and the second parameter is the ip address of the packae server. For example:

```
$ ./build.sh platform_console_backend 127.0.0.1
```

Package server is expected to listen on `:3535`.

You can also use `build_all.sh` script which will run every script in `build.d`, it only requires the package server ip as parameter.
