# Remal Image: HashiCorp Vault

Start the container with `docker-compose`:
```
version: '3'
services:
    # ----- Private Certificate Authority Server -------------------------------
    pki:
        image: remal-private-ca:0.8.0
        container_name: pki
        hostname: pki.hello.com
        ports:
            - "13012:22"   # SSH
        environment:
            - EASYRSA_REQ_CN=hello.com
            - EASYRSA_REQ_COUNTRY=DK
            - EASYRSA_REQ_PROVINCE=Region Hovedstaden
            - EASYRSA_REQ_CITY=Copenhagen
            - EASYRSA_REQ_ORG=Hello Software

    # ----- Hashirorp Vault service --------------------------------------------
    vault:
        image: remal-vault:0.8.0
        container_name: vault
        hostname: vault.hello.com
        depends_on:
            - pki
        ports:
            - "13052:22"   # SSH
            - "13058:8200" # vault listening
        environment:
            - PKI_HOST=pki.hello.com
```

Login to container:
```
sshpass -p password ssh -oStrictHostKeyChecking=no root@vault.hello.com -p 13042
```

Processing the audit log:
```
tail -f /var/log/vault-audit.log | while read -r line; do
    echo "$line"
    echo "$line" | jq '.request.path'
    echo "$line" | jq '.request.data.data | keys[]'
    echo "$line" | jq '.response.data.data | keys[]'
done
```

## License and Copyright
Copyright (c) 2020-2026 Remal Software, Arnold SOMOGYI. All rights reserved.
