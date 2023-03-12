#!/bin/bash

passphrase=1111
scriptname=$0

log(){
      n=$(date +'%Y-%m-%d %H:%M:%S')
      args=("$@") 
      echo "$n $args"
}


trap ctrl_c INT

function ctrl_c() {
      echo ""
      echo ""
      log "ABORTED: $scriptname"
      echo ""
      exit -1
}

