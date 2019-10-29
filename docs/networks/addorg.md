---
title: Add Organisation
parent: Networks
has_children: true
nav_order: 2
---

## Overview

The purpose of this demonstrator is to help you understands the process of adding an organisation to an existing network.

For a conceptual understanding of the process of adding a peer to an existing network and channel, please refer to this [article](https://medium.com/@kctheservant/add-a-new-organization-on-existing-hyperledger-fabric-network-2c9e303955b2).

The demonstrator has been verified to work on macOS these versions of Hyperledger Fabric components:

| Component | Version |
| :-- | :-- |
| FABRIC CA | 1.4.0 |
| PEER | 1.4.0 |
| ORDERER | 1.4.0 |
| FABRIC TOOL | 1.4 |
| macOS | Catalina |
| Docker | version 19.03.4, build 9013bf5 |

## Scenario

Imagine a scenario where you are responsible for instantiating a network with one `orderer` and `org1` -- comprising a Certificate Authority (CA), peer node and a cli client peer -- and a channel named `mychannel`. You are also responsible for generating cryptographic and channel artefacts for `org2`, and configuring `mychannel` to accept `org2`.

Switch to another persona, who is also responsible for orchstrating `org2`. The persona is responsible for joining `org2` to `mychannel`.

**NOTE:** This is one of many possible ways to configure and expanding a Hyperledger Fabric network. The intention here is to demonstrate the underlying process of expanding a network, which is same regardless of how a network is configured.

A more realistic scenario is one where individual members are responsible for their own organisations and responsible for generating their own cryptographic artefacts. Each member then submit their respective artefacts to a collectively managed and neutral organisation responsible for configuring the network as a whole.

## Steps to add Org2 to network

Step 1 - Run the command `./fabricOps.sh network` to create initialise and instantiate a network with `org1` and one channel named `mychannel`

Step 2 - Run the command `./fabricOps.sh status` and if you see the following status, it means you have a functioning network

```shell
CONTAINER ID        IMAGE                                                                                          COMMAND                  CREATED             STATUS              PORTS                                            NAMES
3bed8a31d698        dev-peer0.org1.dev-mycc-1.0-a21f64b1b2d2350eb61345597984983a2efce1027733a9446bfd8d1816598c3b   "chaincode -peer.add…"   4 minutes ago       Up 3 minutes                                                         dev-peer0.org1.dev-mycc-1.0
6252a894ffa0        hyperledger/fabric-tools:latest                                                                "/bin/bash"              4 minutes ago       Up 4 minutes                                                         cli.org1.dev
e25f0ef5e82c        hyperledger/fabric-peer:1.4.0                                                                  "peer node start"        4 minutes ago       Up 4 minutes        0.0.0.0:7051->7051/tcp, 0.0.0.0:7053->7053/tcp   peer0.org1.dev
57e75ef3fdc5        hyperledger/fabric-ca:1.4.0                                                                    "/bin/sh -c 'fabric-…"   4 minutes ago       Up 4 minutes        0.0.0.0:7054->7054/tcp                           ca.org1.dev
b0ec24dc8897        hyperledger/fabric-orderer:1.4.0                                                               "orderer"                4 minutes ago       Up 4 minutes        0.0.0.0:7050->7050/tcp                           orderer.dev
```

> To ensure that you have an operative network, select the container ID with a name like `dev-*-*-X.X`. Using the above example, it would be
> named `dev-peer0.org1.dev-mycc-1.0` with container ID `3bed8a31d698`. Run the command `docker logs 3bed8a31d698` and you will see any logs
> that exists in the running chaincode. For example,

```shell
2019-02-27 14:17:06.067 UTC [minimalcc] Info -> INFO 001 Hello Init
2019-02-27 14:17:06.068 UTC [minimalcc] Infof -> INFO 002 Name1: Paul Amount1: 10
2019-02-27 14:17:06.069 UTC [minimalcc] Infof -> INFO 003 Name2: John Amount2: 20
```

Step 3 - Run the command `./fabricOps.sh add-org2 artefacts` to create artefacts for `org2`.

Step 4 - Run the command `./fabricOps.sh add-org2 join` to join `org2` to `org1`.

Step 5 - Run the command `./fabricOps.sh add-org2 validate` to install and instantiate chaincode in `org2`. Ignore the sentence `Error: error sending transaction for invoke: could not send: EOF`. If you see in the console log `proposal response: version:1 response:<status:200 payload:"Payment done" >`, it means org2 has been added. For further confirmation if you run the command `fabricOps.sh status` and if you see a container named `dev-peer0.org-mycc-1.0` it means your org2 has been properly added.

## Copyright Notice

Copyright (c) 2019. The Fabric-DevKit Authors. All rights reserved.
SPDX-License-Identifier: Apache-2.0
