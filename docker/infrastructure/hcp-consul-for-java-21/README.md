# Remal Image: HashiCorp Consul for Java 21

Login to container:
~~~
sshpass -p password ssh -oStrictHostKeyChecking=no root@consul.hello.com -p 13062
~~~

List of the opened ports on localhost:
~~~
netstat -tulpn | grep LISTEN
~~~

Check if a port is open on a remote machine
~~~
nc -zvw10 consul.hello.com 22
~~~

## License and Copyright
Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
