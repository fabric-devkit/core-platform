# Fabric Developers' Kit - Helper

This is a component of a developers' kit intended to help developers and platform engineers:

* understand the system architecture of Hyperledger Fabric through a series of smoke tests and reference networks;
* to define, instantiate and configure a Fabric network to support development effort;
* learn to orchestrate a Kafka based Fabric network;
* debug chaincodes and client apps.

# Prerequisite

1. Knowledge of [Docker](https://docs.docker.com/).

2. Set up as you would for [Go chaincode development](https://github.com/workingwithblockchain/writing-go-chaincodes#setupDevEnv)

3. Verify that you have a root directory referenced by `$GOPATH` environment variable containing these directories:
```
drwxr-xr-x  3 <userid>  <groupid>  102  3 Feb 15:44 bin
drwxr-xr-x  3 <userid>  <groupid>  102  3 Feb 15:44 pkg
drwxr-xr-x  3 <userid>  <groupid>  102  3 Feb 15:44 src
```

4. Navigate to `$GOPATH` and clone this repository via this command:
```
go get github.com/workingwithblockchain/fabric-devkit
```

5. Navigate to the path `$GOPATH/src/github.com/workingwithblockchain/fabric-devkit` and you will find the toolkits.

# How to use the DevKit

| User story | Guide |
| --- | --- |
| As a developer, I would like to be able to spin up a small Fabric network locally, so I can use it to debug my chaincode and client app. | [dev network guide](./guides/dev-network.md)|
| As a platform engineer, I would like to see a fairly realistic working Kafka based Fabric network, so I can learn to set-up one. | [kafka network guide](./guides/kafka-network.md) |
| As a platform engineer, I would like to be able to conduct experiment with Fabric's cryptogen and configtxgen toolkit and associated configuration files without the need for complex set-up. | [crypto-configtx guide](./guides/crypto-configtx.md) |
| As a platform engineer, I would like to be able to inspect the internals of an operational Fabric Certificate Authority (CA) whilst performing enrollment and registration, so I know how to debug the CA. | [Fabric CA guide](./guides/fabric-ca.md) |
| As a developer, I would like to be able to inspect the internals of an operational Fabric Certificate Authority (CA) whilst performing enrollment and registration, so I can diagnose problems caused by my application whilst interacting with the CA. | [Fabric CA guide](./guides/fabric-ca.md) |
| As a developer, I would like to have a pre-built simple RESTful nodeJS based component that is able to interact with the reference networks, so I learn to create apps using `fabric-client` sdk. | [fabric-node-client guide](./guides/fabric-node-client.md)|
| As a platform engineer, I would like to have a simple code showing me the steps involved in adding a new organisation `org2` to the dev network, so I can learn to create my own scripts. | [dev network guide](./guides/dev-network.md#addOrg2) |

# Content

| Item | Description |
| --- | --- |
| `chaincodes` | A collection of simple Go chaincodes intended primarily to smoke test the preconfigured networks.<br> + `minimalcc` this is the default chaincode package used to smoke test the [dev network](./guides/dev-network) <br> + `one` and `two` are chaincode packages used to smoke test the [kafka network](.guides/kafka-network) |
| `extensions` | These are collections of scripts intended to expand the features of the predefined networks. |
| `guides` | User guides. |
| `networks` | Preconfigured Fabric network orchestrators. |

# Release Notes

| Version | Features | Status |
| --- | --- | --- |
| 0.1 | + Code to demonstrate process of adding a new organisation to the existing channel in the `dev` network. | + Under development<br> + See master branch. |

# Disclaimer

The sample codes presented in this `DevKit` are intended only to explain concepts and are **not** intended for use in a mission critical or production environment. Should you choose to reproduce the code for production use, you do so at your own risk.

Unless otherwise specified, the artefacts in this repository are distributed under Apache 2 license.

All artefacts found here are provided on "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.