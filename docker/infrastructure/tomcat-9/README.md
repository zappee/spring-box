# Remal Spring Box: Apache Tomcat 9 image

## 1) Overview
This image is an official Remal Docker image, used as a base image of the subsequent docker images.

DOMAIN_NAME=remal.com; docker run -d \
   --name tomcat.${DOMAIN_NAME} \
   -p 18080:8080 \
   -p 10022:22 \
   springbox-tomcat-9:0.8.0



## 2) Image details
* based on the latest [openjdk-11](../../core/openjdk-11) Remal image
* Apache Tomcat 9, listening on port `8080`
* web console user: `admin`/`password`
* tomcat log improvement to track access to resources better, [(pattern attribute info)](https://tomcat.apache.org/tomcat-9.0-doc/config/valve.html#Access_Log_Valve) 

## 3) Ports used by the image

| container port | description |
|----------------|-------------|
| 22             | SSH         |
| 8080           | HTTP        |

## 4) Supported parameters

| name         | default value                          | description                   |
|--------------|----------------------------------------|-------------------------------|
| JAVA_OPTIONS | `-Xms512m -Xmx512m -XX:+UseParallelGC` | Server startup configuration. |


## License and Copyright
Contact:   arnold.somogyi@gmail.com

Copyright: Copyright (c) 2020-2026 Remal Software

This work is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License.
To view a copy of this license, visit: https://creativecommons.org

You are free to share and adapt the material for personal or hobby purposes, provided you give appropriate credit and do not use the material for commercial gain.
