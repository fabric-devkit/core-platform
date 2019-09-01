---
title: Add Organisation
parent: Networks
has_children: true
nav_order: 2
---

# Add an organisation to an existing channel

This sub-project is intially configured with an organisation (named `Org1`) comprising of one orderer, one certificate authority (ca), one peer and one cli container operating in solo mode. The purpose of this sub-project is to demonstrate the process of adding another organisation named `Org2` to the existing network channel.

The artefacts needed to support the addition of Org2 are found in the folder [org2](../networks/dev/org2), [docker-compose.org2.yaml](../networks/dev/docker-compose.org2.yaml) and [step1AddOrg2.sh, step2AddOrg2.sh org2Validate.sh](../networks/dev/cli-scripts).

Please refer to the [Hyperledger Fabric's official documentation](https://hyperledger-fabric.readthedocs.io/en/release-1.4/blockchain.html) to learn about the Fabric network.

## How can I demonstrate the process of adding another organisation?

Firstly, startup the network with one-organisation.

1. Run the command `./fabricOps.sh network artefacts` to build the necessary crytographic and channel artefacts.
   
2. Run the command `./fabricOps.sh network start` to get the dev network running.

3. Assuming you have chaincode installed (see [setting](#dotEvn)) if you wish to:
   
    a) Instantiate a new chaincode, run the command `./fabricOps.sh network init`

    b) Upgrade an existing chaincode (i.e. same name), run the command `./fabricOps.sh network upgrade` -- the script will generate a new version number.

4. To help you debug code, run the command `./fabricOps.sh status` and you will see a list of running containers along this line:

```
CONTAINER ID        IMAGE                                                                                          COMMAND                  CREATED             STATUS              PORTS                                            NAMES
3bed8a31d698        dev-peer0.org1.dev-mycc-1.0-a21f64b1b2d2350eb61345597984983a2efce1027733a9446bfd8d1816598c3b   "chaincode -peer.add…"   4 minutes ago       Up 3 minutes                                                         dev-peer0.org1.dev-mycc-1.0
6252a894ffa0        hyperledger/fabric-tools:latest                                                                "/bin/bash"              4 minutes ago       Up 4 minutes                                                         cli.org1.dev
e25f0ef5e82c        hyperledger/fabric-peer:1.4.0                                                                  "peer node start"        4 minutes ago       Up 4 minutes        0.0.0.0:7051->7051/tcp, 0.0.0.0:7053->7053/tcp   peer0.org1.dev
57e75ef3fdc5        hyperledger/fabric-ca:1.4.0                                                                    "/bin/sh -c 'fabric-…"   4 minutes ago       Up 4 minutes        0.0.0.0:7054->7054/tcp                           ca.org1.dev
b0ec24dc8897        hyperledger/fabric-orderer:1.4.0                                                               "orderer"                4 minutes ago       Up 4 minutes        0.0.0.0:7050->7050/tcp                           orderer.dev
```

Select the container ID with a name like `dev-*-*-X.X`. Using the above example, it would be named `dev-peer0.org1.dev-mycc-1.0` with container ID `3bed8a31d698`.

Run the command `docker logs 3bed8a31d698` and you will see any logs that exists in the running chaincode. For example,

```
2019-02-27 14:17:06.067 UTC [minimalcc] Info -> INFO 001 Hello Init
2019-02-27 14:17:06.068 UTC [minimalcc] Infof -> INFO 002 Name1: Paul Amount1: 10
2019-02-27 14:17:06.069 UTC [minimalcc] Infof -> INFO 003 Name2: John Amount2: 20
```

Secondly, add `Org2` to existing channel containing `Org1`:

1. Run the command `./fabricOps.sh clean` - this is to ensure that you have a clean network

2. Run `./fabricOps.sh network artefacts`, followed by `./fabricOps.sh network start` and then `./fabricOps.sh network init`.

3. Run `./fabricOps.sh add-org2 artefacts` and followed by `./fabricOps.sh add-org2 join`. You will see console displaying a two step operations. If no error proceed to next step.

4. Run `./fabricOps.sh add-org2 validate`. Ignore the sentence `Error: error sending transaction for invoke: could not send: EOF` and if you see in the console log `proposal response: version:1 response:<status:200 payload:"Payment done" >`, it means org2 has been added. For further confirmation if you run the command `fabricOps.sh status` and if you see a container named `dev-peer0.org-mycc-1.0` it means your org2 has been properly added.

> Note:
> The error message appears to be caused by a bug in the `peer chaincode invoke` command.

## Content

The dev network orchestrator is located [here](../networks/dev)

| Item | Description |
| --- | --- |
| `.env` | Shared orchestrator environmental variables |
| `cli-scripts` | This folder contains scripts to configure the dev network by creating channels, installing and instantiating chaincodes |
| `configtx.yaml` | Channel specification please refer to [crypto-configtx guide for details](./crypto-configtx.md)  |
| `crypto-config.yaml` | Crytographic artefact specification [crypto-configtx guide for details](./crypto-configtx.md) |
| `docker-compose.fabric.yaml` | An orchestration file for the dev network |
| `docker-compose.org2.yaml` | Orchestration file for org2 that includes one peer and one cli |
| `fabricOps.sh` | Please refer to details [here](#fabricOps) |
| `generate-artefacts.sh` | Script to execute configtxgen and cryptogen tool |
| `org2` | This contains artefacts for org2 namely:<br> + `configtx.yaml` channel configuration file for org2:<br> + `org2-crypto.yaml` cryptographic configuration for org2<br> + `generate-artefacts.sh` scripts to be executed as part of `fabricOps.sh` to generate org2 artefacts. |

**<a name="dotEvn">.env</a>**

Modify the file `.env` to specify its content accordingly:

```
COMPOSE_PROJECT_NAME=dev
NETWORKS=fabric-network
CA_IMAGE_TAG=1.4.0
PEER_IMAGE_TAG=1.4.0
ORDERER_IMAGE_TAG=1.4.0
FABRIC_TOOL_IMAGE_TAG=latest
CHAINCODE_PATH=../../chaincodes/
```

>Note:
>Do not modify `COMPOSE_PROJECT_NAME` and `NETWORKS`. These values are use to generate bridging network

**<a name="fabricOps">fabricOps.sh</a>**

The principal network orchestration script to help you spin-up, tear down and add supporting components to the network. It is a Bash script based command line application.

`./fabricOps.sh network <subcommand> | ca-client <subcommand> | fabric-node-client <subcommand> | add-org2 <subcommand> | status | clean`
 
*`network` command*

Command to create Fabric network related:

* crytographic and channel arefects;
* to spin-up a working Fabric network;
* intialise (create channels, install chaincode and initialise chaincode first version) the running Fabric network;
* or upgrade the chaincode in a running Fabric network.

> Note:
> Please make sure the network operations is executed in the follow sequence:
> 1. For newly instantiated network: `network artefacts`, then `network start`, then `network init`;
> 2. Upgrading new chaincode: `network upgrade`.

```
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

```
./fabricOps.sh add-org2 artefacts | join 
```
| Subcommand | Description |
| --- | --- |
| `artefacts` | Create `org2` related artefacts |
| `join` | Operations to join `org2` to dev network, this include operations to reconfigure existing channel to facilitating the addition or `org2`. |

*`status` command*

Command to get a list of the status instances running in the network.

```
./fabricOps.sh status
```

*`clean` command*

Command to tear down *all* containers in the Fabric network

```
./fabricOps.sh clean
```
