# ldaps-relay
Simple Makefile for managing a docker's container for relay requets LDAP to LDAPS.  
So, you can connect to ldap://localhost:389 and all requests will relayed to ldaps://LDAP_HOST:636  
* Usage: 
```
export LDAP_HOST=yourldaphost.domain.local
make # will build and start container.
```
* In addition:
```
make build # build an image. do not forget set LDAP_HOST before run it.
make start # will start the container
make stop # remove the container
make log # show log from container
```


* If you want to connect to the relay from another containaer, without creating networks or links or another methods,  
just add rule to your firewall (pay attention that this method increasing security risks on your host):
```
iptables -A INPUT -i docker0 -j ACCEPT # allow all traffic from conatinaers to host
```
Enjoy!
