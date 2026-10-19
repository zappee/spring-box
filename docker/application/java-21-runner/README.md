# Remal Image: Java 21 Runner

## Exposed ports
* **8500 (HTTP):** Used for unencrypted HTTP API traffic and the Consul Web UI. By default, this is what your Java applications, the consul CLI, and local development configurations use to register services, check health, and fetch key/value data.
* **8501 (HTTPS):** Used for encrypted TLS (HTTPS) API traffic and the secure Web UI. It is typically disabled by default but is configured in production or secure environments to protect sensitive infrastructure data using mTLS.

## License and Copyright
Contact: arnold.somogyi@gmail.com

Copyright: Copyright (c) 2020-2026 Remal Software

This work is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License.
To view a copy of this license, visit: https://creativecommons.org

You are free to share and adapt the material for personal or hobby purposes, provided you give appropriate credit and do not use the material for commercial gain.
