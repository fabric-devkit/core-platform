#!/bin/bash

. ./share/common.sh

peer channel create -o $ORDERER -c $CHANNEL_ONE_NAME -f ./channel-artefacts/$CHANNEL_ONE_NAME.tx --tls --cafile $ORDERER_CA
peer channel join -o $ORDERER -b ./$CHANNEL_ONE_NAME.block --tls --cafile $ORDERER_CA

peer channel create -o $ORDERER -c $CHANNEL_TWO_NAME -f ./channel-artefacts/$CHANNEL_TWO_NAME.tx --tls --cafile $ORDERER_CA
peer channel join -o $ORDERER -b ./$CHANNEL_TWO_NAME.block --tls --cafile $ORDERER_CA
