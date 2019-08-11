#!/bin/bash

CHANNEL_ONE_NAME=channelone
CHANNEL_ONE_PROFILE=ChannelOne
CHANNEL_TWO_NAME=channeltwo
CHANNEL_TWO_PROFILE=ChannelTwo

if [ -d ./channel-artefacts ]; then
    rm -rf ./channel-artefacts
fi

if [ -d ./crypto-config ]; then
    rm -rf ./crypto-config
fi

cryptogen generate --config=./crypto-config.yml --output="./crypto-config"

if [ ! -d ./channel-artefacts ]; then
    mkdir -p ./channel-artefacts
fi

configtxgen -profile OrdererGenesis -outputBlock ./channel-artefacts/genesis.block

configtxgen -profile ${CHANNEL_ONE_PROFILE} -outputCreateChannelTx ./channel-artefacts/${CHANNEL_ONE_NAME}.tx -channelID $CHANNEL_ONE_NAME
configtxgen -profile ${CHANNEL_TWO_PROFILE} -outputCreateChannelTx ./channel-artefacts/${CHANNEL_TWO_NAME}.tx -channelID $CHANNEL_TWO_NAME

configtxgen -profile ${CHANNEL_ONE_PROFILE} -outputAnchorPeersUpdate ./channel-artefacts/Org1MSPanchors_${CHANNEL_ONE_NAME}.tx -channelID $CHANNEL_ONE_NAME -asOrg Org1MSP
configtxgen -profile ${CHANNEL_ONE_PROFILE} -outputAnchorPeersUpdate ./channel-artefacts/Org2MSPanchors_${CHANNEL_ONE_NAME}.tx -channelID $CHANNEL_ONE_NAME -asOrg Org2MSP

configtxgen -profile ${CHANNEL_TWO_PROFILE} -outputAnchorPeersUpdate ./channel-artefacts/Org1MSPanchors_${CHANNEL_TWO_NAME}.tx -channelID $CHANNEL_TWO_NAME -asOrg Org1MSP
configtxgen -profile ${CHANNEL_TWO_PROFILE} -outputAnchorPeersUpdate ./channel-artefacts/Org2MSPanchors_${CHANNEL_TWO_NAME}.tx -channelID $CHANNEL_TWO_NAME -asOrg Org2MSP
