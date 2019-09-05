---
title: Private Data
parent: Networks
has_children: true
nav_order: 5
---
# Private data

This section describes how private data works, and illustrates an example of how it can compartmentalise the flow of data within a Hyperledger Fabric network. For more information, please refer to the [official documentation (version 1.4)](https://hyperledger-fabric-ca.readthedocs.io/en/release-1.4/).

# What is private data?
By default, all data in an entry on a Hyperledger Fabric network are viewable by all of the participants. This is often desirable, and such transparency is a frequently advertised feature of public blockchains. However, in an enterprise blockchain, there are often certain elements of a record that a user would want to restrict access to certain participants within a network. For example, a supplier to a store would only want to make pricing information available to the parties directly involved, and not shared with other suppliers who may be part of the same network.

# How does private data work?
Private data is achieved by marking selected fields in our chaincode as private. By setting a policy on this chaincode, we can select a subset of member properties of the record that the chaincode controls, and permit access to them only by specified organisations in the network. Other organisations will still be able to see the presence of the record and the public fields within it, but cannot access the private fields.
Additional settings within the private data allow us to configure a minimum and maximum number of peers required to validate private data, and a maximum lifespan of the data in blocks, allowing us to write private data that will become un-queryable if not modified for a fixed number of blocks. Only a hash of the purged data is left behind to prove that it ever existed.
Private data provides a finer level of access than can be achieved through channels. By setting up distinct channels that exclude certain organisations, those outside the channel will have no visibility at all of activity within the channel. This may be desirable in some circumstances, but private data allows some elements of our data to be made public while keeping others private.

# Prepararion
NB: Private data was implemented in Hyperledger Fabric version 1.3. In order for chaincode containing private data to be installed, our network must enble V1.2 functionality. Before building the network, ensure that configtx.yaml contains a section:
```
Application: &ApplicationCapabilities
        # V1.2 for Application enables the new non-backwards compatible
        # features and fixes of fabric v1.3.
        V1_2: true
```
### Collections Config
A chaincode utilising private data needs a corresponding collections_config.json file. This specifies the privacy policy for each field with an object, allowing selected fields to be made public to other organisations, while others are kept private to the originating node. In our example we define this as:
````
[
    {
         "name": "collectionTransaction",
         "policy": "OR('Org1MSP.member', 'Org2MSP.member')",
         "requiredPeerCount": 0,
         "maxPeerCount": 3,
         "blockToLive":0,
         "memberOnlyRead": true
    },
  
    {
         "name": "collectionTransactionPrivate",
         "policy": "OR('Org1MSP.member')",
         "requiredPeerCount": 0,
         "maxPeerCount": 3,
         "blockToLive":3,
         "memberOnlyRead": true
    }
  ]
````
In this example, collectionTransaction is our public collection, which is shared between org1 and org2. collectionTransactionPrivate is the policy for our private data, which is only available to Org1.

The mapping of fields to privacy policies is made in the chaincode itself. In our example, we assign a `price` field to the `collectionTransactionPrivate` policy, and the rest to the `collectionTransaction` policy:
```
// ==== Create transaction private details object with price, marshal to JSON, and save to state ====
transactionPrivateDetails := &transactionPrivate{
        ObjectType:   "transactionPrivate",
        ProductCode:  transactionInput.ProductCode,
        ProductPrice: transactionInput.ProductPrice,
}
transactionPrivateDetailsBytes, err := json.Marshal(transactionPrivateDetails)
err = stub.PutPrivateData("collectionTransactionPrivate", transactionInput.ProductCode, transactionPrivateDetailsBytes)
```
```
// ==== Create transaction object, marshal to JSON, and save to state ====
transaction := &transaction{
        ObjectType:      "transaction",
        ProductCode:     transactionInput.ProductCode,
        ProductId:       transactionInput.ProductId,
        ProductQuantity: transactionInput.ProductQuantity,
}
err = stub.PutPrivateData("collectionTransaction", transaction.ProductCode, transactionJSONasBytes)
```


# Usage
As with our other examples, a script has been provided to create and intialise the network. From the folder ```networks/private-data```, run the following two commands to set up the network and prepare the chaincode:
```
./fabricOps.sh network start
./fabricOps.sh network init
```
Next, we'll create a sample transaction on the network from org1 with the command:
```
./fabricOps.sh network createSampleTransaction
```
Once this has completed, query the transaction with the command:
```
./fabricOps.sh network readTransaction
```
This queries the public data in the sample transaction that we just created from both org1 and org2. As we made the public data available to both orgs, we should see the same results on both:
```
############### Querying on org1 ###############
2019-09-05 07:06:11.479 UTC [chaincodeCmd] InitCmdFactory -> INFO 001 Retrieved channel (mychannel) orderer endpoint: orderer.priv:7050
2019-09-05 07:06:11.490 UTC [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 002 Chaincode invoke successful. result: status:200 payload:"{\"docType\":\"transaction\",\"productCode\":\"productA\",\"productDescription\":\"1234\",\"productQuantity\":70}" 
############### Querying on org2 ###############
2019-09-05 07:06:11.879 UTC [chaincodeCmd] InitCmdFactory -> INFO 001 Retrieved channel (mychannel) orderer endpoint: orderer.priv:7050
2019-09-05 07:06:12.759 UTC [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 002 Chaincode invoke successful. result: status:200 payload:"{\"docType\":\"transaction\",\"productCode\":\"productA\",\"productDescription\":\"1234\",\"productQuantity\":70}" 
```

Now we query the private data on both organisations with the command:
```
./fabricOps.sh network readTransactionPrivate
```
As we defined our collections config to make private data available to org1 only, this command should return the private data when run on org1, but fail on org2:
```
############### Querying on org1 ###############
2019-09-05 07:08:13.176 UTC [chaincodeCmd] InitCmdFactory -> INFO 001 Retrieved channel (mychannel) orderer endpoint: orderer.priv:7050
2019-09-05 07:08:13.188 UTC [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 002 Chaincode invoke successful. result: status:200 payload:"{\"docType\":\"transactionPrivate\",\"productCode\":\"productA\",\"productPrice\":60}" 
############### Querying on org2 ###############
2019-09-05 07:08:13.562 UTC [chaincodeCmd] InitCmdFactory -> INFO 001 Retrieved channel (mychannel) orderer endpoint: orderer.priv:7050
Error: endorsement failure during invoke. response: status:500 message:"{\"Error\":\"Failed to get private details for productA: GET_STATE failed: transaction ID: b85e1b2d2d7520970941861e09ade164f64e89e191ba5064872d08131706d9bf: tx creator does not have read access permission on privatedata in chaincodeName:private-data collectionName: collectionTransactionPrivate\"}" 
```

## Copyright Notice
Copyright (c) 2019. The Fabric-DevKit Authors. All rights reserved.
SPDX-License-Identifier: Apache-2.0