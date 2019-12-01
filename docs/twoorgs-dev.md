---
title: Two Organisations Setup
nav_order: 1
---

## Overview

This section illustrates a process to orchestrate a Hyperledger Fabric network via a simple two-organisations network demonstrator. The demonstrator uses a combination of Hyperledger Fabric command line (CLI) tools to demonstrate a process. Command lines tools provide the ability to the process under the hood.

The demonstrator has been verified to work on macOS these versions of Hyperledger Fabric components:

| Component | Version |
| :-- | :-- |
| FABRIC CA | 1.4.0 |
| PEER | 1.4.0 |
| ORDERER| 1.4.0 |
| COUCHDB | 0.4.8 |
| FABRIC TOOL | 1.4 |
| macOS | Catalina |
| Docker | version 19.03.4, build 9013bf5 |

## Scenario

Imagine a scenario where you are tasked with orchestrating a two-organisation network with one orderer node operating in solo mode. Each organisation is assigned a Hyperledger Fabric Certificate Authority (CA), a peer node (anchor, endorser and committer combined) and a CLI client node (to enable user interact with peer node).

Having created the network, you are task with a installing and instantiating a chaincode (named minimalcc). The chaincode contains logic to transfer values between two personas (Paul and John). Where initially, Paul is assigned 10 units and John assigned 20 units of some value.

The process involve `org1` who is tasked with create an initial channel for the whole network. The channel is configure to facilitate transactions between`org1` and `org2` only. Please refer to the topic [crypto-configtx](fabric-devkit.github.io/core-platform) where the process of configuring Hyperledger Fabric channel is discussed.

`org1` and `org2` are responsible to for installing chaincodes in their own peer nodes. In this particular scenario, `org1` is responsible for instantiating the chaincode. `org2` is reponsible for installing the chaincode only.

`org1` and `org2` interacts with their respective installed chaincode by `invoking` and `querying`. Whilst each organisation interacts with its own node, you will see that both nodes will produce same result.

**NOTE:** if you are a chaincode developer and wanting to test out your chaincode, you could clone this folder and work with this.

## How to use this demonstrator

The demonstrator is hardcoded to follow the scenario described above out-of-the-box.

STEP 1 - Open a bash terminal and clone the repo [https://github.com/fabric-devkit/core-platform](https://github.com/fabric-devkit/core-platform). Examine the `docker-compose.yaml` (this shows the relationship between the orders, peer nodes and cli nodes) and scripts (these are bash scripts showing steps to configure and interact with the network using cli tools).

STEP 2 - Navigate to the folder `twoorg-dev`.

STEP 3 - Run the command `./fabricOps.sh artefacts`. This creates the necessary crytographic and channel configuration assets (i.e. genesis nodes, etc).

STEP 4 - Run the command `./fabricOps.sh network start` to start-up a pre-configure network.

STEP 5 - Run the command `./fabricOps.sh cli org1` to give you access to the cli tool belonging to `org1`. You will see the terminal that looks similar to this:

```shell
root@311ebdd409fc:/opt/gopath/src/github.com/hyperledger/fabric#
```

STEP 4 - In `org1` cli terminal, run the command `./scripts/createChan.sh`, and if you get a result similar to this:

```shell
root@311ebdd409fc:/opt/gopath/src/github.com/hyperledger/fabric# ./scripts/createChan.sh
........
........
2019-10-20 14:28:39.845 UTC [channelCmd] executeJoin -> INFO 040 Successfully submitted proposal to join channel
```

This means `org1` peer has created a channel named `mychannel` and joined it.

STEP 5 - In `org1` cli terminal, run the command `./scripts/installCC.sh` to install the chaincode name `minimalcc` in `org1` peer node. Watch for a message: `Installed remotely response:<status:200 payload:"OK" >` to be confident of success.

STEP 6 - In `org1` cli terminal, run the command `./scripts/instantiateCC.sh` to instantiate the chaincode -- i.e. initialise the world state with Paul 10 units and John 20 units. It make take some time to complete this the process.

STEP 7 - In `org1` cli terminal, run the command `./scripts/query.sh Paul` and you will see an indication stating Paul has 10 units.

STEP 8 - Run the command `exit` to leave `org1` cli terminal.

STEP 9 - Run the command `./fabricOps.sh cli org2` to give you access to `org2` cli terminal.

STEP 10 - In `org2` cli terminal, run the command `./scripts/joinChan.sh` to join `org2` peer node to `mychannel`.

STEP 11 - In `org2` cli terminal, run the command `./scripts/installCC.sh` in `org2` peer node.

STEP 12 - In `org2` cli terminal, run the command `./scripts/query.sh John` to show initial value of 20 assigned to John.

When you have completed these steps you will have a fully initialise network.

**NOTE:** You will have noticed that there is a script `invoke.sh` that simulate a hardcoded payment transaction from the persona John to Paul for 1 unit. This does not have an effect on the network -- i.e. reach a consensus between `org1` and `org2` nodes that payment has occurred between the two personas. So neither nodes will have updated their world state. The cli command `peer chaincode invoke` only runs a simulation of the chaincode but it does not commit the result to the world state. You can use this script to help you debug the chaincode without impacting the network state.

## Copyright Notice

Copyright (c) 2019. The Fabric-DevKit Authors. All rights reserved.
SPDX-License-Identifier: Apache-2.0
