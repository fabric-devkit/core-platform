#!/bin/bash

CHANNEL_NAME=mychannel
CHANNEL_PROFILE=MyChannel
ORDERERGENESYS_PROFILE=OrdererGenesis

if [ -d ./channel-artefacts ]; then
    rm -rf ./channel-artefacts
fi

if [ -d ./crypto-config ]; then
    rm -rf ./crypto-config
fi

cryptogen generate --config=./crypto-config.yaml --output="./crypto-config"

if [ ! -d ./channel-artefacts ]; then
    mkdir -p ./channel-artefacts
fi

configtxgen -profile ${ORDERERGENESYS_PROFILE} -outputBlock ./channel-artefacts/${CHANNEL_NAME}-genesis.block
configtxgen -profile ${CHANNEL_PROFILE} -outputCreateChannelTx ./channel-artefacts/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME
configtxgen -profile ${CHANNEL_PROFILE} -outputAnchorPeersUpdate ./channel-artefacts/Org1MSPanchors_${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
