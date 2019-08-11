const log4js = require('log4js');
const logger = log4js.getLogger('FabricRESTFul');
logger.level = 'debug';

const express = require('express');
const app = express();
const bodyParser = require('body-parser');
// support parsing application/json type post data
app.use(bodyParser.json()); 
//support parsing of application/x-www-form-urlencoded post data
app.use(bodyParser.urlencoded({
    extended: false
}));

app.use((req, res, next) => {
    logger.debug('New request for %s', req.originalUrl);
    return next();
});

const http = require('http');

const port = 8080;

const server = http.createServer(app).listen(port, ()=>{});
logger.info('Server started at %s', port);
server.timeout = 240000;

const blockchain = require('./blockchain');

app.post('/register', async (req, res)=>{
  logger.debug('==================== ENROLL ==================');
  const adminName = req.body.adminName;
  const adminPassword = req.body.adminPassword;
  const registrantName = req.body.registrantName;

  logger.debug('Username is: ' + adminName);
  logger.debug('Password is: ' + adminPassword);
  logger.debug('Registrant is: ' + registrantName);

  let result = null;
  const clientObj = await blockchain.getClient(adminName, adminPassword);
  if (clientObj.success) {
    
    const registerUserObj = await blockchain.registerUser(clientObj.payload.client, clientObj.payload.enrolledUserObj, registrantName);
    console.log(registerUserObj);
    result = {
      success: 200,
      message: {
        registrantID: registrantName,
		    registrantSecret: registerUserObj.payload.registrantSecret
      }
    }

  }else{
    result = {
      success: 500,
      message: `Unable to register ${registrantName}`
    };
  }
  
  res.send(result);
  
});

app.post('/invoke', async (req, res) => {
	logger.debug('==================== INVOKE ON CHAINCODE ==================');

  const enrollmentName = req.body.enrollmentName;
  const enrollmentSecrets = req.body.enrollmentSecrets;
	const fcn = req.body.fcn;
	const args = req.body.args;

  logger.debug('enrollmentName : ' + enrollmentName);
  logger.debug('enrollmentSecrets: ' + enrollmentSecrets);
	logger.debug('fcn  : ' + fcn);
	logger.debug('args  : ' + args);

  const clientObject = await blockchain.getClient(enrollmentName, enrollmentSecrets);
  if (!clientObject.success){
    res.send({
      success: 500, 
      message: "Unable to enroll users"});
  }

  const proposalObject = await blockchain.proposeTransaction(clientObject.payload.client, fcn, args);
  if (!proposalObject.success){
    res.send({
      success: 500, 
      message: "Unable to commit your transaction"});
  }
  
  const committedObject = await blockchain.commitTransaction(clientObject.payload.client, proposalObject.payload.txId, proposalObject.payload.proposalResponses, proposalObject.payload.proposal);
  if (!committedObject.success){
    res.send({
      success: 500, 
      message: "Unable to commit your transaction"});
  }

  if (committedObject.payload.commitStatus == 'SUCCESS'){
    const results = await blockchain.attachEventHub(clientObject.payload.client, proposalObject.payload.txIDString, 3000);
    res.send({
      success: 200, 
      message: results});
  }
  
  res.send({
    success: 500,
    message: 'Unable to commit'});
});

// Invoke transaction on chaincode on target peers
app.post('/query', async (req, res) => {
	logger.debug('==================== QUERY ON CHAINCODE ==================');

  const enrollmentName = req.body.enrollmentName;
  const enrollmentSecrets = req.body.enrollmentSecrets;
	const fcn = req.body.fcn;
	const args = req.body.args;

  logger.debug('enrollmentName : ' + enrollmentName);
  logger.debug('enrollmentSecrets: ' + enrollmentSecrets);
	logger.debug('fcn  : ' + fcn);
	logger.debug('args  : ' + args);

  const clientObject = await blockchain.getClient(enrollmentName, enrollmentSecrets);
  if (!clientObject.success){
    res.send({
      success: 500, 
      message: "Unable to enroll users"});
  }


  const queryObject = await blockchain.queryChaincode(clientObject.payload.client, fcn,args);
  if (!queryObject.success){
    res.send({
      success: 500,
      message: queryObject.message
    });
  }

  console.log(queryObject.payload.responses);
  res.send({
    success: 200,
    message: queryObject.payload.responses
  });

});

app.get('/blocks', async (req, res)=>{
  logger.debug('================ BLOCK INFO ===================');
  const blockInfoObject = await blockchain.blockInfo();
  if (!blockInfoObject.success){
    res.send({
      success: 500,
      message: blockInfoObject.message
    });
  }

  res.send({
      success: 200,
      message: blockInfoObject.payload.result
  });

});

// Invoke transaction on chaincode on target peers
app.get('/blocks/:blockNumber', async (req, res) => {
	logger.debug('==================== BLOCK INFO BY BLOCK NUMBER ==================');

  const blockNumber = req.params.blockNumber;

	logger.debug('blockNumber  : ' + blockNumber);

  const blockObject = await blockchain.getBlockByNumber(blockNumber);
  if (!blockObject.success){
    res.send({
      success: 500,
      message: blockObject.message
    });
  }

  res.send({success: 200, data: blockObject.payload.reponse});
});

// Invoke transaction on chaincode on target peers
app.get('/transactions/:trxHash', async (req, res) => {
	logger.debug('==================== BLOCK INFO BY BLOCK HASH ==================');

  const trxHash = req.params.trxHash;

	logger.debug('trxHash  : ' + trxHash);

  const blockData = await blockchain.getBlockByHash(trxHash);
  logger.debug('Block found : ' + blockData);
  res.json({success: 200, data: blockData});
});