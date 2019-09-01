#!/bin/bash

sqlite3 ./fabric-ca-home/fabric-ca-server.db "select * from users"