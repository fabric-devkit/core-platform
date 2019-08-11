#!/bin/bash

. ./share/common.sh

Install and instantiate  in org 1
peer chaincode install -n $CHAINCODE_ONE_NAME -l $CHAINCODE_LANG -p $CHAINCODE_ONE_SRC -v $CHAINCODE_VERSION
peer chaincode install -n $CHAINCODE_TWO_NAME -l $CHAINCODE_LANG -p $CHAINCODE_TWO_SRC -v $CHAINCODE_VERSION
