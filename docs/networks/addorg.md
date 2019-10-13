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
| `cli-scripts` | This folder contains scripts to configure the dev network by creating channels, installing and instantiating chaincodes |
| `configtx.yaml` | Channel specification please refer to [crypto-configtx guide for details](./crypto-configtx.md)  |
| `crypto-config.yaml` | Crytographic artefact specification [crypto-configtx guide for details](./crypto-configtx.md) |
| `docker-compose.fabric.yaml` | An orchestration file for the dev network |
| `docker-compose.org2.yaml` | Orchestration file for org2 that includes one peer and one cli |
| `fabricOps.sh` | Please refer to details |
| `generate-artefacts.sh` | Script to execute configtxgen and cryptogen tool |
| `org2` | Artefacts associated with `org2` |

### fabricOps.sh

The principal network orchestration script to spin-up, tear down and add supporting components to the network. It is a Bash script based command line application.

`./fabricOps.sh network <subcommand> | ca-client <subcommand> | fabric-node-client <subcommand> | add-org2 <subcommand> | status | clean`

*`network` command*

Command to create Fabric network related:

* crytographic and channel arefects;
* to spin-up a working Fabric network;
* intialise (create channels, install chaincode and initialise chaincode first version) the running Fabric network;
* or upgrade the chaincode in a running Fabric network.

> Note:
> Please make sure the network operations is executed in the follow sequence:
>
> 1. For newly instantiated network: `network artefacts`, then `network start`, then `network init`;
> 2. Upgrading new chaincode: `network upgrade`.

```shell
./fabricOps.sh network artefacts | start | init | upgrade
```

| Subcommand | Description |
| --- | --- |
| `artefacts` | Create cryptographic and channel artefacts. |
| `start` | Instantiate the dev network. |
| `init` | Create, install and instantiate a chaincode [minimalcc](../chaincodes/minimalcc) on a network with no chaincode. |
| `upgrade` | Upgrade to a new version of chaincode and automatically append the new version with a new datetime stamp. |

*`add-org2` command*

Command to add org2 into the running `dev` network

```shell
./fabricOps.sh add-org2 artefacts | join
```

| Subcommand | Description |
| --- | --- |
| `artefacts` | Create `org2` related artefacts |
| `join` | Operations to join `org2` to dev network, this include operations to reconfigure existing channel to facilitating the addition or `org2`. |

*`status` command*

Command to get a list of the status instances running in the network.

```shell
./fabricOps.sh status
```

*`clean` command*

Command to tear down *all* containers in the Fabric network

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

To run this demonstrator, you will need to:

* Firstly, create and spin up a network with one organisation;
* Secondly, add `org2` to the existing one-organisation network;

### Startup the network with one-organisation

1. Run the command `./fabricOps.sh network artefacts` to build the necessary crytographic and channel artefacts.
2. Run the command `./fabricOps.sh network start` to get the dev network running.
3. Instantiate a new chaincode, run the command `./fabricOps.sh network init`
4. To help you debug code, run the command `./fabricOps.sh status` and you will see a list of running containers along this line:

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

### Add `Org2` to existing network channel containing `Org1`

1. Run the command `./fabricOps.sh clean` - this is to ensure that you have a clean network
2. Run `./fabricOps.sh network artefacts`, followed by `./fabricOps.sh network start` and then `./fabricOps.sh network init`.
3. Run `./fabricOps.sh add-org2 artefacts` and followed by `./fabricOps.sh add-org2 join`. You will see console displaying a two step operations. If no error proceed to next step.
4. Run `./fabricOps.sh add-org2 validate`. Ignore the sentence `Error: error sending transaction for invoke: could not send: EOF` and if you see in the console log `proposal response: version:1 response:<status:200 payload:"Payment done" >`, it means org2 has been added. For further confirmation if you run the command `fabricOps.sh status` and if you see a container named `dev-peer0.org-mycc-1.0` it means your org2 has been properly added.

> Note:
> The error message appears to be caused by a bug in the `peer chaincode invoke` command.
