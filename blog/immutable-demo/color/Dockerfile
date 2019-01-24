FROM node:11.6.0-alpine

COPY package.json package-lock.json /app/
WORKDIR /app
ENV CONSUL_HOSTNAME localhost

EXPOSE 8000
RUN npm ci

COPY . /app/

ENTRYPOINT ["node", "./index.js"]

