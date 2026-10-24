# Remal Spring Box: OpenJDK 21 Omni Runner image

## 1) Overview
Image name: `springbox-openjdk-omni-runner`

This ultimate _Omni_ image extends our [Java Runner with PostgreSQL](https://github.com/zappee/spring-box/tree/main/docker/application/java-25-postgres-runner) image.
It is our largest Java Runner image, packed with additional tools and Linux packages required by specialized Java applications.

## 2) Features
* `fonts-dejavu` Linux package: This is a system-level TrueType fonts (.ttf) required by Java graphics engines, reporting libraries (e.g., JasperReports), and PDF/Excel/Word generators (e.g., Apache POI) to render text correctly without crashing. If your containerized Java app tries to generate a chart, Excel sheet, or PDF without these fonts installed in the OS layer, it will crash with a `NullPointerException` or an `AWTError` stating that it cannot instantiate the font manager.

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
