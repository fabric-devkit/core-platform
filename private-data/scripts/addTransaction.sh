#! /bin/bash

PRODUCT_CODE="$1"
PRODUCT_ID="$2"
PRODUCT_QUANTITY=$3
PRODUCT_PRICE=$4

TRANSACTION="{\"productCode\":\"${PRODUCT_CODE}\",\"productId\":\"${PRODUCT_ID}\",\"productQuantity\":${PRODUCT_QUANTITY},\"productPrice\":${PRODUCT_PRICE}}"
TRANSACTION_transient=$(echo $TRANSACTION | base64 | tr -d "\\n")
echo $TRANSACTION_transient
peer chaincode invoke -C mychannel -n private-data -c '{"Args":["addTransaction"]}' --transient "{\"transaction\":\"$TRANSACTION_transient\"}" --tls --cafile $ORDERER_CA


