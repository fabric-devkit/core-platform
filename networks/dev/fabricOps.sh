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

function clearCAArtefacts(){
    rm -rf ./fabric-ca-home
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

# CA Client
ca_client_image="workingwithblockchain/ca-client-toolkit"
ca_client_container="ca.client.org1.dev"
ca_client_subcommand_message="Usage: $0 ca-client image | cli | start | clean"

function buildImageCAClient(){
    pushd ../../extensions/fabric-ca-client
        docker build -t $ca_client_image .
    popd
}

function startCAClient(){
    docker-compose -f ./docker-compose.fabric.yaml -f ./docker-compose.ca-client.yaml up -d $ca_client_container
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
fabric_client_container="fabric-client.org1.dev"

#######################################################
# Modify these functions to suit your implementation. #
#######################################################
function buildFabricClientImage(){
    pushd ../../extensions/fabric-node-client # modify this to the location of your client implementation
        docker build -t $fabric_client_image .  
    popd
}

# This unit test is defaulted to node based client. Modify to suit your implementation language. 
function unitTestFabricClient(){
    echo "Fabric client unit testing"
    docker-compose -f ./docker-compose.fabric.yaml -f ./docker-compose.fabric-client.yaml run --rm $fabric_client_container /bin/bash -c 'npm run unit:test'
    return $?
}

# This smoke test is defaulted to node based client. Modify to suit your implementation language. 
function smokeTestFabricClient(){
    echo "Fabric client smoke testing"
    docker-compose -f ./docker-compose.fabric.yaml -f ./docker-compose.fabric-client.yaml run --rm $fabric_client_container /bin/bash -c 'npm run smoke:test'
    return $?
}

function e2eTestFabricClient(){
    echo "Fabric client e2e testing"
    docker-compose -f ./docker-compose.fabric.yaml -f ./docker-compose.fabric-client.yaml run --rm $fabric_client_container /bin/bash -c 'npm run e2e:test'
    return $?
}
########################################################

function startFabricClient(){
    docker-compose -f ./docker-compose.fabric.yaml -f ./docker-compose.fabric-client.yaml up -d $fabric_client_container
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
            echo $add_org2_message
            ;;
    esac
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