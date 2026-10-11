# Remal Image: ForgeRock Access Management

### 1) Overview
This is a Remal Docker image for ForgeRock Access Management , using [openjdk-11](../../core/openjdk-11) as a base image.

### 2) Ports used by the image

| container port | description              |
|----------------|--------------------------|
| 22             | SSH                      |
| 8080           | Apache Tomcat HTTP port  |
| 443            | Apache Tomcat HTTPs port |

Tomcat web console user:
* account: `admin`/`password`

Access Management admin user:
* account: `amAdmin`/`password`
* OpenAM web console: [https://am.remal.com:13024/openam]()

## 3) Troubleshooting
* Turn on SSL debug log: `-Djavax.net.debug=all`
* Monitoring the network traffic
    ~~~~
    $ tcpdump --interface any -f "not port 22"
    $ tcpdump --interface any -f "not port 22 and not port 636
    ~~~~

## 4) License and Copyright
Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.

## Annex 1) Manual installation of ForgeRock Access Management
Open the AM web console in a web browser: [https://am.hello.com:13024/openam](https://am.hello.com:13024/openam), then follow the instructions.

* Step 1: Default user password
  * default user: `amAdmin`
  * password: `password`


* Step 2: Server settings
  * server URL: `https://am.hello.com:13034`
  * cookie domain: `hello.com`
  * platform locale: `en_US`
  * configuration directory: `/home/openam`


* Step 3: Configuration Data Store Settings
  * data store: `External DS`
  * SSL/TLS enabled: `true`
  * host name: `ds.hello.com`
  * port: `636`
  * encryption key:
  * root suffix: `ou=am-config,dc=hello,dc=com`
  * login ID: `uid=am-config,ou=admins,ou=am-config,dc=hello,dc=com`
  * password: `password`
  * new deployment: `true`


* Step 4: User Data Store Settings
  * user data store type: `ForgeRock Directory Services (DS)`
  * SSL/TLS enabled: `true`
  * directory name: `ds.hello.com`
  * port: `636`
  * root suffix: `ou=am-identity,dc=hello,dc=com`
  * login ID: `uid=am-identity-bind-account,ou=admins,ou=am-identity,dc=hello,dc=com`
  * password: `password`
