# Cryptogen and Configtxgen extension

`cryptogen` and `configtxgen` tools for generating cryptographic and channel materials necessary for the operations of the Fabric network. For more details please refer to Fabric's official documentations:

* [Membership Service Provider (MSP)](https://hyperledger-fabric.readthedocs.io/en/release-1.4/msp.html)
* [Channel configuration](https://hyperledger-fabric.readthedocs.io/en/release-1.4/configtx.html)
* [cryptogen tool](https://hyperledger-fabric.readthedocs.io/en/release-1.4/commands/cryptogen.html)
* [configtxgen](https://hyperledger-fabric.readthedocs.io/en/release-1.4/commands/configtxgen.html)

> Note:
> This extension has no direct links to the dev network. However, it enables you to use it to carry out experimentation with `crypto-config.yaml` and `configtx.yaml` here without impacting the ones found in the dev network. Once you have a configuration that suits your need, you can copy those files to any network orchestrator you like.

# How to use this extension?

1. Modify [configtx.yaml](../extensions/crypto-configtx/configtx.yaml) and [crypto-config.yaml](../extensions/crypto-configtx/crypto-config.yaml) to meet your requirement.
2. Navigate to the [extension](../extensions/crypto-configtx).
3. Execute `test.sh` and this will generate a folder `./assets` where you will find all the required cryptographic and channel artefacts as specified in step 1.

# Content

The extension is located [here](../extensions/crypto-configtx).

| Item | Description |
| --- | --- |
| `configtx.yaml` | This is a file to specify channel configurations and genesis block. Please refer to [official documentation](https://hyperledger-fabric.readthedocs.io/en/release-1.4/commands/configtxgen.html?highlight=configtx.yaml) for use case. |
| `crypto-config.yaml` | This is a file to specify cryptographic artefacts. Please refer to [official documentation](https://hyperledger-fabric.readthedocs.io/en/release-1.4/msp.html#how-to-generate-msp-certificates-and-their-signing-keys) for use case. |
| `generate-artefacts.sh` | This is a supporting script for `test.sh` |
| `test.sh` | This is the principal script for generating cryptographic and channel artefacts |


