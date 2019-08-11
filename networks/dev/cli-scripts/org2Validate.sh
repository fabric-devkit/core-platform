#!/bin/bash

echo "=========================="
echo "== Validating Org2      =="
echo "=========================="

. ./scripts/common.sh

peer chaincode invoke -o $ORDERER -C $CHANNEL_NAME -n $CHAINCODE_NAME -c '{"Args":["pay","Paul","1","John"]}'