APP = ldaps-relay
LDAP_HOST ?= ldaphost.example.com

.PHONY: start stop log

all: build stop start
restart: stop start

dockerfile:
	@echo >d 'FROM alpine:3.8'
	@echo >>d 'RUN apk --update add stunnel libressl ca-certificates'
	@echo >>d 'COPY o /etc/stunnel/openssl.cnf'
	@echo >>d 'COPY s /etc/stunnel/stunnel.conf'
	@echo >>d 'RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/stunnel/stunnel.key -out /etc/stunnel/stunnel.pem -config /etc/stunnel/openssl.cnf >/dev/null 2>&1'
	@echo >>d 'CMD ["stunnel"]'
	@echo >>d 'EXPOSE 389'

opensslfile:
	@echo >o 'RANDFILE=/dev/urandom'
	@echo >>o '[req]'
	@echo >>o 'default_bits=2048'
	@echo >>o 'default_keyfile=/etc/stunnel/stunnel.key'
	@echo >>o 'distinguished_name=req_distinguished_name'
	@echo >>o 'prompt=no'
	@echo >>o 'policy=policy_anything'
	@echo >>o '[req_distinguished_name]'
	@echo >>o 'commonName=localhost'

stunnelfile:
	@echo >s 'cert=/etc/stunnel/stunnel.pem'
	@echo >>s 'key=/etc/stunnel/stunnel.key'
	@echo >>s 'CAfile=/etc/ssl/certs/ca-certificates.crt'
	@echo >>s 'setuid=root'
	@echo >>s 'setgid=root'
	@echo >>s 'pid=/var/run/stunnel.pid'
	@echo >>s 'socket=l:TCP_NODELAY=1'
	@echo >>s 'socket=r:TCP_NODELAY=1'
	@echo >>s 'debug=0'
	@echo >>s 'foreground=yes'
	@echo >>s 'client=yes'
	@echo >>s '[$(APP)]'
	@echo >>s 'accept=389'
	@echo >>s 'connect=$(LDAP_HOST):636'

build:
	@make opensslfile stunnelfile dockerfile
	@docker build -t $(APP) -f d .
	@rm -rf {d,o,s}
	@docker rmi -f $(shell docker images -qf 'dangling=true') >/dev/null 2>&1 || true

start:
	@docker run -d \
	--restart=always \
	-p 389:389 \
	--name=$(APP) \
	$(APP)

stop:
	@docker rm -fv $(APP) >/dev/null 2>&1| true

log:
	@docker logs -f $(APP)


