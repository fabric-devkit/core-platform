#!/bin/bash

if [ -d ./crypto-config ]; then
    rm -rf ./crypto-config
fi

cryptogen generate --config=./org2-crypto.yaml --output="./crypto-config"

if [ -d ./channel-artefacts ]; then
    rm -rf ./
fi

mkdir ./channel-artefacts
configtxgen -printOrg Org2MSP > ./channel-artefacts/org2.json
