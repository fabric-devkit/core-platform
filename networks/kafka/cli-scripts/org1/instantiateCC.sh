#!/bin/bash

. ./share/common.sh

CHAINCODE_CONSTRUCTOR="[\"init\",\"Paul\",\"10\",\"John\",\"20\"]"
constructor="{\"Args\":$CHAINCODE_CONSTRUCTOR}"

peer chaincode instantiate -o $ORDERER -C $CHANNEL_ONE_NAME -n $CHAINCODE_ONE_NAME -l $CHAINCODE_LANG -v $CHAINCODE_VERSION -c $constructor -P "OR ('Org1MSP.member', 'Org2MSP.member')" --tls --cafile $ORDERER_CA
peer chaincode instantiate -o $ORDERER -C $CHANNEL_TWO_NAME -n $CHAINCODE_TWO_NAME -l $CHAINCODE_LANG -v $CHAINCODE_VERSION -c $constructor -P "OR ('Org1MSP.member', 'Org2MSP.member')" --tls --cafile $ORDERER_CA
