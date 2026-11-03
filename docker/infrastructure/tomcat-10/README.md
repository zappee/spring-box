# Remal Spring Box: Apache Tomcat 10 image

## 1) Overview
Image name: `springbox-tomcat-10`

A production-ready, security-hardened Apache Tomcat 10 container image optimized for Jakarta EE deployment.
Features a high-performance NIO network connector engine, native OpenSSL cryptographic routing, and structured, pixel-aligned DevOps logging for clean container orchestration and troubleshooting.

## 2) Features
* **Apache Tomcat 10 server ready:** Fully configured and ready for the application inside this container.
* **Apache Tomcat Admin account:** `admin`/`password`

## 3) Ports used by the container
* 22: SSH
* 1331: Readiness signal
* 8080: HTTP
* 8443: HTTPS
* 5005: JVM debug

## 4) Usage
Start the container:
~~~
DOMAIN_NAME=remal.com; docker run -d \
   --name tomcat.${DOMAIN_NAME} \
   -p 18080:8080 \
   -p 10022:22 \
   springbox-tomcat-10:0.8.0
~~~

Log in to the running container:
~~~
sshpass -p password ssh -oStrictHostKeyChecking=no root@localhost -p 10022
~~~

Web console access:
~~~
http://localhost:18080
~~~

## License and Copyright
Contact:   arnold.somogyi@gmail.com

Copyright: Copyright (c) 2020-2026 Remal Software

This work is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License.
To view a copy of this license, visit: https://creativecommons.org

You are free to share and adapt the material for personal or hobby purposes, provided you give appropriate credit and do not use the material for commercial gain.
