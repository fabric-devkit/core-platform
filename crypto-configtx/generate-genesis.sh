#!/bin/bash

CHANNEL_ONE_NAME=channelone
CHANNEL_ONE_PROFILE=ChannelOne
CHANNEL_TWO_NAME=channeltwo
CHANNEL_TWO_PROFILE=ChannelTwo

if [ ! -d ./assets/crypto-config ]; then
    ./generate-certs.sh
fi

mkdir -p ./assets/channel-artifacts

configtxgen -profile OrdererGenesis -outputBlock ./assets/channel-artifacts/genesis.block -channelID CHANNEL_ONE_NAME
