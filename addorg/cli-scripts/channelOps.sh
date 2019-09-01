#!/bin/bash

. ./scripts/common.sh

peer channel create -o $ORDERER -c $CHANNEL_NAME -f ./channel-artefacts/$CHANNEL_NAME.tx --tls --cafile $ORDERER_CA
peer channel update -f ./channel-artefacts/Org1MSPanchors_$CHANNEL_NAME.tx -c $CHANNEL_NAME -o $ORDERER --tls --cafile $ORDERER_CA
peer channel join -o $ORDERER -b ./$CHANNEL_NAME.block --tls --cafile $ORDERER_CA

