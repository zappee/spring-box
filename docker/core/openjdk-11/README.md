# Remal Image: OpenJDK 11

## 1) Overview
This image is an official Remal Docker image, used as a base image of the subsequent docker images.

## 2) Image details
* based on the latest [Remal Base](../../base/base) image
* `bash` and `sh`, bash is the default
* customized bash prompt that shows the container name and version
* bash aliases: `ll` and `ls`
* `ssh` running on port 22
* password of the `root` user is set to `password`
* `OpenJDK 11`
* `OpenSSH` tool
* `head.sh` and `tail.sh` bash scripts that can be used in the child containers to execute custom commands
* `shutdown-actions.sh` bash script that is executed automatically before the container shuts down

## 3) Ports used by the image

| container port | description |
|----------------|-------------|
| 22             | SSH         |

## License and Copyright
Contact:   arnold.somogyi@gmail.com

Copyright: Copyright (c) 2020-2026 Remal Software

This work is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License.
To view a copy of this license, visit: https://creativecommons.org

You are free to share and adapt the material for personal or hobby purposes, provided you give appropriate credit and do not use the material for commercial gain.
