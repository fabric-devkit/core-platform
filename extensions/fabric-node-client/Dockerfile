# Test image
FROM node:8.15

COPY ./rest /opt/rest
COPY ./test /opt/test
COPY ./package.json /opt/package.json

RUN cd /opt && \
    npm install --save-dev chai && \
    npm install --save-dev mocha && \
    npm install --save-dev randomstring && \
    npm install --save-dev supertest && \
    npm install --save body-parser && \
    npm install --save express && \
    npm install --save fabric-ca-client && \
    npm install --save fabric-client && \
    npm install --save http && \
    npm install --save log4js

RUN cd /opt && npm install

EXPOSE 8080

CMD ["npm","start"]
