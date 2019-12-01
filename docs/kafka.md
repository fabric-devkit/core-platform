---
title: Kafka Network
nav_order: 3
---

# Overview

The purpose of this demonstrator is to help you appreciate the process of setting up a Kafka based Hyperledger Fabric network.

Please refer to Fabric's [official document on Kafka based Fabric network](https://hyperledger-fabric.readthedocs.io/en/release-1.4/kafka.html)

The demonstrator has been verified to work on macOS these versions of Hyperledger Fabric components:

| Component | Version |
| :-- | :-- |
| FABRIC CA | 1.4.0 |
| PEER | 1.4.0 |
| ORDERER | 1.4.0 |
| COUCHDB | 0.4.8 |
| FABRIC_TOOL | 1.4 |
| KAFKA | 0.4.16 |
| ZOOKEEPER | 0.4.16 |
| macOS | Catalina |
| Docker | version 19.03.4, build 9013bf5 |

## Scenario

This network uses a cluster of two orderers curated by a combination of Kafka and zookeepers. The network also comprises of two organisations. Each organisation owns a peer node, Fabric CA and a cli. The two organisation transact wtith each other via two channels.

## Steps to configure a Kafka network

STEP 1: `git clone https://github.com/fabric-devkit/core-platform` and navigate to the folder named `kafka`.

STEP 2: Run the command `fabricOps.sh kafka start` to start Kafka cluster.

STEP 3: Run the command `fabricOps.sh network start` followed by `fabricOps.sh configure` to instantiate a Hyperledger Fabric network.

## Copyright Notice

Copyright (c) 2019. The Fabric-DevKit Authors. All rights reserved.
SPDX-License-Identifier: Apache-2.0
