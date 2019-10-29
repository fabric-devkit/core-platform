---
title: Kafka Network
parent: Networks
has_children: true
nav_order: 3
---

## Overview

The purpose of this demonstrator is to help you appreciate the process of setting up a Kafka based Hyperledger Fabric network.

Please refer to Fabric's [official document on Kafka based Fabric network](https://hyperledger-fabric.readthedocs.io/en/release-1.4/kafka.html)

## Scenario

This network uses a cluster of two orderers curated by a combination of Kafka and zookeepers. The network also comprises of two organisations. Each organisation owns a peer node, Fabric CA and a cli. The two organisation transact wtith each other via two channels.

## Steps to configure a Kafka network

STEP 1: `git clone https://github.com/fabric-devkit/core-platform` and navigate to the folder named `kafka`.

STEP 2: Run the command `fabricOps.sh kafka start` to start Kafka cluster.

STEP 3: Run the command `fabricOps.sh network start` followed by `fabricOps.sh configure` to instantiate a Hyperledger Fabric network.

## Copyright Notice

Copyright (c) 2019. The Fabric-DevKit Authors. All rights reserved.
SPDX-License-Identifier: Apache-2.0
