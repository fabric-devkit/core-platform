const expect = require('chai').expect;
const FabricClient = require('fabric-client');

describe(`=== fabric-client unit testing ===`, ()=>{

  describe('network-config', ()=>{
    const client = FabricClient.loadFromConfig(__dirname + '/fixtures/network-config.yaml');
  
    describe("When I instantiate a fabric client from network-config file", ()=>{
      it('expects to return an instance of a fabric client', ()=>{
        expect(client).to.be.not.null;
      });
    });
  
    describe('Given a properly instantiated client', ()=>{
      const mspid = 'Org1MSP';
      context(`and I invoke the getPeersForOrg() and pass it the value ${mspid}`, ()=>{
        it('expects to return one peer', ()=>{
            expect(client.getPeersForOrg(mspid)).to.have.length(1);
        });
      });
  
      const ordererName = 'orderer.dev';
      context(`and I invoke the getOrderer() and pass it the value ${ordererName}`, ()=>{
        it('expects to return an instance of an orderer', ()=>{
            expect(client.getOrderer(ordererName)).to.be.not.null;
        });
      });
    });
  });
});

