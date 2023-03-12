#!/bin/bash
# based on https://jamielinux.com/docs/openssl-certificate-authority/create-the-intermediate-pair.html
source ./common.sh

intermediateName="${1:-intermediate}"

cd intermediate

log "STARTING: $intermediateName"

# Key
# https://www.openssl.org/docs/man3.0/man1/openssl-genrsa.html
log "Generating key: $intermediateName"
openssl genrsa -aes256 -passout pass:$passphrase -out "private/$intermediateName.key" 4096
#It means to protect a file against the accidental overwriting, removing, renaming or moving files.
log "Protecting key: $intermediateName"
chmod 400 "private/$intermediateName.key"

# CSR
log "Generating CSR: $intermediateName"
openssl req -config ../openssl.cnf -new -sha256 -passin pass:$passphrase \
      -subj "/C=GB/ST=England/O=Pachamama Ltd/CN=$intermediateName.pachamama.ltd/emailAddress=$intermediateName@pachamama.org" \
      -key "private/$intermediateName.key" \
      -out "csr/$intermediateName.csr"

# CA signing Intermediate cert
log "Changing to CA folder"
cd ../ca

cert="../intermediate/certs/$intermediateName.cert"
log "Generating certificate: $intermediateName"
openssl ca -config ../openssl.cnf -extensions v3_intermediate_ca \
      -days 3650 -notext -md sha256  -passin pass:$passphrase \
      -in "../intermediate/csr/$intermediateName.csr" \
      -out $cert

# You can only read apple.txt, as everyone else.
log "Protecting certificate: $intermediateName"
chmod 444 $cert

# Intermediate verification
log "Verifiying certificate: $intermediateName"
openssl x509 -noout -text -in $cert

# Creating chain file
pem="../intermediate/certs/ca-chain-$intermediateName.pem"
log "Creating chain: $pem"
cat $cert certs/ca.cert > $pem
chmod 444 $pem 

log "FINISHED: $intermediateName"
cd ..
