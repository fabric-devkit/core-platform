#!/bin//bash

CLI_NAME="$0"
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

    # Download crypto and channel artefact tools
    docker run --rm \
               -e "GOPATH=/opt/gopath" \
               -e "FABRIC_CFG_PATH=/opt/gopath/src/github.com/hyperledger/fabric" \
               -w="/opt/gopath/src/github.com/hyperledger/fabric" \
               --volume=${PWD}:/opt/gopath/src/github.com/hyperledger/fabric \
               hyperledger/fabric-tools:${FABRIC_TOOL_IMAGE_TAG} /bin/bash -c '${PWD}/generate-artefacts.sh'

    # Renaming the secret keys purely for administration purpose and is not 
    # fundamental to the operations of Hyperledger Fabric
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

# Networking ops
function network(){

    if [ ! -d ./crypto-config ]; then
        echo "Missing cryto artefacts"
        exit
    fi

    if [ ! -d ./channel-artefacts ]; then
        echo "Missing channel configuration artefacts"
        exit 1
    fi

    local subcmd=$1
    case $subcmd in
        "start")
            docker-compose up -d
            ;;
        "stop")
            docker-compose down
            ;;
        "status")
            docker ps -a --filter network=$network_name
            ;;
        *)
            echo "$CLI_NAME $COMMAND [start | stop | status]"
            ;;
    esac
}

# Access to Fabric command line tool
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
            echo "Usage: ${CLI_NAME} ${COMMAND} [org1 | org2]"
            ;;
    esac
}

# Access to the chaincode log
function chaincodeLog() {
    local org=$1
    local ccid=$( docker ps -a | grep dev-peer0.$org | awk '/dev-*/ {print $1}')
    if [ ! -z $ccid ]; then
        docker logs $ccid
    fi
}

function log(){
    local subcmd=$1
    case $subcmd in
        org[1-2])
            chaincodeLog $subcmd
            ;;
        *)
            echo "Usage: ${CLI_NAME} ${COMMAND} [org1 | org2]"
            ;; 
    esac
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

function cleanCCImages() {
    local ccImages=$(docker images --filter=reference='dev-*' --format "{{.ID}}")
    docker rmi -f $ccImages
}

function clean(){
    clearCryptoChannelAssets
    docker rm -f $(docker ps --filter network=$network_name -aq)
    cleanCCImages
}

case $COMMAND in
    "artefacts")
        clearCryptoChannelAssets
        createCryptoChannelArtefacts
        ;;
    "chaincode")
        log $SUBCOMMAND
        ;;
    "clean")
        clean
        ;;
    "cli")
        cli $SUBCOMMAND
        ;;
    "network")
        network $SUBCOMMAND
        ;;
    *)
        echo "Usage: ${CLI_NAME} [ artefacts | chaincode | clean | cli | network  ]"
        ;;
esac
