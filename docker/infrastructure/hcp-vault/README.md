# Remal Image: HashiCorp Vault

Start:
* In the foreground: `docker compose --env-file remal.com.env up`
* In the background: `docker compose --env-file remal.com.env up -d`
* Login to container: `sshpass -p password ssh -oStrictHostKeyChecking=no root@vault.remal.com -p 13102`
* Open this: https://localhost:13103
* Search for the login `Root Token` in the docker log.

## License and Copyright
Contact:   arnold.somogyi@gmail.com

Copyright: Copyright (c) 2020-2026 Remal Software

This work is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License.
To view a copy of this license, visit: https://creativecommons.org

You are free to share and adapt the material for personal or hobby purposes, provided you give appropriate credit and do not use the material for commercial gain.
