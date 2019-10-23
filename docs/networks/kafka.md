---
title: Kafka Network
parent: Networks
has_children: true
nav_order: 3
---

## Overview

The purpose of this demonstrator is to help you appreciate the use of Kafka to give your network resiliancy.

Please refer to Fabric's [official documentation on Kafka based Fabric network](https://hyperledger-fabric.readthedocs.io/en/release-1.4/kafka.html)

## Scenario

This network uses a cluster of two orderers curated by a combination of Kafka and zookeepers. The network also comprises of two organisations. Each organisation owns a peer node, Fabric CA and a cli. The two organisation transact wtith each other via two channels.

## Demonstrator Content

| Item | Description |
| --- | --- |
| `cli-scripts` | This folder contains scripts to configure the dev network by creating channels, installing and instantiating chaincodes |
| `configtx.yaml` | Channel specification  |
| `crypto-config.yaml` | Crytographic artefact specification |
| `docker-compose.fabric.yaml` | A Hyperledger Fabric network orchestration specification |
| `docker-compose.kafka.yaml` | An orchestration specification for the kafka |
| `fabricOps.sh` | Please refer to details below |
| `generate-artefacts.sh` | Script to execute configtxgen and cryptogen tool |

### fabricOps.sh

This the principal network orchestration script to help you spin-up, tear down and add supporting components to the network. It is a Bash script based command line application. The script commands and sub-commands are as follows:

`./fabricOps.sh kafka <subcommand> | network <subcommand> | status | clean`

* `kafka` command to start a preconfigure kafka cluster, with the following sub commands

```shell
./fabricOps.sh kafka start | clean
```

* `network` to manipulate a Hyperledger Fabric network, with the following sub-command

```shell
./fabricOps.sh network start | configure | clean
```

* `status` command to display the status of the network.

* `clean` command to tear down the Hyperledger Fabric network to a clean state.

## Running the demonstrator

STEP 1: `git clone https://github.com/fabric-devkit/core-platform` and navigate to the folder named `kafka`.

STEP 2: Run the command `fabricOps.sh kafka start` to start Kafka cluster.

STEP 3: Run the command `fabricOps.sh network start` followed by `fabricOps.sh configure` to instantiate a Hyperledger Fabric network.

## Copyright Notice

Copyright (c) 2019. The Fabric-DevKit Authors. All rights reserved.
SPDX-License-Identifier: Apache-2.0
