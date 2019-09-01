#!/bin/bash

. ./scripts/common.sh

CHAINCODE_CONSTRUCTOR="[\"init\",\"Paul\",\"10\",\"John\",\"20\"]"
constructor="{\"Args\":$CHAINCODE_CONSTRUCTOR}"

CC_VER=`date +%Y%m%d_%H%M%S`

peer chaincode install -n $CHAINCODE_NAME -l $CHAINCODE_LANG -p $CHAINCODE_SRC -v $CC_VER
peer chaincode upgrade -o $ORDERER -C $CHANNEL_NAME -n $CHAINCODE_NAME -l $CHAINCODE_LANG -v $CC_VER -c $constructor -P "OR ('Org1MSP.member')" --tls --cafile $ORDERER_CA
