#!/bin/bash

. ./scripts/common.sh

peer channel update -f ./channel-artefacts/Org2MSPanchors_$CHANNEL_NAME.tx -c $CHANNEL_NAME -o $ORDERER --tls --cafile $ORDERER_CA

peer channel fetch 0 -o $ORDERER -c $CHANNEL_NAME --tls --cafile $ORDERER_CA ./$CHANNEL_NAME.block
peer channel join -o $ORDERER -b $CHANNEL_NAME-genesis.block --tls --cafile $ORDERER_CA
