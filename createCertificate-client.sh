#!/bin/bash
source ./common.sh

intermediateName="${1:-intermediate}"
clientName="${2:-server}"

cd ca

key="../intermediate/private/$intermediateName-$clientName.key"
csr="../intermediate/csr/$intermediateName-$clientName.csr"
cert="../intermediate/certs/$intermediateName-$clientName.cert"
pem="../intermediate/certs/ca-chain-$intermediateName.pem"
subj="/C=GB/ST=England/O=Pachamama Ltd/CN=$intermediateName-$clientName/emailAddress=$clientName@pachamama.org"
ext="usr_cert"

log "STARTING: $intermediateName $clientName"

# Key
log "Generating key: $clientName"
openssl genrsa -out $key 2048
#It means to protect a file against the accidental overwriting, removing, renaming or moving files.
log "Protecting key: $clientName"
chmod 400 $key

# CSR
log "Generating CSR: $clientName"
openssl req -config ../openssl.cnf -new -sha256 \
      -subj "$subj" \
      -key "$key" \
      -out "$csr"

# CA signing Intermediate cert



log "Generating certificate: $clientName"
openssl ca -config ../openssl.cnf -extensions $ext \
      -days 365 -notext -md sha256  -passin pass:$passphrase \
      -in "$csr" \
      -out "$cert"

# You can only read apple.txt, as everyone else.
log "Protecting certificate: $clientName"
chmod 444 $cert

# Intermediate verification
log "Verifiying certificate: $clientName"
openssl x509 -noout -text -in $cert

log "Validating ca-cert: $clientName ca-chain:$pem cert:$cert"
openssl verify -CAfile $pem $cert

log "FINISHED: $intermediateName $clientName"
echo ""
echo ""
cd ..
