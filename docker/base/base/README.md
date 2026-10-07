# Remal Spring-Box Base image

## 1) Overview
This is the official _Remal Spring-Box_ base Docker image, designed to provide core utilities and runtime configurations for all downstream images.

## 2) Image details
* **Base image:** Built on top of the lightweight `alpine` Linux distribution.
* **Available shells:** Includes both `sh` and `bash`, with `bash` configured as the default shell.
* **OpenSSH integration:** A fully installed and configured `OpenSSH` server. The SSH daemon runs on port `22`.
* **Credentials:** The default password for the `root` user is set to `password`.
* **Custom Bash environment:**
    * Tailored `bash` prompt dynamically displaying the current container name and version.
    * Pre-configured shell aliases for productive navigation (`ll` and `ls`).
* **Initialization scripts:**
    * **First startup:** Bash scripts placed within the `/docker.init` directory are executed exclusively during the container's initial startup.
    * **Regular start:** Bash scripts placed within the `/docker.startup` directory are executed every time the container boots.
* **Graceful shutdown:** Implements an automated lifecycle hook that triggers the `/shutdown-actions.sh` script prior to complete container termination. To ensure proper execution, stop the container with an adequate grace period, for example: `docker stop --timeout 60 <container-id>`.

## 3) Exposed ports
* **22 (TCP):** Secure Shell (SSH) management access.
* **1331 (TCP):** Readiness signal port

## 4) License and Copyright
Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
