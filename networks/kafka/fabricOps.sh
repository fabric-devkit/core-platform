#!/bin/bash

ARGS_NUMBER="$#"
COMMAND="$1"
SUBCOMMAND="$2"

network_name="kafka_fabric-network"

# Kafka
kafka_subcommand_message="Usage: $0 kafka start | clean"

function smokeKafka(){
    docker-compose -f ./docker-compose.kafka.yaml exec kafka1.network /bin/bash -c '${PWD}/bin/kafka-topics.sh --create --zookeeper zookeeper1.network:2181 --replication-factor 1 --partitions 1 --topic test'
    docker-compose -f ./docker-compose.kafka.yaml exec kafka1.network /bin/bash -c '${PWD}/bin/kafka-topics.sh --zookeeper zookeeper1.network:2181 --describe --topic test'
    docker-compose -f ./docker-compose.kafka.yaml exec kafka1.network /bin/bash -c '${PWD}/bin/kafka-console-producer.sh --broker-list localhost:9021 --topic test'
}

function startKafka(){
    docker-compose -f ./docker-compose.kafka.yaml up -d zookeeper1.network
    docker-compose -f ./docker-compose.kafka.yaml up -d zookeeper2.network 
    docker-compose -f ./docker-compose.kafka.yaml up -d zookeeper3.network 
    docker-compose -f ./docker-compose.kafka.yaml up -d kafka1.network
    docker-compose -f ./docker-compose.kafka.yaml up -d kafka2.network 
    docker-compose -f ./docker-compose.kafka.yaml up -d kafka3.network 
    docker-compose -f ./docker-compose.kafka.yaml up -d kafka4.network
}

function cleanKafka(){

    docker rm -f zookeeper1.network
    docker rm -f zookeeper2.network 
    docker rm -f zookeeper3.network 
    docker rm -f kafka1.network
    docker rm -f kafka2.network 
    docker rm -f kafka3.network 
    docker rm -f kafka4.network
}

function kafka(){
    local subcommand="$1"
    case $subcommand in
        "start")
            startKafka
            #smokeKafka
            ;;
        "clean")
            cleanKafka
            ;;
        *)
            echo $kafka_subcommand_message
            ;;
    esac
}

# network
function createCryptoChannelArtefacts(){
    rm -rf ./channel-artefacts
    rm -rf ./crypto-config
    docker run --rm -e "GOPATH=/opt/gopath" -e "FABRIC_CFG_PATH=/opt/gopath/src/github.com/hyperledger/fabric" -w="/opt/gopath/src/github.com/hyperledger/fabric" --volume=${PWD}:/opt/gopath/src/github.com/hyperledger/fabric hyperledger/fabric-tools /bin/bash -c '${PWD}/generate-artefacts.sh'
}

function renameSecretPrivKeys(){
    pushd ./crypto-config/peerOrganizations/org1.kafka.network/ca
        PK=$(ls *_sk)
        mv $PK secret.key
    popd

    pushd ./crypto-config/peerOrganizations/org2.kafka.network/ca
        PK=$(ls *_sk)
        mv $PK secret.key
    popd

    pushd ./crypto-config/peerOrganizations/org1.kafka.network/users/Admin@org1.kafka.network/msp/keystore
        PK=$(ls *_sk)
        mv $PK secret.key
    popd

    pushd ./crypto-config/peerOrganizations/org2.kafka.network/users/Admin@org2.kafka.network/msp/keystore
        PK=$(ls *_sk)
        mv $PK secret.key
    popd
}

function startFabric(){
    docker-compose -f ./docker-compose.kafka.yaml -f ./docker-compose.fabric.yaml up -d
}

function createChannel(){
    docker exec cli.org1.kafka.network /bin/bash -c '${PWD}/scripts/channelOps.sh'
    docker exec cli.org2.kafka.network /bin/bash -c '${PWD}/scripts/channelOps.sh'
}

function installChaincode(){
    docker exec cli.org1.kafka.network /bin/bash -c '${PWD}/scripts/installCC.sh'
    docker exec cli.org2.kafka.network /bin/bash -c '${PWD}/scripts/installCC.sh'
}

function instantiateChaincode(){
    docker exec cli.org1.kafka.network /bin/bash -c '${PWD}/scripts/instantiateCC.sh'
}

function clearCryptoChannelArtefacts(){
    rm -rf ./channel-artefacts
    rm -rf ./crypto-config
}

function clearContainers(){
    containers=$( docker ps -aq --filter network=$network_name)
    docker rm -f $containers
}

network_subcommand_message="Usage: $0 network start | configure | clean"
function network(){
    local subcommand="$1"
    case $subcommand in
        "start")
            clearCryptoChannelArtefacts
            clearContainers
            createCryptoChannelArtefacts
            renameSecretPrivKeys
            startFabric
            ;;
        "configure")
            createChannel
            installChaincode
            instantiateChaincode
            ;;
        "clean")
            clearCryptoChannelArtefacts
            clearContainers
            ;;
        *)
            echo $network_subcommand_message
            ;;
    esac 
}

# Status
function status(){

    echo "------------------------------------"
    echo "--       Running containers       --"
    echo "------------------------------------"
    docker ps --filter status=running
    echo

    echo "------------------------------------"
    echo "--       Stopped containers       --"
    echo "------------------------------------"
    docker ps --filter status=exited
}

# FabricOps.sh
usage_message="Usage: $0 kafka <subcommand> | network <subcommand> | status | clean "

case $COMMAND in
    "kafka")
        kafka $SUBCOMMAND 
        ;;
    "network")
        network $SUBCOMMAND
        ;;
    "status")
        status
        ;;
    "clean")
        kafka clean
        network clean
        ;;				
    *)
        echo $usage_message
        exit 1
esac