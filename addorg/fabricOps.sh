#!/bin/bash

ARGS_NUMBER="$#"
COMMAND="$1"
SUBCOMMAND="$2"

# Network
network_subcommand_message="Usage: $0 network artefacts | start | init | upgrade"
network_name="dev_fabric-network"

function createCryptoChannelArtefacts(){
    docker run --rm -e "GOPATH=/opt/gopath" -e "FABRIC_CFG_PATH=/opt/gopath/src/github.com/hyperledger/fabric" -w="/opt/gopath/src/github.com/hyperledger/fabric" --volume=${PWD}:/opt/gopath/src/github.com/hyperledger/fabric hyperledger/fabric-tools /bin/bash -c '${PWD}/generate-artefacts.sh'

    pushd ./crypto-config/peerOrganizations/org1.dev/ca
        PK=$(ls *_sk)
        mv $PK secret.key
    popd

    pushd ./crypto-config/peerOrganizations/org1.dev/users/Admin@org1.dev/msp/keystore
        PK=$(ls *_sk)
        mv $PK secret.key
    popd

}

function clearContainers(){
    docker rm -f $(docker ps --filter network=$network_name -aq)
}

function clearChaincodeImages(){
    cc_images=$( docker images -a | awk '/dev-*/ {print $3}' )
    docker rmi -f $cc_images
}

function clearCryptoChannelArtefacts(){
    rm -rf ./channel-artefacts
    rm -rf ./crypto-config
}

function startNetworkContainers(){
    docker-compose -f ./docker-compose.fabric.yaml up -d orderer.dev
    docker-compose -f ./docker-compose.fabric.yaml up -d ca.org1.dev
    docker-compose -f ./docker-compose.fabric.yaml up -d peer0.org1.dev
    docker-compose -f ./docker-compose.fabric.yaml up -d cli.org1.dev
}

function initializeNetwork(){
    docker exec cli.org1.dev /bin/bash -c '${PWD}/scripts/channelOps.sh'
    docker exec cli.org1.dev /bin/bash -c '${PWD}/scripts/installCC.sh'
    docker exec cli.org1.dev /bin/bash -c '${PWD}/scripts/instantiateCC.sh'
}

function upgradeNetwork(){
    docker exec cli.org1.dev /bin/bash -c '${PWD}/scripts/upgradeCC.sh'
}

function network(){
    local subcommand="$1"
    case $subcommand in
        "artefacts")
            clearCryptoChannelArtefacts
            createCryptoChannelArtefacts
            ;;
        "start")
            clearContainers
            startNetworkContainers
            ;;
        "init")
            initializeNetwork
            ;;
        "upgrade")
            upgradeNetwork
            ;;
        *)
            echo $network_subcommand_message
            ;;
    esac
}

# Org2
org1_cli="cli.org1.dev"
org2_cli="cli.org2.dev"

function org2Artefacts(){

    pushd ./org2
        docker run --rm \
        -e "GOPATH=/opt/gopath" \
        -e "FABRIC_CFG_PATH=/opt/gopath/src/github.com/hyperledger/fabric" \
        -w="/opt/gopath/src/github.com/hyperledger/fabric" \
        --volume=${PWD}:/opt/gopath/src/github.com/hyperledger/fabric \
        hyperledger/fabric-tools \
        /bin/bash -c '${PWD}/generate-artefacts.sh'
    popd

    if [[ -f ./org2/channel-artefacts/org2.json && -d ./channel-artefacts ]]; then
        if [ -f ./channel-artefacts/org2.json ]; then
            rm -f ./channel-artefacts/org2.json
        fi
        mv org2/channel-artefacts/org2.json ./channel-artefacts
        rm -rf org2/channel-artefacts
    fi

    if [[ -d ./org2/crypto-config/peerOrganizations && -d ./crypto-config ]]; then
        if [ -d ./crypto-config/peerOrganizations/org2.dev ]; then
            rm -rf ./crypto-config/peerOrganizations/org2.dev
        fi

        cp -r ./org2/crypto-config/peerOrganizations/org2.dev ./crypto-config/peerOrganizations/org2.dev
        rm -rf ./org2/crypto-config

        pushd ./crypto-config/peerOrganizations/org2.dev/ca
            PK=$(ls *_sk)
            mv $PK secret.key
        popd
    fi

}

function joinOrg2(){
    docker-compose -f ./docker-compose.fabric.yaml -f ./docker-compose.org2.yaml up -d peer0.org2.dev
    docker-compose -f ./docker-compose.fabric.yaml -f ./docker-compose.org2.yaml up -d cli.org2.dev
    docker-compose -f ./docker-compose.fabric.yaml -f ./docker-compose.org2.yaml run --rm $org1_cli /bin/bash -c '${PWD}/scripts/step1AddOrg2.sh'
    docker-compose -f ./docker-compose.fabric.yaml -f ./docker-compose.org2.yaml run --rm $org2_cli /bin/bash -c '${PWD}/scripts/step2AddOrg2.sh'
}

function validateOrg2(){
    docker-compose -f ./docker-compose.fabric.yaml -f ./docker-compose.org2.yaml run --rm $org2_cli /bin/bash -c '${PWD}/scripts/org2Validate.sh'
}

function addOrg2(){
    local subcommand="$1"
    case $subcommand in
        "artefacts")
            org2Artefacts
            ;;
        "join")
            joinOrg2
            ;;
        "validate")
            validateOrg2
            ;;
        *)
            echo "Usage: $0 add-org2 artefacts | join | validate "
            ;;
    esac
}

# Fabric Ops
function fabricOpsStatus(){
    docker ps -a --filter network=$network_name
}

function fabricOpsClean(){
    clearContainers
    clearChaincodeImages
    clearCryptoChannelArtefacts
    fabricClient clean
    docker rmi -f $(docker images -f "dangling=true" -q)
}

case $COMMAND in
    "network")
        network $SUBCOMMAND
        ;;
    "status")
        fabricOpsStatus
        ;;
    "clean")
        fabricOpsClean
        ;;
    "add-org2")
        addOrg2 $SUBCOMMAND
        ;;
    *)
        echo "Usage: $0 network <subcommand> | add-org2 <subcommand> | status | clean"
        ;;
esac