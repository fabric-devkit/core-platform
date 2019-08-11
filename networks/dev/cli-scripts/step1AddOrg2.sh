#!/bin/bash

echo "==============================================="
echo "== STEP 1: Prepare to add Org2 from Org1 cli =="
echo "==============================================="

apt-get -y update && apt-get -y install jq

. ./scripts/common.sh

peer channel fetch config config_block.pb -o $ORDERER -c $CHANNEL_NAME --tls --cafile $ORDERER_CA

configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json

jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups":{"Org2MSP":.[1]}}}}}' config.json ./channel-artefacts/org2.json >modified_config.json

configtxlator proto_encode --input config.json --type common.Config >original_config.pb
configtxlator proto_encode --input modified_config.json --type common.Config >modified_config.pb
configtxlator compute_update --channel_id $CHANNEL_NAME --original original_config.pb --updated modified_config.pb >config_update.pb
configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate >config_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL_NAME'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . >config_update_in_envelope.json
configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope >./channel-artefacts/org2_update_in_envelope.pb

peer channel signconfigtx -f ./channel-artefacts/org2_update_in_envelope.pb

peer channel update -f ./channel-artefacts/org2_update_in_envelope.pb -c $CHANNEL_NAME -o $ORDERER --tls --cafile $ORDERER_CA