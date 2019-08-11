/*
*/
const chai = require('chai');
const expect = chai.expect;

const randomstring = require('randomstring');

const blockchain = require('../rest/blockchain');

describe(`=== blockchain services smoke test ===`, () => {
    describe('getClient', () => {
        context(`When calling the method blockchain.getClient with enrollmentID "aaa" and secrets "aaa"`, () => {
            it('expects to return a failed object', async () => {
                const result = await blockchain.getClient('aaa', 'aaa');
                expect(result.success).to.be.false;
            });
        });
        context(`When calling the method blockchain.getClient with enrollmentID 'admin' and secrets 'adminpw'`, () => {
            it('expects to return an instance of a successful object', async () => {
                const result = await blockchain.getClient('admin', 'adminpw');
                expect(result.success).to.be.true;
                expect(result.payload).to.be.not.null;
                expect(result.payload.client).to.be.not.null;
                expect(result.payload.enrolledUserObj).to.be.not.null;
            });
        });
    });
    describe('registerUser', () => {
        const randomUser = randomstring.generate();
        context(`when calling the method blockchain.registerUser to register ${randomUser} by admin with enrollmentID 'admin' 
and secrets 'adminpw'`, () => {
            it('expects to return a successful object', async ()=>{
                const clientObject = await blockchain.getClient('admin', 'adminpw');
                expect(clientObject.success).to.be.true;
                const client = clientObject.payload.client;
                const enrolledUserObj = clientObject.payload.enrolledUserObj;
                const result = await blockchain.registerUser(client, enrolledUserObj, randomUser);
                expect(result.success).to.be.true;
                expect(result.payload).to.be.not.null;
                expect(result.payload.registrantID).to.be.not.null;
                expect(result.payload.registrantSecret).to.be.not.null;
            });
        });
    });
    describe('sendProposal', ()=>{
        context(`When proposing fcn: 'pay' with args: '["Paul","1","John"]' and signed 
        by enrollmentID: 'admin', enrollmentSecret: 'adminpw'`, ()=>{
            it('expects to return successful object', async ()=>{
                const clientObject = await blockchain.getClient('admin', 'adminpw');
                expect(clientObject.success).to.be.true;
                const client = clientObject.payload.client;
                const args = ["Paul","1","John"];
                const result = await blockchain.proposeTransaction(client, 'pay', args);
                expect(result.success).to.be.true;
            });
        });

        context(`When commiting proposal`, ()=>{
            it('expects to return success', async ()=>{
                const clientObject = await blockchain.getClient('admin', 'adminpw');
                expect(clientObject.success).to.be.true;
                const client = clientObject.payload.client;
                const args = ["Paul","1","John"];
                const proposalObject = await blockchain.proposeTransaction(client, 'pay', args);
                expect(proposalObject.success).to.be.true;
                const committedObject = await blockchain.commitTransaction(client, proposalObject.payload.txId, proposalObject.payload.proposalResponses, proposalObject.payload.proposal);
                expect(committedObject.success).to.be.true;
                expect(committedObject.payload.commitStatus).to.be.equal('SUCCESS');

                const results = await blockchain.attachEventHub(client, proposalObject.payload.txIDString, 3000);
                expect(results).to.be.a("Array");

            }).timeout(5000);
        });
    });
});



