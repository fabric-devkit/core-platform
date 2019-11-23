#!/bin/bash

. ./scripts/common.sh

peer chaincode install -n $CHAINCODE_NAME -l $CHAINCODE_LANG -p $CHAINCODE_SRC -v $CHAINCODE_VERSION
