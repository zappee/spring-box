# Remal Image: Java 21 Runner with Postgres

## Postgres

### Persist data in a dockerized Postgres database using volumes
* docker-compose.yml
    ```
    services:
        user-service:
            image: remal-java-21-postgres-runner:0.8.0
            ...
            volumes:
                - user-service-data:/var/lib/postgresql/data
    
    volumes:
        user-service-data:
            driver: local
    ```

* list volumes
    ```
    $ docker volume ls
    ...
    local     projects_user-service-data
    ```

* volume size
    ```
    docker system df --verbose | grep <container-name>
    ```

* delete unused volumes
    ```
    $ docker volume prune --all
    ```

* backup volume

  Normally, if you want to back up a data volume, you start a new container using the volume you want to back up, then execute the tar command to produce an archive of the volume content:
    ```
    $ VOLUME_NAME=projects_user-service-data
  
    $ docker run --rm \
       --volume "$VOLUME_NAME":/volume \
       --volume "$(pwd)":/backup \
       busybox \
       tar --exclude='postmaster.pid' -zcvf /backup/"$VOLUME_NAME".tar.gz -C /volume .
    ```
  Backing up Docker volumes is critical if you care about the data they store.
  Docker volumes do not have a built-in "backup" command. 
  The standard approach involves using a temporary container to create or extract a compressed archive (tarball) of the volume's data.


* restore volume
    ```
    $ docker run --rm \
         --volume "$VOLUME_NAME":/volume \
         --volume $(pwd):/backup \
         busybox sh -c "cd /volume && tar xzf /backup/"$VOLUME_NAME".tar.gz"
    ```

* volume size
    ```
    docker system df --verbose | grep <volume-name>
    ```

### Useful SQL commands
| Function                            | SQL                                |
|-------------------------------------|------------------------------------|
| Determine the version of the server | `SELECT version()`                 |
| List databases                      | `SELECT datname FROM pg_database`  |
| List Users                          | `SELECT * FROM pg_catalog.pg_user` |

## License and Copyright
Contact:   arnold.somogyi@gmail.com

Copyright: Copyright (c) 2020-2026 Remal Software

This work is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License.
To view a copy of this license, visit: https://creativecommons.org

You are free to share and adapt the material for personal or hobby purposes, provided you give appropriate credit and do not use the material for commercial gain.
