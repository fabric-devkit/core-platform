#!/bin/bash

. ./share/common.sh

peer channel fetch newest -o $ORDERER -c $CHANNEL_ONE_NAME --tls --cafile $ORDERER_CA ./$CHANNEL_ONE_NAME.block
peer channel join -o $ORDERER -b ./$CHANNEL_ONE_NAME.block --tls --cafile $ORDERER_CA

peer channel fetch newest -o $ORDERER -c $CHANNEL_TWO_NAME --tls --cafile $ORDERER_CA ./$CHANNEL_TWO_NAME.block
peer channel join -o $ORDERER -b ./$CHANNEL_TWO_NAME.block --tls --cafile $ORDERER_CA