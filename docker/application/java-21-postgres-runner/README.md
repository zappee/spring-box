# Remal Spring Box: OpenJDK 21 Runner with PostgreSQL image

## 1) Overview
Image name: `springbox-openjdk-postgres-runner`

This image is an extends of our base [Java Runner](https://github.com/zappee/spring-box/tree/main/docker/application/java-25-runner) images layer by adding a pre-installed, and ready-to-use PostgreSQL database server on top of that image. While everything detailed in the Java Runner images section applies to this image as well, this image requires a few extra configuration steps to operate the embedded database engine.

It is recommended to usie this image if your application requires a dedicated database and follows a database-per-container or database-per-service design pattern.

⚠️ _**Important:** Because this image runs both the Java application and the database server inside a single container, it may require higher memory and CPU allocations._

## 2) Features
* **PostgreSQL database server ready:** Fully configured and ready for the application inside this container.

## 3) Ports used by the container
* 22: SSH
* 1331: Readiness signal
* 80: HTTP
* 443: HTTPS
* 5005: JVM debug
* 5432:PostgreSQL

## License and Copyright
Contact:   arnold.somogyi@gmail.com

Copyright: Copyright (c) 2020-2026 Remal Software

This work is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License.
To view a copy of this license, visit: https://creativecommons.org

You are free to share and adapt the material for personal or hobby purposes, provided you give appropriate credit and do not use the material for commercial gain.
