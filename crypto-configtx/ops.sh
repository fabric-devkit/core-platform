#!/bin/bash

CLI_NAME="$0"
COMMAND="$1"

FABRIC_TOOL_VERSION=1.4.1

function shell(){
    docker run -it --rm -e "GOPATH=/opt/gopath" \
                -e "FABRIC_CFG_PATH=/opt/gopath/src/github.com/hyperledger/fabric" \
                -w="/opt/gopath/src/github.com/hyperledger/fabric" \
                --volume=${PWD}:/opt/gopath/src/github.com/hyperledger/fabric \
                hyperledger/fabric-tools:$FABRIC_TOOL_VERSION /bin/bash
}

function cert(){
    docker run -it --rm -e "GOPATH=/opt/gopath" \
                -e "FABRIC_CFG_PATH=/opt/gopath/src/github.com/hyperledger/fabric" \
                -w="/opt/gopath/src/github.com/hyperledger/fabric" \
                --volume=${PWD}:/opt/gopath/src/github.com/hyperledger/fabric \
                hyperledger/fabric-tools:$FABRIC_TOOL_VERSION /bin/bash -c "./generate-certs.sh"
}

function genesis(){
    docker run -it --rm -e "GOPATH=/opt/gopath" \
                -e "FABRIC_CFG_PATH=/opt/gopath/src/github.com/hyperledger/fabric" \
                -w="/opt/gopath/src/github.com/hyperledger/fabric" \
                --volume=${PWD}:/opt/gopath/src/github.com/hyperledger/fabric \
                hyperledger/fabric-tools:$FABRIC_TOOL_VERSION /bin/bash -c "./generate-genesis.sh"
}

function channel(){
    docker run -it --rm -e "GOPATH=/opt/gopath" \
                -e "FABRIC_CFG_PATH=/opt/gopath/src/github.com/hyperledger/fabric" \
                -w="/opt/gopath/src/github.com/hyperledger/fabric" \
                --volume=${PWD}:/opt/gopath/src/github.com/hyperledger/fabric \
                hyperledger/fabric-tools:$FABRIC_TOOL_VERSION /bin/bash -c "./generate-channel.sh"
}

case $COMMAND in
    cert)
        cert
        ;;
    genesis)
        genesis
        ;;
    channel)
        channel
        ;;
    shell)
        shell
        ;;
    clean)
        rm -rf ./assets
        ;;
    *)
        echo "Usage: ${CLI_NAME} [ shell | clean ]"
        ;;
esac