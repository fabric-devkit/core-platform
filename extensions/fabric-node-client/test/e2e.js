const request = require('supertest');
const agent = request.agent('http://fabric-client.org1.dev:8080');

describe('== End to end testing ==', () => {

    context('POST /register', () => {
        const randomstring = require('randomstring');
        const registrantName = randomstring.generate();
        it(`expects to return 200 with a body {
        registrantName: ${registrantName}
        registrantSecret: <to be generated>
    }`, (done) => {
            agent
                .post('/register')
                .send({
                    adminName: 'admin',
                    adminPassword: 'adminpw',
                    registrantName: registrantName
                })
                .set('Accept', 'application/json')
                .expect(200, done)
        });
    });

    context('POST /invoke', () => {
        it(`expects to return 200`, (done) => {
            agent
                .post('/invoke')
                .send({
                    enrollmentName: 'admin',
                    enrollmentSecrets: 'adminpw',
                    fcn: 'pay',
                    args: ['Paul','1','John']
                })
                .set('Accept', 'application/json')
                .expect(200, done)
        }).timeout(5000);
    });

    context('POST /query', ()=>{
        it(`expects to return 200`, (done)=>{
            agent
                .post('/query')
                .send({
                    enrollmentName: 'admin',
                    enrollmentSecrets: 'adminpw',
                    fcn: 'query',
                    args: ['Paul']                    
                })
                .set('Accept', 'application/json')
                .expect(200, done);
        });
    });

    context('GET /blocks', ()=>{
        it(`expects to return 200`, (done)=>{
            agent
                .get('/blocks')
                .expect(200, done);
        });
    });

    context('GET /blocks/1', ()=>{
        it(`expects to return 200`, (done)=>{
            agent
                .get('/blocks/1')
                .expect(200, done);
        });
    });

});
