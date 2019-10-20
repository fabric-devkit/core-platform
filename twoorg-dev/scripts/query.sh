#!/bin/bash

. ./scripts/common.sh

QUERY_PARAM="$1"

if [ -z $QUERY_PARAM ]; then
    echo "Enter name of account you wish to query"
    exit 1
fi

CHAINCODE_CONSTRUCTOR="[\"query\",\"$QUERY_PARAM\"]"
constructor="{\"Args\":$CHAINCODE_CONSTRUCTOR}"

peer chaincode query -o $ORDERER -C $CHANNEL_NAME -n $CHAINCODE_NAME -c $constructor --tls --cafile $ORDERER_CA
