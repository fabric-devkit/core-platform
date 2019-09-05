#! /bin/bash

PRODUCT_CODE="$1"

peer chaincode invoke -C mychannel -n private-data -c "{\"Args\":[\"readTransaction\", \"${PRODUCT_CODE}\"]}" --tls --cafile $ORDERER_CA

