#!/bin//bash

ARGS_NUMBER="$#"
COMMAND="$1"
SUBCOMMAND="$2"

export COMPOSE_PROJECT_NAME=twoorg-dev
export CA_IMAGE_TAG=1.4.0
export PEER_IMAGE_TAG=1.4.0
export ORDERER_IMAGE_TAG=1.4.0
export FABRIC_TOOL_IMAGE_TAG=1.4
export COUCHDB_IMAGE_TAG=0.4.8
export CHAINCODE_PATH=../chaincodes/
export CHANNEL_NAME=mychannel

network_name="${COMPOSE_PROJECT_NAME}_fabric-network"

# Crypto and channel assets
function createCryptoChannelArtefacts(){

    docker run --rm \
               -e "GOPATH=/opt/gopath" \
               -e "FABRIC_CFG_PATH=/opt/gopath/src/github.com/hyperledger/fabric" \
               -w="/opt/gopath/src/github.com/hyperledger/fabric" \
               --volume=${PWD}:/opt/gopath/src/github.com/hyperledger/fabric \
               hyperledger/fabric-tools:${FABRIC_TOOL_IMAGE_TAG} /bin/bash -c '${PWD}/generate-artefacts.sh'

    pushd ./crypto-config/peerOrganizations/org1.fabric.network/ca
        PK=$(ls *_sk)
        mv $PK secret.key
    popd

    pushd ./crypto-config/peerOrganizations/org1.fabric.network/users/Admin@org1.fabric.network/msp/keystore
        PK=$(ls *_sk)
        mv $PK secret.key
    popd

    pushd ./crypto-config/peerOrganizations/org2.fabric.network/ca
        PK=$(ls *_sk)
        mv $PK secret.key
    popd

    pushd ./crypto-config/peerOrganizations/org2.fabric.network/users/Admin@org2.fabric.network/msp/keystore
        PK=$(ls *_sk)
        mv $PK secret.key
    popd

}

# Network ops
function startNetworkContainers(){
    docker-compose up -d
}

# Global ops
function networkStatus(){
    docker ps -a --filter network=$network_name
}

# Clean
function clearCryptoChannelAssets(){
    if [ -d ./channel-artefacts ]; then
        rm -rf ./channel-artefacts;
    fi

    if [ -d ./crypto-config ]; then
        rm -rf ./crypto-config
    fi
}

function clean(){
    clearCryptoChannelAssets
    docker rm -f $(docker ps --filter network=$network_name -aq)
}

function cli(){
    local subcmd=$1
    case $subcmd in
        "org1")
            docker exec -it cli.peer0.org1.fabric.network /bin/bash
            ;;
        "org2")
            docker exec -it cli.peer0.org2.fabric.network /bin/bash
            ;;
        *)
            echo "Usage: fabicOps.sh cli [org1 | org2]"
            ;;
    esac
}

case $COMMAND in
    "start")
        clearCryptoChannelAssets
        createCryptoChannelArtefacts
        startNetworkContainers
        ;;
    "cli")
        cli $SUBCOMMAND
        ;;
    "status")
        networkStatus
        ;;
    "clean")
        clean
        ;;
    *)
        echo "Usage: $0 [ start | cli | status | clean ]"
        ;;
esac
