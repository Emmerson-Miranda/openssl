#!/bin/bash
source ./common.sh

intermediateName="${1:-intermediate}"

cd intermediate

key="private/$intermediateName.key"
csr="csr/$intermediateName.csr"
cert="../intermediate/certs/$intermediateName.cert"
subj="/C=GB/ST=England/O=Pachamama Ltd/CN=$intermediateName.pachamama.ltd/emailAddress=$intermediateName@pachamama.org"
pem="../intermediate/certs/ca-chain-$intermediateName.pem"
ext="v3_intermediate_ca"

log "STARTING: $intermediateName"

# Key
log "Generating key: $intermediateName"
openssl genrsa -aes256 -passout pass:$passphrase -out $key 4096
#It means to protect a file against the accidental overwriting, removing, renaming or moving files.
log "Protecting key: $intermediateName"
chmod 400 $key

# CSR
log "Generating CSR: $intermediateName"
openssl req -config ../openssl.cnf -new -sha256 -passin pass:$passphrase \
      -subj "$subj" \
      -key $key \
      -out $csr

# CA signing Intermediate cert
log "Changing to CA folder"
cd ../ca

log "Generating certificate: $intermediateName"
openssl ca -config ../openssl.cnf -extensions $ext \
      -days 3650 -notext -md sha256  -passin pass:$passphrase \
      -in "../intermediate/$csr" \
      -out $cert

# You can only read apple.txt, as everyone else.
log "Protecting certificate: $intermediateName"
chmod 444 $cert

# Intermediate verification
log "Verifiying certificate: $intermediateName"
openssl x509 -noout -text -in $cert

# Creating chain file
log "Creating chain: $pem"
cat $cert certs/ca.cert > $pem
chmod 444 $pem 

log "FINISHED: $intermediateName"
cd ..
