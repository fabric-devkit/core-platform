#!/bin/bash

. ./scripts/common.sh

CHAINCODE_CONSTRUCTOR="[\"init\",\"Paul\",\"10\",\"John\",\"20\"]"
constructor="{\"Args\":$CHAINCODE_CONSTRUCTOR}"

peer chaincode instantiate -o $ORDERER -C $CHANNEL_NAME -n $CHAINCODE_NAME -l $CHAINCODE_LANG -v $CHAINCODE_VERSION -c $constructor -P "OR ('Org1MSP.member')" --tls --cafile $ORDERER_CA
