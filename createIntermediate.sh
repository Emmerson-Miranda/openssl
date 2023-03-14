#!/bin/bash
source ./common.sh

# script input parameters
caName="${1:-default}"
intermediateName="${2:-intermediate}"

# folder definitions
caFolder="ca-$caName"
intermediateSubFolder="intermediate-$intermediateName"
intermediateFolder="$caFolder/$intermediateSubFolder"

#folder creation
mkdir -p $intermediateFolder/certs
mkdir -p $intermediateFolder/crl
mkdir -p $intermediateFolder/csr
mkdir -p $intermediateFolder/newcerts
mkdir -p $intermediateFolder/private
chmod 700 $intermediateFolder/private

# openssl files
touch $intermediateFolder/index.txt
echo 1000 > $intermediateFolder/serial
echo 1000 > $intermediateFolder/crlnumber

# key, csr and certificate paths
key="$intermediateSubFolder/private/intermediate.key"
csr="$intermediateSubFolder/csr/intermediate.csr"
cert="$intermediateSubFolder/certs/intermediate.cert"
pem="$intermediateSubFolder/certs/ca-chain-intermediate.pem"

# openssl extra configuration
log "Configuring Intermediate openssl.cnf"
dir=$(pwd)
dirscaped=$(echo "$dir/$intermediateFolder/" | sed 's/\//\\\//g')
sed -e "s/ROOTDIR/$dirscaped/" openssl-intermediate.cnf  > $intermediateFolder/openssl.cnf

subj="/C=GB/ST=England/O=$caName Ltd/CN=$intermediateName.$caName.ltd/emailAddress=$intermediateName@$caName.org"
ext="v3_intermediate_ca"

log "STARTING: $intermediateName"
cd $caFolder

# Key
log "Generating key: $intermediateName"
openssl genrsa -aes256 -passout pass:$passphrase -out $key 4096
log "Protecting key: $intermediateName"
chmod 400 $key #It means to protect a file against the accidental overwriting, removing, renaming or moving files.

# CSR
log "Generating CSR: $intermediateName"
openssl req -config openssl.cnf -new -sha256 -passin pass:$passphrase \
      -subj "$subj" \
      -key $key \
      -out $csr

# CA signing Intermediate cert
log "Changing to CA folder"
cd ../$caFolder

log "Generating certificate: $intermediateName"
openssl ca -config openssl.cnf -extensions $ext \
      -days 3650 -notext -md sha256  -passin pass:$passphrase \
      -in "$csr" \
      -out $cert

# You can only read $cert, as everyone else.
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

