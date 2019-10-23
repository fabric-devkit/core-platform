---
title: Add Organisation
parent: Networks
has_children: true
nav_order: 2
---

## Overview

The purpose of this demonstrator is to help you understands the process of adding an organisation to an existing network.

For a conceptual understanding of the process of adding a peer to an existing network and channel, please refer to this [article](https://medium.com/@kctheservant/add-a-new-organization-on-existing-hyperledger-fabric-network-2c9e303955b2).

## Demonstrator Scenario

Imagine a scenario where you have instantiated a Hyperledger Fabric network with one orderer (operating in solo mode) a Fabric organisation (named `Org1`) comprising one certificate authority (CA), one peer and one cli adminstrator client peer. You have also create a channel for `Org1` peer to interact via the orderer with another peer in another organisation.

Next you want to add another organisation named `Org2`, namely the one peer in the organisation, to the existing network channel you have created for `Org1`.

## Demonstator Content

To help you learn the process of adding an org to an existing network, clone [https://github.com/fabric-devkit/core-platform](https://github.com/fabric-devkit/core-platform) and navigate to the folder named `addorg` and you will find the following items.

| Item | Description |
| --- | --- |
| `cli-scripts` | This folder contains scripts to configure an initial one org (`Org1`) network and to add another org (`Org2`) |
| `configtx.yaml` | Channel specification |
| `crypto-config.yaml` | Crytographic artefact specification  |
| `docker-compose.fabric.yaml` | A network orchestration specification for initial network |
| `docker-compose.org2.yaml` | Orchestration specification for org2 that includes one peer and one cli |
| `fabricOps.sh` | Please refer to details below |
| `generate-artefacts.sh` | Script to execute configtxgen and cryptogen tool |
| `org2` | Artefacts associated with `org2` |

### fabricOps.sh

The principal network orchestration script to spin-up, tear down and add supporting components to the network. It is a Bash script based command line application.

`./fabricOps.sh network | add-org2 <subcommand> | status | clean`

* `network` command responsible for creating and starting an initial network;

* `add-org2` command responsible for add org2 into the running `dev` network, please refer to sub-commands.

```shell
./fabricOps.sh add-org2 artefacts | join | validate
```

| Subcommand | Description |
| --- | --- |
| `artefacts` | Create `org2` related artefacts via `org1` cli |
| `join` | Operations to join `org2` via its cli to initial network |
| `validate` | Operations to instatiate the chaincodes in `org2` |

* `status` command list of the status instances running in the network.

```shell
./fabricOps.sh status
```

* `clean` command reset network to clean state

```shell
./fabricOps.sh clean
```

### Org2 artefacts

| Item | Description |
| --- | --- |
| `configtx.yaml` |  Channel configuration file  |
| `org2-crypto.yaml` | cryptographic configuration file for org2 |
| `generate-artefacts.sh`| scripts to create cryptographics and channel artefacts |

## Steps to add Org2 to network

Step 1 - Run the command `./fabricOps.sh network` to create initialise and instantiate a network.

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

Step 4 - Run the command `./fabricOps.sh add-org2 join`.

Step 5 - Run the command `./fabricOps.sh add-org2 validate` to install and instantiate chaincode in `org2`. Ignore the sentence `Error: error sending transaction for invoke: could not send: EOF`. If you see in the console log `proposal response: version:1 response:<status:200 payload:"Payment done" >`, it means org2 has been added. For further confirmation if you run the command `fabricOps.sh status` and if you see a container named `dev-peer0.org-mycc-1.0` it means your org2 has been properly added.

## Copyright Notice

Copyright (c) 2019. The Fabric-DevKit Authors. All rights reserved.
SPDX-License-Identifier: Apache-2.0