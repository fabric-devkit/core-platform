# Overview

This is a Fabric Devkit [sub-project](https://github.com/fabric-devkit/core-platform) intended to help platform engineers, DevOps engineers or Site Reliability Engineer (SRE) gain knowledge instantiating and orchestrating a Hyperledger Fabric network.

## What can I expect here

In this projects you will find demonstrators covering aspects of Hyperledger Fabric components you would orchestrate a functioning Hyperledger Fabric network. The basic components you will need to create or orchestrate a Hyperledger Fabric network are:

* Cryptogen and configtxgen -- tools you will use to create crytographic asstes and networking configuration;
* Fabric Certificate Authority (CA);
* Fabric peer and client nodes.

The demonstrators are organised to different topics to help gain knowledge of the internals of the abovementioned components and to illustrates different aspects of orchestrating networks. The demonstrators contains working examples.

* `crypto-configtx` section demonstrate the process of creating cryptographic and networking configurations;
* `fabric-ca` section demonstrates the internal workings of the Fabric CA server interacting via a cli CA client;
* `networking` sections provide working examples illustrating the process of adding a new peer to an existing network, the creation of private data networks and the use of Kafka.

**Note:** Hyperledger Fabric is customisable and you can replaced the official out-of-the-box components with customised one. The components discussed in [here](https://github.com/fabric-devkit/core-platform) are components found in the official out-of-the-box Hyperledger Fabric project.

## How to use this project

1. Clone this project `git clone https://github.com/fabric-devkit/core-platform`.

2. Choose the topics you wish to learn (see links on the left panel).

## Disclaimer

None of the sub projects here are intended for mission critical or production use cases. They are intended purely for demonstration purposes only. If you choose to use it for mission critical and production use cases, you do so at your own risks.

## Copyright Notice

Copyright (c) 2019. The Fabric-DevKit Authors. All rights reserved.
SPDX-License-Identifier: Apache-2.0
