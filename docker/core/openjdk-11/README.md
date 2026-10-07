# Remal Spring-Box - OpenJDK 11 image

## 1) Overview
This is an official _Remal Spring-Box_ Docker core base image, designed to serve as the foundational base layer for all subsequent downstream Docker images.

## 2) Image details
* **Base image:** Built on top of the latest [Remal Spring-Box Base image](../../base/base).
* **OpenJDK:** Installed **OpenJDK 11** for Java applications.
* **OpenSSL integration:** Installed **OpenSSL 11** cryptographic library for securing general network traffic.
* **java-cacerts package:** This installed package is an essential utility in Alpine Linux designed to manage and update the Java keystore (cacerts) automatically based on the system's root certificates.

## 3) Exposed ports
* **22 (TCP):** Secure Shell (SSH) management access
* **1331 (TCP):** Readiness signal port
* **8000 (TCP):** JVM debug port

## 4) License and Copyright
Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
