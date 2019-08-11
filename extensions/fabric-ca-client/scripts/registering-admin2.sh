#!/bin/bash

echo
echo "========================================================="
echo "Enrolling this client with the following credentials"
echo "at fabric-ca-server:7050"
echo "========================================================="
echo
echo "  username: admin"
echo "  password: adminpw"
echo
fabric-ca-client enroll -u https://admin:adminpw@ca.org1.dev:7054
echo "Client enrolled!"
echo

echo
id_attrs='hf.Revoker=true,admin=true:ecert'
echo "====================================================="
echo "Registering a peer following a successful enrollment."
echo "====================================================="
echo
echo " id.type: peer"
echo " id.name: admin2"
echo " id.affliliation: org1.department1"
echo " id.attrs: '$id_attrs'"
echo
fabric-ca-client register --id.type peer --id.name admin2 --id.affiliation org1.department1 --id.attrs $id_attrs

echo
echo "Expected user in database: "
echo " admin"
echo " admin2"
sqlite3 ./fabric-ca-home/fabric-ca-server.db "select * from users"