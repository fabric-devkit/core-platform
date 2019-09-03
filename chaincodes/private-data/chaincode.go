package main

import (
	"encoding/json"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
)

var logger = shim.NewLogger("minimalcc")

// Note that field names must begin with Capitals, or json.Unmarshal will silently fail
type transaction struct {
	ObjectType      string `json:"docType"`
	ProductCode     string `json:"productCode"`
	ProductId       string `json:"productDescription"`
	ProductQuantity int    `json:"productQuantity"`
}

// private elements in the class
type transactionPrivate struct {
	ObjectType   string `json:"docType"`
	ProductCode  string `json:"productCode"`
	ProductPrice int    `json:"productPrice"`
}

// Transaction
func initialise(stub shim.ChaincodeStubInterface) pb.Response {

	// Do nothing, just wait for some transactions to be added

	return shim.Success([]byte("Initialisation completed"))
}

// Add a new transaction including private data.
// First command sets up the transfer object, converting it to base 64 and stripping off any newline characters added by the conversion.
// export TRANSACTION=$(echo -n "{\"productCode\":\"productA\",\"productId\":\"1234\",\"productQuantity\":70,\"productPrice\":100}" | base64 | tr -d \\n)
// peer chaincode invoke -C mychannel -n private-data -c '{"Args":["addTransaction"]}' --transient "{\"transaction\":\"$TRANSACTION\"}" --tls --cafile $ORDERER_CA
func (t *transaction) addTransaction(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error

	// Note that field names must begin with Capitals, or json.Unmarshal will silently fail
	type transactionTransientInput struct {
		ProductCode     string `json:"productCode"`
		ProductId       string `json:"productId"`
		ProductQuantity int    `json:"productQuantity"`
		ProductPrice    int    `json:"productPrice"`
	}

	// ==== Input sanitation ====
	logger.Info("- start init transaction")

	if len(args) != 0 {
		return shim.Error("Incorrect number of arguments. Private transaction data must be passed in transient map.")
	}

	transMap, err := stub.GetTransient()
	if err != nil {
		return shim.Error("Error getting transient: " + err.Error())
	}

	if _, ok := transMap["transaction"]; !ok {
		return shim.Error("transaction must be a key in the transient map")
	}

	if len(transMap["transaction"]) == 0 {
		return shim.Error("transaction value in the transient map must be a non-empty JSON string")
	}

	var transactionInput transactionTransientInput
	err = json.Unmarshal(transMap["transaction"], &transactionInput)
	if err != nil {
		return shim.Error("Failed to decode JSON of: " + string(transMap["transaction"]))
	}

	if len(transactionInput.ProductCode) == 0 {
		return shim.Error("productCode field must be a non-empty string")
	}
	if len(transactionInput.ProductId) == 0 {
		return shim.Error("productId field must be a non-empty string")
	}
	if transactionInput.ProductQuantity <= 0 {
		return shim.Error("productQuantity field must be a positive integer")
	}
	if transactionInput.ProductPrice <= 0 {
		return shim.Error("productPrice field must be a positive integer")
	}

	// ==== Create transaction object, marshal to JSON, and save to state ====
	transaction := &transaction{
		ObjectType:      "transaction",
		ProductCode:     transactionInput.ProductCode,
		ProductId:       transactionInput.ProductId,
		ProductQuantity: transactionInput.ProductQuantity,
	}
	transactionJSONasBytes, err := json.Marshal(transaction)
	if err != nil {
		return shim.Error(err.Error())
	}

	// === Save transaction to state ===
	err = stub.PutPrivateData("collectionTransaction", transaction.ProductCode, transactionJSONasBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

	// ==== Create transaction private details object with price, marshal to JSON, and save to state ====
	transactionPrivateDetails := &transactionPrivate{
		ObjectType:   "transactionPrivate",
		ProductCode:  transactionInput.ProductCode,
		ProductPrice: transactionInput.ProductPrice,
	}
	transactionPrivateDetailsBytes, err := json.Marshal(transactionPrivateDetails)
	if err != nil {
		return shim.Error(err.Error())
	}
	err = stub.PutPrivateData("collectionTransactionPrivate", transactionInput.ProductCode, transactionPrivateDetailsBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

	// ==== Transaction saved and indexed. Return success ====
	logger.Info("- end init transfer")
	return shim.Success(nil)
}

// ===============================================
// readTransaction - read a transaction from chaincode state
// ===============================================
func (t *transaction) readTransaction(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var productCode, jsonResp string
	var err error

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting product code to query")
	}

	productCode = args[0]
	valAsbytes, err := stub.GetPrivateData("collectionTransaction", productCode)
	if err != nil {
		jsonResp = "{\"Error\":\"Failed to get state for " + productCode + "\"}"
		return shim.Error(jsonResp)
	} else if valAsbytes == nil {
		jsonResp = "{\"Error\":\"Transaction does not exist: " + productCode + "\"}"
		return shim.Error(jsonResp)
	}

	return shim.Success(valAsbytes)
}

// ===============================================
// readTransactionPrivateDetails - read private details from chaincode state
// ===============================================
func (t *transaction) readTransactionPrivateDetails(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var productCode, jsonResp string
	var err error

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting product code to query")
	}

	productCode = args[0]
	valAsbytes, err := stub.GetPrivateData("collectionTransactionPrivate", productCode)
	if err != nil {
		jsonResp = "{\"Error\":\"Failed to get private details for " + productCode + ": " + err.Error() + "\"}"
		return shim.Error(jsonResp)
	} else if valAsbytes == nil {
		jsonResp = "{\"Error\":\"Private details does not exist: " + productCode + "\"}"
		return shim.Error(jsonResp)
	}

	return shim.Success(valAsbytes)
}

// Init to initiate the SimpleChaincode class
func (t *transaction) Init(stub shim.ChaincodeStubInterface) pb.Response {
	logger.Info("Hello Init")
	fcn, _ := stub.GetFunctionAndParameters()
	if fcn == "init" {
		return initialise(stub)
	}

	return shim.Error("Fail to initialise state")
}

// Invoke a method specified in the SimpleChaincode class
func (t *transaction) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	logger.Info("Hello Invoke")
	fcn, args := stub.GetFunctionAndParameters()

	if fcn == "addTransaction" {
		return t.addTransaction(stub, args)
	}

	if fcn == "readTransaction" {
		return t.readTransaction(stub, args)
	}

	if fcn == "readTransactionPrivateDetails" {
		return t.readTransactionPrivateDetails(stub, args)
	}

	return shim.Success([]byte("Invoke"))
}

func main() {
	logger.SetLevel(shim.LogInfo)
	err := shim.Start(new(transaction))
	if err != nil {
		logger.Debugf("Error: %s", err)
	}
}
