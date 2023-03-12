#!/bin/bash
source ./common.sh

cd ca

# Preparation
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber

key="private/ca.key"
cert="certs/ca.cert"
subj="/C=GB/ST=England/O=Pachamama Ltd/CN=pachamama.ltd/emailAddress=support@pachamama.org"

# Key
log "Generating key: CA"
openssl genrsa -aes256 -passout pass:$passphrase -out $key 4096
log "Protecting key: CA"
chmod 400 $key

# Certificate
log "Generating certificate: CA"
openssl req -config ../openssl.cnf \
      -subj "$subj" \
      -key "$key" -passin pass:$passphrase  \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -out "$cert"

log "Protecting certificate: CA"
chmod 444 "$cert"

# Verification
log "Verifiying certificate: CA"
openssl x509 -noout -text -in "$cert"

cd ..
