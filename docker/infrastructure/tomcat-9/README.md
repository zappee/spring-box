# Remal Image: Apache-Tomcat 9

## 1) Overview
This image is an official Remal Docker image, used as a base image of the subsequent docker images.

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

## 5) License and Copyright
Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.

## Annex 1) Access log customization
The configured `localhost_access_log.YYYY-MM-DD.txt` logfile pattern layout configuration:

~~~
%t, %h, %u, "%r", %s, %b, "%{Referer}i", "%{User-Agent}i", %D, %F
~~~

Columns:

| column number |   pattern    | description                                                                                                |
|:-------------:|:------------:|------------------------------------------------------------------------------------------------------------|
|      1.       |     `%t`     | Date and time                                                                                              |
|      2.       |     `%h`     | Remote host name (or IP address if enableLookups for the connector is false)                               |
|      3.       |     `%u`     | Remote user that was authenticated (if any), else '-' (escaped if required)                                |
|      4.       |     `%r`     | First line of the request (method and request URI)                                                         |
|      5.       |     `%s`     | HTTP status code of the response                                                                           |
|      6.       |     `%b`     | Bytes sent excluding HTTP headers, or '-' if zero                                                          |
|      7.       |  `Referer`   | The Referer HTTP request header (the absolute or partial address from which a resource has been requested) |
|      8.       | `User-Agent` | Identify of the application, operating system, vendor, and/or version of the requesting user agent         |
|      9.       |     `%D`     | Time taken to process the request in millis                                                                |
|      10.      |     `%F`     | Time taken to commit the response, in milliseconds                                                         |

Sample log:
~~~
[07/Feb/2023:22:28:28 +0000], 172.17.0.1, -, "GET / HTTP/1.1", 200, 11230, "-", "Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101 Firefox/102.0", 1645, 1643
[07/Feb/2023:22:28:29 +0000], 172.17.0.1, -, "GET /tomcat.css HTTP/1.1", 200, 5542, "http://localhost:13080/", "Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101 Firefox/102.0", 9, 9
[07/Feb/2023:22:28:29 +0000], 172.17.0.1, -, "GET /bg-nav.png HTTP/1.1", 200, 1401, "http://localhost:13080/tomcat.css", "Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101 Firefox/102.0", 2, 1
~~~
