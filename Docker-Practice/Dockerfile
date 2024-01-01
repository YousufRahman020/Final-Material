FROM node:19-alpine

COPY package.json /App/
COPY src /App/

WORKDIR /App

RUN npm install

CMD ["node", "server.js"]
