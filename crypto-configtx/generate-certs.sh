#!/bin/bash

if [ -d ./assets/crypto-config ]; then
    rm -rf ./assets/crypto-config
fi

mkdir -p ./assets/crypto-config

cryptogen generate --config=./crypto-config.yaml --output="./assets/crypto-config"
