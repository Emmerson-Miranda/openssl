#!/bin/bash
# based on https://jamielinux.com/docs/openssl-certificate-authority/sign-server-and-client-certificates.html
source ./common.sh

intermediateName="${1:-intermediate}"
serverName="${2:-server}"

cd ca

key="../intermediate/private/$intermediateName-$serverName.key"
csr="../intermediate/csr/$intermediateName-$serverName.csr"
cert="../intermediate/certs/$intermediateName-$serverName.cert"
pem="../intermediate/certs/ca-chain-$intermediateName.pem"
subj="/C=GB/ST=England/O=Pachamama Ltd/CN=$serverName.pachamama.org/emailAddress=$serverName@pachamama.org"

log "STARTING: $intermediateName $serverName"

# Key
# https://www.openssl.org/docs/man3.0/man1/openssl-genrsa.html
log "Generating key: $serverName"
openssl genrsa -out $key 2048
#It means to protect a file against the accidental overwriting, removing, renaming or moving files.
log "Protecting key: $serverName"
chmod 400 $key

# CSR
log "Generating CSR: $serverName"
openssl req -config ../openssl.cnf -new -sha256 \
      -subj "$subj" \
      -key "$key" \
      -out "$csr"

# CA signing Intermediate cert



log "Generating certificate: $serverName"
openssl ca -config ../openssl.cnf -extensions server_cert \
      -days 365 -notext -md sha256  -passin pass:$passphrase \
      -in "$csr" \
      -out "$cert"

# You can only read apple.txt, as everyone else.
log "Protecting certificate: $serverName"
chmod 444 $cert

# Intermediate verification
log "Verifiying certificate: $serverName"
openssl x509 -noout -text -in $cert
log "Validating ca-cert: $serverName ca-chain:$pem cert:$cert"
openssl verify -CAfile $pem $cert

log "FINISHED: $intermediateName $serverName"
echo ""
echo ""
cd ..
