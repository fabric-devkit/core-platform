#!/bin/bash

. ./scripts/common.sh

peer channel fetch 0 $CHANNEL_NAME.block -o $ORDERER -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
peer channel join -o $ORDERER -b ./$CHANNEL_NAME.block --tls --cafile $ORDERER_CA
peer channel update -o $ORDERER -c $CHANNEL_NAME -f ./channel-artefacts/Org2MSPanchors_${CHANNEL_NAME}.tx --tls --cafile $ORDERER_CA