# Remal Image: OpenJDK 17

## 1) Overview
Image name: `springbox-openjdk`

The platform supports production-ready runtimes for [OpenJDK 11, 17, 21, and 25](https://github.com/zappee/spring-box/tree/main/docker/core).

⚠️ _**Important:**_
_These core images are designed to serve as top layer for custom builds and are not recommended for running Java applications (*.jar) directly._
_To deploy and execute your Java applications, we highly recommend using our specialized [Java Runner](#8-java-runner-containers---springbox-openjdk-runner) containers._

#### 7.1) Features
This Docker image layer only adds
* specific OpenJDK installations
* OpenSSL to deal with keystores

## License and Copyright
Contact:   arnold.somogyi@gmail.com

Copyright: Copyright (c) 2020-2026 Remal Software

This work is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License.
To view a copy of this license, visit: https://creativecommons.org

You are free to share and adapt the material for personal or hobby purposes, provided you give appropriate credit and do not use the material for commercial gain.
