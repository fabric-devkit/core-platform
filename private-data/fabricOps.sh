#!/bin/bash

ARGS_NUMBER="$#"
COMMAND="$1"
SUBCOMMAND="$2"

# Network
network_subcommand_message="Usage: $0 network artefacts | start | init | upgrade"
network_name="priv_fabric-network"

function createCryptoChannelArtefacts(){
    #docker run --rm -e "GOPATH=/opt/gopath" -e "FABRIC_CFG_PATH=/opt/gopath/src/github.com/hyperledger/fabric" -w="/opt/gopath/src/github.com/hyperledger/fabric" --volume=${PWD}:/opt/gopath/src/github.com/hyperledger/fabric hyperledger/fabric-tools /bin/bash -c '${PWD}/generate-artefacts.sh'
    # Above line was replaced by calling the script locally, as when run in the docker container, *_sh end up 
    # owned by root and cannot be moved
    ./generate-artefacts.sh

    pushd ./crypto-config/peerOrganizations/org1.priv/ca
        PK=$(ls *_sk)
        mv $PK secret.key
    popd
    pushd ./crypto-config/peerOrganizations/org2.priv/ca
        PK=$(ls *_sk)
        mv $PK secret.key
    popd

    pushd ./crypto-config/peerOrganizations/org1.priv/users/Admin@org1.priv/msp/keystore
        PK=$(ls *_sk)
        mv $PK secret.key
    popd
    pushd ./crypto-config/peerOrganizations/org2.priv/users/Admin@org2.priv/msp/keystore
        PK=$(ls *_sk)
        mv $PK secret.key
    popd

}

function clearContainers(){
    docker rm -f $(docker ps --filter network=$network_name -aq)
}

function clearChaincodeImages(){
    cc_images=$( docker images -a | awk '/priv-*/ {print $3}' )
    docker rmi -f $cc_images
}

function clearCryptoChannelArtefacts(){
    rm -rf ./channel-artefacts
    rm -rf ./crypto-config
}

function clearCAArtefacts(){
    rm -rf ./fabric-ca-home
}

function startNetworkContainers(){
    docker-compose -f ./docker-compose.yaml up -d orderer.priv
    docker-compose -f ./docker-compose.yaml up -d ca.org1.priv
    docker-compose -f ./docker-compose.yaml up -d peer0.org1.priv
    docker-compose -f ./docker-compose.yaml up -d cli.org1.priv
    docker-compose -f ./docker-compose.yaml up -d ca.org2.priv
    docker-compose -f ./docker-compose.yaml up -d peer0.org2.priv
    docker-compose -f ./docker-compose.yaml up -d cli.org2.priv
}

function initializeNetwork(){
    docker exec cli.org1.priv /bin/bash -c '${PWD}/scripts/channelOps.sh'
    docker exec cli.org1.priv /bin/bash -c '${PWD}/scripts/installCC.sh'
    docker exec cli.org1.priv /bin/bash -c '${PWD}/scripts/instantiateCC.sh'

    docker exec cli.org2.priv /bin/bash -c '${PWD}/scripts/joinChannel.sh'
    docker exec cli.org2.priv /bin/bash -c '${PWD}/scripts/installCC.sh'
}

function addSampleTransaction(){
    docker exec cli.org1.priv /bin/bash -c '${PWD}/scripts/addTransaction.sh productA 1234 70 60'
}

function readTransaction(){
    echo '############### Querying on org1 ###############'
    docker exec cli.org1.priv /bin/bash -c '${PWD}/scripts/readTransaction.sh productA'
    echo '############### Querying on org2 ###############'
    docker exec cli.org2.priv /bin/bash -c '${PWD}/scripts/readTransaction.sh productA'
}

function readTransactionPrivate(){
    echo '############### Querying on org1 ###############'
    docker exec cli.org1.priv /bin/bash -c '${PWD}/scripts/readTransactionPrivate.sh productA'
    echo '############### Querying on org2 ###############'
    docker exec cli.org2.priv /bin/bash -c '${PWD}/scripts/readTransactionPrivate.sh productA'
}

function upgradeNetwork(){
    docker exec cli.org1.priv /bin/bash -c '${PWD}/scripts/upgradeCC.sh'
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
        "addSampleTransaction")
            addSampleTransaction
            ;;
        "readTransaction")
            readTransaction
            ;;
        "readTransactionPrivate")
            readTransactionPrivate
            ;;
        *)
            echo $network_subcommand_message
            ;;
    esac
}

# CA Client
ca_client_image="workingwithblockchain/ca-client-toolkit"
ca_client_container="ca.client.org1.priv"
ca_client_subcommand_message="Usage: $0 ca-client image | cli | start | clean"

