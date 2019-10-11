#!/bin/bash

sqlite3 ./fabric-ca-server/fabric-ca-server.db "select * from users"