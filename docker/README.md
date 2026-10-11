# Guide for Remal Docker Images 

## 1) Overview

## 3) Development environment
You can start the complete Docker stack on your machine if your machine has enough CPU and memory.

### 3.1) Prepare the environment
Perform the following tasks to prepare your environment to be ready to run the Remal Docker images.

#### 3.1.1) Install tools
* Install Git client.
* Install Docker and Docker-Compose.

#### 3.1.2) Prepare FQDN
Map hostnames to IP addresses in `/etc/hosts` file.
  * `127.0.0.1   am.hello.com`
  * `127.0.0.1   vault.hello.com`

#### 3.1.3) Prepare the environment for Forgerock Directory Server (LDAP)
The LDAP server has some special requirements.
Learn about how to prepare your environment to get it ready for Forgerock Directory Server, check [paragraph 3.1) of this document](infrastructure/forgerock-ds/README.md#31-preparation-of-your-environment).

### 3.2) Build the images
Each image has a build script that is called `build.sh`.
This script can be used to build the particular Docker image.
If you want to build the whole Remal Docker stack then it is recommended to use the `remal.sh` script because it simplifies the processes.
The benefit of using the main script are the followings:
* Not necessary to change between directories while building images.
* Multiple images can be built in one shot.
* The full image set can be built with one run.
* It builds slim images using the `BUILD_TYPE="slim"`  build argument.

The main build script can execute a task or multiple tasks.
For example, the following command builds all the necessary images that you need to have for development and then show the build info:
~~~
$ ./remal.sh abcdi
~~~

Before to use the script, do not forget to set the `REMAL_HOME` environment variable properly. It must point to the root directory of this project.
The default value of the variable is set to the directory from where you are executing the build script.

### 3.3) Start any container
~~~
# run the image
$ docker run --rm --name tmp-container -it IMAGE_NAME[:TAG] bash

# run the image with an empty entrypoint
$ docker run --rm --name tmp-container --entrypoint "" IMAGE_NAME[:TAG]  tail -f /dev/null

# start an interactive shell inside it 
$ docker exec -it tmp-container bash
~~~

### 3.4) Start the development environment
Once the build is done you can start the servers locally and show the application logs by using the same script:
~~~
s remal.sh <command>
~~~

### 3.5) Setting Up Certificate Authorities (CA) in Firefox 
How to get Firefox to trust all self-signed certificates you use locally to serve your development sites over https and not complain about them?
You can add the root CA to your web browser.
The root CA locates in the CA server, the Docker container name is `pki.remal.com`.

![step 1](infrastructure/easy-rsa-pki/docs/firefox-setting-up-ca-step-1.png)

![step 2](infrastructure/easy-rsa-pki/docs/firefox-setting-up-ca-step-2.png)

![step 3](infrastructure/easy-rsa-pki/docs/firefox-setting-up-ca-step-3.png)

### 3.6) Stop the development environment
Docker can back up the current configuration of the running servers before the whole environment will be stopped.
By default, the `docker compose stop` command attempts to stop a container by sending a `SIGTERM` to the running containers.
Then, it waits for a default timeout of 10 seconds. After the timeout, a `SIGKILL` is sent to the containers to forcefully kill it.
The backup processes usually need more time than 10 seconds to finish the backup, so we need to give more time to Docker than the default otherwise the shutdown-hooks will not work able to complete backup tasks.

~~~
$ docker-compose stop --timeout 120
~~~

## 5) License and Copyright
Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.

## Annex 1) Build slim Docker images
Does the Docker Image size matter?

You may think that image sizes are not relevant.
But if you think about the followings then you can realize that it really matters.
* Smaller Docker images take up less disk space.
* Reducing Docker image size cuts the cost of your Google/Amazon Cloud.
* A large Docker image is difficult (takes a lot of time) to upload.

We build as slim images as possible and remove image layers that contains unused data like installation files.
However, removing image layers is not easy because once a file has been copied to the image using the `COPY` Docker command, it can not be removed from the layer despite you delete it later during the build.
That happens because the `COPY` command automatically adds a new layer.
The only way to keep out install packages from the image is not using the `COPY` command.
We can avoid it by downloading the files during the image from a webserver and deleted them after the usage in the same layer.

So for building slim images you need to make the installation files downloadable.
Thus, you need to set up a local web server before the build and make all files available via `HTTP`.
The Remal slim image build process will download the files on-the-fly from your local web server using `wget` during the build instead of using the `COPY` command.

**Steps for the slim image build:**
1. Download [Apache-Tomcat](https://tomcat.apache.org/download-10.cgi) and start it using `bin/catalina.sh run`.
2. Create the following directory structure: `$CATALINA_HOME/webapps/docker-build`.
3. Copy the files and install packages from the `bin/` folder of each image source code into the web server directory.
4. Then start the build using the `slim` parameter, for example `./remal.sh ab`

## Annex 2) Troubleshooting
### BusyBox

* Replace `wget` and `curl` with GNU version
  * `apk --no-cache add curl`
  * `apk --no-cache add wget`

### JVM
+ **JVM debug**: How to attach `VisualVM` to the Java process running in a Docker container
  * At first, you should run your Java application with these JVM parameters:
    ```
    -Dcom.sun.management.jmxremote=true
    -Dcom.sun.management.jmxremote.port=9997
    -Dcom.sun.management.jmxremote.rmi.port=9997
    -Dcom.sun.management.jmxremote.authenticate=false
    -Dcom.sun.management.jmxremote.ssl=false
    -Djava.rmi.server.hostname=0.0.0.0
    ```
  * Then you should expose port for docker: `EXPOSE 9997`
  * Also specify port binding with docker run command: `docker run --publish 9997:9997 ...`
  * After that, you can connect with `JConsole`/`VisualVM` to local port 9997.

* **Optimizing JVM memory in Docker containers**

  By default, the JVM automatically allocates some memory depending on the system memory.
  Even if it is running inside a Docker container, JVM will try to allocate some portion of the total system memory.
  But Docker containers can be limited to use a maximum amount of the memory, and any container using more memory will be killed.
  This poses a risk to our container.
  
  What if a container has less memory than the JVM’s allocated memory?
  Docker will kill the container immediately.
  We can configure the JVM to use minimun and maximum memory with `-Mxm` and `-Mxs` options.
  In this case, the JVM will not use more memory than the maximum.
  This seemingly solves our problem.
  If we set the maximum memory for both the container and the JVM, we will be safe.

  However, if we want to change the container's memory allocation someday, we will also need to change the JVM options too.

  The setting below avoids hardcoding memory limits for the JVM.
  You only need to worry about the container's memory, and the JVM will adjust its memory allocation automatically.

  + Configure JVM memory limits:
      ```
      -XX:+UseContainerSupport
      -XX:MaxRAMPercentage=75.0
      -XX:+UseG1GC
      -XX:MaxGCPauseMillis=100
      -XX:+ParallelRefProcEnabled
      -XX:+UseStringDeduplication
      -XX:+HeapDumpOnOutOfMemoryError
      -XX:+ExitOnOutOfMemoryError
      -XX:HeapDumpPath=/heap-dump
      ```

* Configure container memory limits:
    ```
    services:
      service-container:
        image: ...
        ...
        deploy:
          resources:
            limits:
              memory: 384M
    ```


### Network
* List of the opened port
  * Connect to the container with SSH and install nmap: `apk add nmap` or `yum install nmap`
  * Run the port-scan with `nmap -p- <host>`, e.g. `nmap ds.remal.com`
  * Check if port is open or closed: `nc -w 5 -z <host> <port>`

### PKI
* Lists entries in a keystore: `keytool -list -v -keystore <keystore-file> -storepass <changeit>`
* Test HTTPS connection: `curl https://user-service.hello.com:8443/actuator/health`
* How to check Subject Alternative Names for an SSL/TLS certificate?
  ~~~
  $ apk add openssl
  $ openssl s_client -connect website.example:443 </dev/null | openssl x509 -noout -text

  # or
  $ openssl s_client -connect website.example:443 </dev/null | openssl x509 -noout -ext subjectAltName
  ~~~

### SSH
* Get rid of the `REMOTE HOST IDENTIFICATION HAS CHANGED` warning that appears while connecting to a container using SSH.
  
  Disable SSH localhost checking specifically for localhost by setting `NoHostAuthenticationForLocalhost` to `yes` in your `~/.ssh/config` as follows:
  ~~~
  NoHostAuthenticationForLocalhost yes
  ~~~

* Connect to a container Docker network and run a command:
  ~~~
  sshpass -p password ssh -oStrictHostKeyChecking=no root@pki.remal.com "ls -all"
  ~~~

## Annex 3) Numbering of Docker container scripts
#### base
* 10000: base

#### infrastructure
* 30100: Easy RSA
* 30200: Tomcat
* 30300: OpenDS
* 30400: OpenAM
* 30500: Vault
* 30600: Consul for Java 21
* 30700: Consul for Java 25
* 30800: Hazelcast

#### monitoring
* 40100: Prometheus
* 40200: Grafana

#### application
* 70100: Java 21 runner
* 70200: Java 21 + Postgres
* 70300: Java 25 runner
* 70400: Java 25 + Postgres
