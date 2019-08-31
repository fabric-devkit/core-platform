# Dev Network

Please refer to Fabric's [official documentation](https://hyperledger-fabric.readthedocs.io/en/release-1.4/blockchain.html) to learn about the Fabric network.

This network has been configured to instantiate an organisation comprising one orderer, one certificate authority (ca) and one cli container operating in solo mode. The network can be extended to include a ca-client cli container and/or to include a RESTFul fabric-node-client based container.

# How to use this network?

* [Instantiating the dev network](#runNetwork)
* [Debug chaincode](#debugChaincode)
* [Debug fabric-sdk app](#debugSDK)

## <a name="runNetwork">Instantiating the dev network</a>

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

5. To stop and restart the network from a clean state run the command `./fabricOps.sh clean`.

## <a name="debugChaincode">Debug chaincode</a>

1. Assuming that you have created a repository containing chaincodes in `$GOPATH/src/github.com/project/go-chaincodes` and you package your chaincodes under `$GOPATH/src/github.com/project/go-chaincodes/my-cc`.

2. Modify the file [`.env`](#detEnv), value `CHAINCODE_PATH` to reference `$GOPATH/src/github.com/project/go-chaincodes`.

3. Simply start and re-start you network to have your chaincode installed.

## <a name="debugSDK">Debug SDK app</a>

Please refer to [fabric-node-client](../extensions/fabric-node-client). This is a simple example to illustrate steps for creating a NodeJS based application via fabric-client SDK. This should apply to app written in any other language.

The step for debugging SDK app.

1. Ensure that you have a running network see [here](#runNetwork).

2. Assuming that the node source code is held in `$GOPATH/src/github.com/project/my-node-app` (this is only an example location, you can place it anywhere).

3. Package your app into a Docker image, please follow the [example code](../extensions/fabric-node-client)).
   
4. Modify the functions `unitTestFabricClient()`, `smokeTestFabricClient()` in `fabricOps.sh` accordingly.

5. Modify the file [`docker-compose.fabric-client.yaml`](#fabricClientCompose).

## <a name="addOrg2">Adding Org2</a>

The artefacts needed to support the addition of Org2 are found in the folder [org2](../networks/dev/org2), [docker-compose.org2.yaml](../networks/dev/docker-compose.org2.yaml) and [step1AddOrg2.sh, step2AddOrg2.sh org2Validate.sh](../networks/dev/cli-scripts).

The steps for adding org2 are:

1. Run the command `./fabricOps.sh clean` - this is to ensure that you have a clean network

2. Run `./fabricOps.sh network artefacts`, followed by `./fabricOps.sh network start` and then `./fabricOps.sh network init`.

3. Run `./fabricOps.sh add-org2 artefacts` and followed by `./fabricOps.sh add-org2 join`. You will see console displaying a two step operations. If no error proceed to next step.

4. Run `./fabricOps.sh add-org2 validate`. Ignore the sentence `Error: error sending transaction for invoke: could not send: EOF` and if you see in the console log `proposal response: version:1 response:<status:200 payload:"Payment done" >`, it means org2 has been added. For further confirmation if you run the command `fabricOps.sh status` and if you see a container named `dev-peer0.org-mycc-1.0` it means your org2 has been properly added.

> Note:
> The error message appears to be caused by a bug in the `peer chaincode invoke` command.

# Content

The dev network orchestrator is located [here](../networks/dev)

| Item | Description |
| --- | --- |
| `.env` | Shared orchestrator environmental variables |
| `cli-scripts` | This folder contains scripts to configure the dev network by creating channels, installing and instantiating chaincodes |
| `configtx.yaml` | Channel specification please refer to [crypto-configtx guide for details](./crypto-configtx.md)  |
| `crypto-config.yaml` | Crytographic artefact specification [crypto-configtx guide for details](./crypto-configtx.md) |
| `docker-compose.ca-client.yaml` | An orchestration file for [ca-client-cli container](./fabric-ca.md) |
| `docker-compose.fabric.yaml` | An orchestration file for the dev network |
| `docker-compose.fabric-client.yaml` | An orchestration [file](#fabricClientCompose) for the Fabric client container |
| `docker-compose.org2.yaml` | Orchestration file for org2 that includes one peer and one cli |
| `fabricOps.sh` | Please refer to details [here](#fabricOps) |
| `generate-artefacts.sh` | Script to execute configtxgen and cryptogen tool |
| `network-config.yaml` | Network configuration file specifying fabric components involve in the network |
| `org1.yaml` | A configuration file for a client container connecting to the Fabric network |
| `services.json` | A configuration file intended to help NodeJS based client to read `network-config.yaml` and `org1.yaml` |
| `org2` | This contains artefacts for org2 namely:<br> + `configtx.yaml` channel configuration file for org2:<br> + `org2-crypto.yaml` cryptographic configuration for org2<br> + `generate-artefacts.sh` scripts to be executed as part of `fabricOps.sh` to generate org2 artefacts. |

## <a name="dotEvn">.env</a>

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

## <a name="fabricClientCompose">docker-compose.fabric-client.yaml</a>

This is the main orchestrator for fabric-client.

```
  fabric-client.org1.dev:
    container_name: fabric-client.org1.dev
    image: workingwithblockchain/fabric-client
    volumes:
      - ./network-config.yaml:/opt/network-config.yaml
      - ./org1.yaml:/opt/org1.yaml
      - ./services.json:/opt/services.json
      - ./crypto-config:/opt/crypto-config
      - ./channel-artefacts:/opt/channel-artefacts
      - ../../extensions/fabric-node-client/test:/opt/test
      - ../../extensions/fabric-node-client/wallet:/tmp
```

1. `./network-config.yaml:/opt/network-config.yaml` maps the network configuration (i.e. peer names, addresses, etc.) into the `fabric-client` container.

2. `./org1.yaml:/opt/org1.yaml` maps the client configuration into the `fabric-client` container.

3. `./services.json:/opt/services.json` maps a nodeJS object combining information from `network-config.yaml` and `org1.yaml`.

> Note:
> `network-config.yaml` and `org1.yaml` (there is no default file names, you can name it the way you like) are standardised configuration files for node fabric-client sdk. Please refer to the [official documentation](https://fabric-sdk-node.github.io/release-1.4/index.html#toc0__anchor) for details.

## <a name="fabricOps">fabricOps.sh</a>

The principal network orchestration script to help you spin-up, tear down and add supporting components to the network. It is a Bash script based command line application.

### Commands

This is the top level command

`./fabricOps.sh network <subcommand> | ca-client <subcommand> | fabric-node-client <subcommand> | add-org2 <subcommand> | status | clean`
 
#### `network` command

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

#### `ca-client` command 

Command to add a CA client container to a running Fabric network. 

```
./fabricOps.sh ca-client image | cli | start | clean
```

| Subcommand | Description |
| --- | --- |
| `image` | builds a new Docker image of Fabric CA client tool |
| `cli` | spin up a bash shell of the Fabric CA client |
| `start` | start an instance of Fabric CA client container |
| `clean` | remove instances of Fabric CA client container |

#### `fabric-node-client` command

Command to add a fabric-client instance to a running Fabric network.

```
./fabricOps.sh fabric-node-client image | start | clean
```

| Subcommand | Description |
| --- | --- |
| `image` | Builds a new Docker image of Fabric client tool |
| `start` | start an instance of the Fabric client tool |
| `clean` | remove instance of the Fabric client tool |

#### `add-org2` command

Command to add org2 into the running `dev` network

```
./fabricOps.sh add-org2 artefacts | join 
```
| Subcommand | Description |
| --- | --- |
| `artefacts` | Create `org2` related artefacts |
| `join` | Operations to join `org2` to dev network, this include operations to reconfigure existing channel to facilitating the addition or `org2`. |

#### `status` command

Command to get a list of the status instances running in the network.

```
./fabricOps.sh status
```

#### `clean` command

Command to tear down *all* containers in the Fabric network

```
./fabricOps.sh clean
```
