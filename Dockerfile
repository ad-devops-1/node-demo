FROM node:10

RUN mkdir -p /usr/src/app

WORKDIR /usr/src/app

# Bundle app source
COPY . /usr/src/app

# Install app node dependencies
#COPY package.json /usr/src/app
RUN npm install

EXPOSE 7000
CMD ["npm", "start"]
