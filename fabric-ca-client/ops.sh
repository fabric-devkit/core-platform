#!/bin/bash

COMMAND=$1


function start(){
    docker-compose -f ./docker-compose.yaml build ca-client.test
    docker-compose -f ./docker-compose.yaml up -d tlsca.org1.dev
    docker-compose -f ./docker-compose.yaml run ca-client.test /bin/bash
}

function stop(){
    docker-compose -f ./docker-compose.yaml down tlsca.org1.dev 
}

function clean(){
    rm -rf ./fabric-ca-server
    docker rmi -f fabric-devkit/ca-client.test
    docker rm -f $(docker ps -aq)
}

case "$COMMAND" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    clean)
        clean
        ;;
    *)
        echo "$0 [start | stop | clean]"
        ;;
esac

