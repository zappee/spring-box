# Remal Image: OpenJDK 21 Runner

## 1) Overview
Image name: `springbox-openjdk-runner`

The Java Runner is an optimized Docker image designed specifically for running containerized Java applications, particularly Spring Boot executable JAR files. Its advanced design accelerates development velocity by providing pre-configured, enterprise-level infrastructure features out of the box:

⚠️ _**Important:** Use this container to deploy and run your Java applications as executable JARs._

## 2) Features
* **OpenJDK 21 and 25 ready:** Optimized for running Spring Boot executable JAR files.
* **Cluster-wide HashiCorp Consul integration:** Provides Dynamic Service Discovery, automated application Health Monitoring via Actuator endpoints, and dynamic runtime Configuration Management using the Consul Key/Value store.
* **Cluster-wide Hazelcast integration:** Configured to instantly join to distributed topologies, seamlessly supporting Embedded Cache, Client-Server, and Near-Cache architectures.
* **Built-in Prometheus metrics collector:** Pre-configured to automatically expose application and JVM telemetry, including CPU usage, memory utilization, and REST performance. It fully integrates with Micrometer to easily track custom meters, counters, and timers.
* **Grafana analytics and visualization platform:** Features pre-configured visualization dashboards that transform raw metrics collected by Prometheus into real-time, intuitive charts.

## Ports used by the container
* **80 (HTTP):** The default exposed HTTP port where Spring Boot REST controller endpoints listen for incoming traffic.
* **8443 (HTTPS):** The default exposed HTTPS port where Spring Boot REST controller endpoints listen for incoming traffic.
* **5005 (JVM debug):** Used for encrypted TLS (HTTPS) API traffic and the secure Web UI. It is typically disabled by default but is configured in production or secure environments to protect sensitive infrastructure data using mTLS.

## License and Copyright
Contact: arnold.somogyi@gmail.com

Copyright: Copyright (c) 2020-2026 Remal Software

This work is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License.
To view a copy of this license, visit: https://creativecommons.org

You are free to share and adapt the material for personal or hobby purposes, provided you give appropriate credit and do not use the material for commercial gain.
