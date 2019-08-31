# Fabric node client extension

Hyperledger Fabric provides several NodeJS based SDKs to help developers create client apps to connect to the Fabric network and these are:

* `fabric-ca-client`
* `fabric-client`
* `fabric-network`
* `api`

Please refer to [the official documentation](https://fabric-sdk-node.github.io/release-1.4/index.html) for details.

This extension provides a RESTFul API implemented using the `fabric-client` sdk. The implementation includes the following features:

* A simple RESTFul API
* Unit tests
* Smoke tests

> Note:
> This extension is not intended for production or mission critical use cases. It is only for illustrative and educational purpose.

# How to use this extension?

To use the extension to interact with the dev network, here are the steps:

1. Navigate to the [dev network orchestrator](../extensions/fabric-node-client).
2. Ensure that you have a running network, please refer to [dev network guide](./dev-network.md)
3. Run the command `./fabricOps.sh fabric-client image` to build the client image
4. Run the command `./fabricOps.sh fabric-client start` to create an instance of a `fabric-node-client` RESTFul API. You will see a running unit test and smoke test before the client container starts.

# Content

The extension is located [here](../extensions/fabric-node-client).

| Item | Description |
| --- | --- |
| `rest` | A NodeJS express based interface interacting with a Fabric network |
| `test` | Unit and smoke testing scripts |
| `Dockerfile` | Docker image builder |
