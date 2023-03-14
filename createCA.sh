#!/bin/bash
source ./common.sh

# script input parameters
caName="${1:-default}"


# folder definitions
caFolder="ca-$caName"

#folder creation
mkdir -p $caFolder/certs 
mkdir -p $caFolder/crl 
mkdir -p $caFolder/newcerts 
mkdir -p $caFolder/private
chmod 700 $caFolder/private

# openssl files
touch $caFolder/index.txt
echo 1000 > $caFolder/serial
echo 1000 > $caFolder/crlnumber

# openssl extra configuration
log "Configuring CA openssl.cnf"
dir=$(pwd)
dirscaped=$(echo "$dir/$caFolder" | sed 's/\//\\\//g')
sed -e "s/ROOTDIR/$dirscaped/" openssl-ca.cnf  > $caFolder/openssl.cnf

subj="/C=GB/ST=England/O=$caName Ltd/CN=$caName.ltd/emailAddress=support@$caName.org"

# key and cert paths
key="private/ca.key"
cert="certs/ca.cert"

log "STARTING: $caName"
cd $caFolder


# Key
log "Generating key: CA"
openssl genrsa -aes256 -passout pass:$passphrase -out $key 4096
log "Protecting key: CA"
chmod 400 $key

# Certificate
log "Generating certificate: CA"
openssl req -config openssl.cnf \
      -subj "$subj" \
      -key "$key" -passin pass:$passphrase  \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -out "$cert"

log "Protecting certificate: CA"
chmod 444 $cert

# Verification
log "Verifiying certificate: openssl x509 -noout -text -in $cert"
openssl x509 -noout -text -in $cert

log "FINISHED: $caName"
cd ..
