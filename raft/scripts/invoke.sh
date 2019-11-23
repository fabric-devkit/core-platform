#!/bin/bash

. ./scripts/common.sh

CHAINCODE_CONSTRUCTOR="[\"pay\",\"Paul\",\"1\",\"John\"]"
constructor="{\"Args\":$CHAINCODE_CONSTRUCTOR}"

peer chaincode invoke -o $ORDERER -C $CHANNEL_NAME -n $CHAINCODE_NAME -c $constructor --tls --cafile $ORDERER_CA
