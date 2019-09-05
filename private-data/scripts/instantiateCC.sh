#!/bin/bash

. ./scripts/common.sh

CHAINCODE_CONSTRUCTOR="[\"init\"]"
constructor="{\"Args\":$CHAINCODE_CONSTRUCTOR}"

peer chaincode instantiate -o $ORDERER -C $CHANNEL_NAME -n $CHAINCODE_NAME -l $CHAINCODE_LANG -v $CHAINCODE_VERSION -c $constructor -P "OR ('Org1MSP.member','Org2MSP.member')" --tls --cafile $ORDERER_CA --collections-config $GOPATH/src/$CHAINCODE_SRC/collections_config.json
