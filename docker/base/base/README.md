# Remal Base Image

## 1) Overview
This image is an official Remal Docker image, used as a base image of the subsequent docker images.

## 2) Image details
* based on the latest `alpine` image
* available Unix shells: `bash` and `sh`, `bash` is set as the default shell
* installed and configured `OpenSSH` connectivity tool
* ssh-server is running on port 22
* password of the `root` user is set to `password`
* customized bash prompt that shows the container name and version
* added bash aliases: `ll` and `ls`
* bash scripts under the `/docker.init` directory are executed only once during the first container startup
* bash scripts under the `/docker.startup` directory are executed always when the container starts
* `shutdown-actions.sh` bash script that is executed automatically before the container shuts down completely if the `docker stop --timeout 60` is used

## 3) Ports used by the image

| container port | description |
|----------------|-------------|
| 22             | SSH         |

## 4) License and Copyright
Copyright (c) 2020-2026 Remal Software, Arnold Somogyi. All rights reserved.
