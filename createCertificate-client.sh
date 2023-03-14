#!/bin/bash
source ./common.sh

# script input parameters
caName="${1:-default}"
intermediateName="${2:-department}"
clientName="${3:-client}"

# folder definitions
caFolder="ca-$caName"
intermediateSubFolder="intermediate-$intermediateName"
intermediateFolder="$caFolder/$intermediateSubFolder"

# key, csr and certificate paths
key="$intermediateSubFolder/private/$intermediateName-$clientName.key"
csr="$intermediateSubFolder/csr/$intermediateName-$clientName.csr"
cert="$intermediateSubFolder/certs/$intermediateName-$clientName.cert"
pem="$intermediateSubFolder/certs/ca-chain-intermediate.pem"

# openssl extra configuration
subj="/C=GB/ST=England/O=$caName Ltd/CN=$clientName/emailAddress=$clientName@$caName.org"
ext="usr_cert"

log "STARTING: $intermediateName $clientName"
cd $caFolder

# Key
log "Generating key: $clientName"
openssl genrsa -out $key 2048
log "Protecting key: $clientName"
chmod 400 $key #It means to protect a file against the accidental overwriting, removing, renaming or moving files.

# CSR
log "Generating CSR: $clientName"
openssl req -config $intermediateSubFolder/openssl.cnf -new -sha256 \
      -subj "$subj" \
      -key "$key" \
      -out "$csr"

# CA signing Intermediate cert
log "Generating certificate: $clientName"
openssl ca -config $intermediateSubFolder/openssl.cnf -extensions $ext \
      -days 365 -notext -md sha256  -passin pass:$passphrase \
      -in "$csr" \
      -out "$cert"

log "Protecting certificate: $clientName"
chmod 444 $cert # You can only read $clientName as everyone else.

# Intermediate verification
log "Verifiying certificate: openssl x509 -noout -text -in $cert"
openssl x509 -noout -text -in $cert

log "Validating ca-cert: openssl verify -CAfile $pem $cert"
openssl verify -CAfile $pem $cert

log "FINISHED: $intermediateName $clientName"
echo ""
echo ""
cd ..
