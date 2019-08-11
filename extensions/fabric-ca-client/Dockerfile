FROM ubuntu:18.10

RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
        libtool \
        libltdl-dev \
        golang-go \
        git \
        openssl \
        ca-certificates \
        sqlite3

ENV GOPATH /opt/go
ENV PATH "$PATH:$GOPATH/bin"

RUN go get github.com/hyperledger/fabric-ca/cmd/fabric-ca-client



