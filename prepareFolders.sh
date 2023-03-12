#!/bin/bash
source ./common.sh

log "Starting folder preparation"

if [ -d "ca" ]; then
  log "CA forder already exists."
else
  log "Setting up CA folder"
  mkdir ca
  mkdir -p ca/certs ca/crl ca/csr ca/newcerts ca/private
  chmod 700 ca/private
fi

if [ -d "intermediate" ]; then
  log "Intermediate forder already exists."
else
  log "Setting up Intermediate folder"
  mkdir intermediate
  mkdir -p intermediate/certs intermediate/crl intermediate/csr intermediate/newcerts intermediate/private
  chmod 700 intermediate/private
  touch intermediate/index.txt
  echo 1000 > intermediate/serial
  echo 1000 > intermediate/crlnumber
fi

log "Folder preparation finished!"