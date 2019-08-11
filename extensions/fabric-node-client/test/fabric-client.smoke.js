const expect = require('chai').expect;

const path = require('path');
const fs = require('fs');

const FabricClient = require('fabric-client');

const randomstring = require('randomstring');

const kvsPath = '/tmp/fabric-client-kv-org1';
const cryptoPath = '/tmp/fabric-client-crypto-org1';

describe(`=== fabric-client smoke testing ===`, ()=>{

    describe('register-user', ()=>{
        const networkConfig = path.join(__dirname, '..','network-config.yaml');
        const client = FabricClient.loadFromConfig(networkConfig);
        describe(`Given fabric client class and I instantatiate a client by loading the class with ${networkConfig}`, ()=>{
            it(`expects the instance to exists`, ()=>{
                expect(client).to.be.not.null;
            });
        });
    
        const clientConfig = path.join(__dirname, '..', 'org1.yaml');
        describe(`Using the instantiate client, I load it with ${clientConfig}`, ()=>{
            client.loadFromConfig(clientConfig);
            it(`expects the the client context attribute _adminSigningIdentity`, ()=>{
                expect(client._network_config._client_context._adminSigningIdentity).to.be.not.null;
            });
        });
    
        before(()=>{
            if (fs.existsSync(kvsPath)){
                const files = fs.readdirSync(kvsPath);
                files.forEach((item)=>{
                    const itemPath = path.join(kvsPath,item);
                    fs.unlinkSync(itemPath);
                });
                fs.rmdirSync(kvsPath);
            }
            if (fs.existsSync(cryptoPath)){
                const files = fs.readdirSync(cryptoPath);
                files.forEach((item)=>{
                    const itemPath = path.join(cryptoPath,item);
                    fs.unlinkSync(itemPath);
                });
                fs.rmdirSync(cryptoPath)
            }
        });
        describe('Having loaded the instance with client configuration and instantiating the credential store', ()=>{
            context('and instantiating the credential store', ()=>{
                it(`expects to create an empty key value store in ${kvsPath}`, async ()=>{
                    await client.initCredentialStores();
                    const result = fs.existsSync(kvsPath);
                    expect(result).to.be.true;
                });
            });
    
            let enrolledUser = null;
            context('and I enrol "admin" with "password"', ()=>{
            
                it(`expects the existence of admin user context in ${kvsPath}`, async ()=>{
                    enrolledUser = await client.setUserContext({username: "admin", password: "adminpw"});
                    const adminContextPath = path.join(kvsPath,'admin');
                    const result = fs.existsSync(adminContextPath);
                    expect(result).to.be.true;
                }).timeout(1000);
                
                it(`expects the existence of private key in ${cryptoPath}`, ()=>{
                    const keyFiles = fs.readdirSync(cryptoPath);
                    let failed = false;
                    keyFiles.forEach((item)=>{
                        if (item.includes('-priv')){
                            failed = true
                        }
                    });
                    expect(failed).to.be.true
                });
    
                it(`expects the existence of public key in ${cryptoPath}`, ()=>{
                    const keyFiles = fs.readdirSync(cryptoPath);
                    let failed = false;
                    keyFiles.forEach((item)=>{
                        if (item.includes('-pub')){
                            failed = true
                        }
                    });
                    expect(failed).to.be.true
                });
            });
    
            let ca = null;
            context(`and I ask for a handle to the certificate authority`, ()=>{
                it('expects a ca handle to exists', ()=>{
                    ca = client.getCertificateAuthority();
                    expect(ca).to.be.not.null;
                })
            });
    
            const randomUser = randomstring.generate();
            context(`and I elect to register a user named ${randomUser} via the ca`, ()=>{
                it('expects the ca to return "test" user to return a password ', async ()=>{
                    const secret = await ca.register({
                        enrollmentID: randomUser,
                        affiliation: 'org1.department1'
                    }, enrolledUser);
                    expect(secret).to.be.not.null;
                });
            });    
        });
    });
});