function buildImageCAClient(){
    pushd ../../extensions/fabric-ca-client
        docker build -t $ca_client_image .
    popd
}

function startCAClient(){
    docker-compose -f ./docker-compose.yaml -f ./docker-compose.ca-client.yaml up -d $ca_client_container
}

function cliCAClient(){
    docker exec -it $ca_client_container /bin/bash
}

function existsCAClientImage(){
    result=$(docker images $ca_client_image --format "{{.ID}}")
    if [ -z $result ]; then
        return 1
    else
        return 0
    fi
}

function clearCAClientContainer(){
    docker rm -f $ca_client_container
}

function clearCAClientImage(){
    docker rmi -f $ca_client_image
}

function caClient(){
    local subcommand="$1"
    case $subcommand in
        "image")
            clearCAClientContainer
            clearCAClientImage
            buildImageCAClient
            ;;
        "start")
            clearCAClientContainer
            existsCAClientImage
            if [ "$?" -ne 0 ]; then
                buildImageCAClient
            fi
            startCAClient
            ;;
        "cli")
            cliCAClient
            ;;
        "clean")
            clearCAClientContainer
            clearCAClientImage
            ;;
        *)
            echo $ca_client_subcommand_message
            ;;
    esac
} 

# Fabric Client
fabric_client_message="Usage: $0 fabric-client image | start | e2e | clean"
fabric_client_image="workingwithblockchain/fabric-client"
fabric_client_container="fabric-client.org1.priv"

#######################################################
# Modify these functions to suit your implementation. #
#######################################################
function buildFabricClientImage(){
    pushd ../../extensions/fabric-node-client # modify this to the location of your client implementation
        docker build -t $fabric_client_image .  
    popd
}

########################################################

function startFabricClient(){
    docker-compose -f ./docker-compose.yaml -f ./docker-compose.fabric-client.yaml up -d $fabric_client_container
}

function existsFabricClientImage(){
    local result=$(docker images $fabric_client_image --format "{{.ID}}")
    if [ -z $result ]; then
        return 1
    else
        return 0
    fi
}

function cleanFabricClientContainer(){
    docker rm -f $fabric_client_container
    rm -rf ../../extensions/fabric-node-client/wallet
}

function cleanFabricClientImage(){
    docker rmi -f $fabric_client_image
}

function fabricClient(){
    local subcommand="$1"
    case $subcommand in
        "image")
            cleanFabricClientContainer
            cleanFabricClientImage
            buildFabricClientImage
            ;;
        "start")
            cleanFabricClientContainer
            existsFabricClientImage
            if [ "$?" -ne 0 ]; then
                buildFabricClientImage
            fi
            unitTestFabricClient
            if [ "$?" -ne 0 ]; then
                echo "Unit test failed - unable to start Fabric Client"
                exit 1
            fi
            smokeTestFabricClient
            if [ "$?" -ne 0 ]; then
                echo "Smoke failed - unable to start Fabric Client"
                exit 1
            fi
            startFabricClient
            ;;
        "e2e")
            e2eTestFabricClient
            ;;    
        "clean")
            cleanFabricClientContainer
            cleanFabricClientImage
            ;;
        *)
            echo $fabric_client_message
            ;;
    esac
}

# Org2
add_org2_message="Usage: $0 add-org2 artefacts | join | validate "
org1_cli="cli.org1.priv"
org2_cli="cli.org2.priv"

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
        if [ -d ./crypto-config/peerOrganizations/org2.priv ]; then
            rm -rf ./crypto-config/peerOrganizations/org2.priv
        fi

        cp -r ./org2/crypto-config/peerOrganizations/org2.priv ./crypto-config/peerOrganizations/org2.priv
        rm -rf ./org2/crypto-config

        pushd ./crypto-config/peerOrganizations/org2.priv/ca
            PK=$(ls *_sk)
            mv $PK secret.key
        popd
    fi

}

# Fabric Ops
fabric_usage_message="Usage: $0 network <subcommand> | ca-client <subcommand> | fabric-client <subcommand> | add-org2 <subcommand> | status | clean"

function fabricOpsStatus(){
    docker ps -a --filter network=$network_name
}

function fabricOpsClean(){
    clearContainers
    clearChaincodeImages
    clearCryptoChannelArtefacts
    clearCAArtefacts
    caClient clean
    fabricClient clean
    docker rmi -f $(docker images -f "dangling=true" -q)
}

case $COMMAND in
    "network")
        network $SUBCOMMAND
        ;;
    "ca-client")
        caClient $SUBCOMMAND
        ;;
    "fabric-client")
        fabricClient $SUBCOMMAND
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
        echo $fabric_usage_message
        ;;
esac