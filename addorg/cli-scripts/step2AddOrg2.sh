#!/bin/bash

echo "=========================="
echo "== STEP 2: Adding Org 2 =="
echo "=========================="

. ./scripts/common.sh

peer channel fetch 0 $CHANNEL_NAME.block -o $ORDERER -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
peer channel join -o $ORDERER -b ./${CHANNEL_NAME}.block --tls --cafile $ORDERER_CA

peer chaincode install -n $CHAINCODE_NAME -l $CHAINCODE_LANG -p $CHAINCODE_SRC -v $CHAINCODE_VERSION