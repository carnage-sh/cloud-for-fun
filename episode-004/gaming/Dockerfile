FROM node:11.6.0-alpine

COPY package.json package-lock.json /app/
WORKDIR /app

EXPOSE 8080
RUN npm ci

COPY . /app/

CMD ["npm", "start"]

