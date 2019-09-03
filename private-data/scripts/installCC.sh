#!/bin/bash

. ./scripts/common.sh

# Install and instantiate  in org 1
peer chaincode install -n $CHAINCODE_NAME -l $CHAINCODE_LANG -p $CHAINCODE_SRC -v $CHAINCODE_VERSION
