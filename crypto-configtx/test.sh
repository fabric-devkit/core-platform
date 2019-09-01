#!/bin/bash

FABRIC_TOOL_VERSION=latest

rm -rf ./assets

docker run --rm -e "GOPATH=/opt/gopath" \
                -e "FABRIC_CFG_PATH=/opt/gopath/src/github.com/hyperledger/fabric" \
                -w="/opt/gopath/src/github.com/hyperledger/fabric" \
                --volume=${PWD}:/opt/gopath/src/github.com/hyperledger/fabric \
                hyperledger/fabric-tools:$FABRIC_TOOL_VERSION /bin/bash -c '${PWD}/generate-artefacts.sh'
