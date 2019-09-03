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
Assuming that these commands successfully completed, open a shell on the `cli.org1.priv` with the command `docker exec -it cli.org1.priv bash`.

Unlike with standard chaincode invoke commands, we need to pass arguments to the private data chaincode using a transient object. We do this by first setting up an object to be inserted into the chaincode:
```export TRANSACTION=$(echo -n "{\"productCode\":\"productA\",\"productId\":\"1234\",\"productQuantity\":70,\"productPrice\":100}" | base64 | tr -d \\n) ```
This creates a json object containing an example transaction to be created in the chaincode, of which the productPrice will be stored in private data, the rest in public data. The information in public data will be available to org1 and org2, the private data will only be available to org1. Having created our data object, we insert it into our chaincode with the command
```peer chaincode invoke -C mychannel -n private-data -c '{"Args":["addTransaction"]}' --transient "{\"transaction\":\"$TRANSACTION\"} " --tls --cafile $ORDERER_CA```

This command should succeed, with output looking like:

```2019-09-01 13:30:24.331 UTC [chaincodeCmd] InitCmdFactory -> INFO 001 Retrieved channel (mychannel) orderer endpoint: orderer.priv:7050
2019-09-01 13:30:24.356 UTC [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 002 Chaincode invoke successful. result: status:200 ```

Now we can query the object that we just created. This is done in two parts, a query of the public data and the private data. On org1 we expect to have access to both parts, from org2 we should have access to the public data only.
First, remaining on cli.org1.priv, execute the command to read the public data:

```root@de4b002261ec:/opt/gopath/src/github.com/hyperledger/fabric# peer chaincode invoke -C mychannel -n private-data -c '{"Args":["readTransaction", "productA"]}' --tls --cafile $ORDERER_CA``

This suld return the content of the public data for the object we just created:
```2019-09-01 13:31:32.820 UTC [chaincodeCmd] InitCmdFactory -> INFO 001 Retrieved channel (mychannel) orderer endpoint: orderer.priv:7050
2019-09-01 13:31:32.829 UTC [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 002 Chaincode invoke successful. result: status:200 payload:"{\"docType\":\"transaction\",\"productCode\":\"productA\",\"productDescription\":\"1234\",\"productQuantity\":70}" ```
Observe that the result contains the public data fields for the object only.

Next, we can query the private data for the same object, also from org1:
```root@de4b002261ec:/opt/gopath/src/github.com/hyperledger/fabric# peer chaincode invoke -C mychannel -n private-data -c '{"Args":["readTransactionPrivateDetails", "productA"]}' --tls --cafile $ORDERER_CA```

This should successfully return the private `price` field for the object:
```2019-09-01 13:31:53.634 UTC [chaincodeCmd] InitCmdFactory -> INFO 001 Retrieved channel (mychannel) orderer endpoint: orderer.priv:7050
2019-09-01 13:31:53.645 UTC [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 002 Chaincode invoke successful. result: status:200 payload:"{\"docType\":\"transactionPrivate\",\"productCode\":\"productA\",\"productPrice\":100}"```

Next, we test the behaviour of querying the object from org2. Switch the shell to `cli.org2.priv`:
```exit
docker exec -it cli.org2.priv bash```
First, check that we can read the public data. This should give the same result as when run from org1:
```root@34f02893274e:/opt/gopath/src/github.com/hyperledger/fabric# peer chaincode invoke -C mychannel -n private-data -c '{"Args":["readTransaction", "productA"]}' --tls --cafile $ORDERER_CA
2019-09-01 13:47:01.680 UTC [chaincodeCmd] InitCmdFactory -> INFO 001 Retrieved channel (mychannel) orderer endpoint: orderer.priv:7050
2019-09-01 13:47:19.058 UTC [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 002 Chaincode invoke successful. result: status:200 payload:"{\"docType\":\"transaction\",\"productCode\":\"productA\",\"productDescription\":\"1234\",\"productQuantity\":70}" ```

Finally, attempt to query the private data. This should fail, as our collections config specifies that the private data is only available to org1:
```root@34f02893274e:/opt/gopath/src/github.com/hyperledger/fabric# peer chaincode invoke -C mychannel -n private-data -c '{"Args":["readTransactionPrivateDetails", "productA"]}' --tls --cafile $ORDERER_CA
2019-09-01 13:47:28.933 UTC [chaincodeCmd] InitCmdFactory -> INFO 001 Retrieved channel (mychannel) orderer endpoint: orderer.priv:7050
Error: endorsement failure during invoke. response: status:500 message:"{\"Error\":\"Failed to get private details for productA: GET_STATE failed: transaction ID: e4a17889223493c9ea259fd127cd0f108278046e64e1e7bf54f8e670fd7fbe65: tx creator does not have read access permission on privatedata in chaincodeName:private-data collectionName: collectionTransactionPrivate\"}" ```



## Copyright Notice
Copyright (c) 2019. The Fabric-DevKit Authors. All rights reserved.
SPDX-License-Identifier: Apache-2.0