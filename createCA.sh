#!/bin/bash
# based on https://jamielinux.com/docs/openssl-certificate-authority/create-the-root-pair.html
source ./common.sh

cd ca

# Preparation
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber

# Key
# https://www.openssl.org/docs/man3.0/man1/openssl-genrsa.html
log "Generating key: CA"
openssl genrsa -aes256 -passout pass:$passphrase -out private/ca.key 4096
log "Protecting key: CA"
chmod 400 private/ca.key

# Certificate
# https://www.openssl.org/docs/man3.0/man1/openssl-req.html
log "Generating certificate: CA"
openssl req -config ../openssl.cnf \
      -subj "/C=GB/ST=England/O=Pachamama Ltd/CN=pachamama.ltd/emailAddress=support@pachamama.org" \
      -key private/ca.key -passin pass:$passphrase  \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -out certs/ca.cert

log "Protecting certificate: CA"
chmod 444 certs/ca.cert

# Verification
log "Verifiying certificate: CA"
openssl x509 -noout -text -in certs/ca.cert

cd ..
