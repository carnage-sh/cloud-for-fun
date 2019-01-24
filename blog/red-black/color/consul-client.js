const ip = require('ip')
const os = require('os')
const moment = require('moment')
const request = require('request')
const process = require('process')
const { createTerminus } = require('@godaddy/terminus');

const consul = process.env.CONSUL_HOSTNAME || "localhost"
let registrationEnabled = true
let apiName = "color"

function maintenanceService(resolve, reject, callback) {
  registrationEnabled = false
  console.error('Trying to disconnect...')
  const date = new Date()
  request({
      method: 'PUT',
      uri: `http://${consul}:8500/v1/agent/service/maintenance/${apiName}-${os.hostname()}?enable=true`,
   }, (error, response, body) => {
      if (error == null) {
        console.log(
         `${ip.address()} - - ` +
         `[${moment(date).utc().format('DD/MMM/YYYY:HH:mm:ss ZZ')}] ` +
         `"MAINTENANCE for ${apiName}-${os.hostname()}" ${response.statusCode} 0 "-" ""`)
        return callback(resolve, reject)
      }
      console.log(
       `${ip.address()} - - ` +
       `[${moment(date).utc().format('DD/MMM/YYYY:HH:mm:ss ZZ')}] ` +
       `"MAINTENANCE for ${apiName}-${os.hostname()} ***ERROR*** ${error}" 500 0 "-" ""`)
      return reject()
  })
}

function deregisterService(resolve, reject) {
  const date = new Date()
  request({
      method: 'PUT',
      uri: `http://${consul}:8500/v1/agent/service/deregister/${apiName}-${os.hostname()}`,
   }, (error, response, body) => {
      if (error == null) {
        console.log(
         `${ip.address()} - - ` +
         `[${moment(date).utc().format('DD/MMM/YYYY:HH:mm:ss ZZ')}] ` +
         `"DEREGISTER ${apiName}-${os.hostname()}" ${response.statusCode} 0 "-" ""`)
        return setTimeout(resolve, 3000)
      }
      console.log(
       `${ip.address()} - - ` +
       `[${moment(date).utc().format('DD/MMM/YYYY:HH:mm:ss ZZ')}] ` +
       `"DEREGISTER ***ERROR*** ${error}" 500 0 "-" ""`)
      return reject()
  })
}

function onSignal () {
  console.log('server is starting cleanup');
  return new Promise((resolve, reject) => {
    maintenanceService(resolve, reject, deregisterService)
  })
}

function onShutdown () {
  console.log('cleanup finished, server is shutting down');
}

function healthCheck () {
  return Promise.resolve()
}

const options = {
  healthChecks: {
    '/healthcheck': healthCheck
  },
  timeout: 5000,
  onSignal,
  onShutdown
};

function registerService() {
  const date = new Date();
  const register = {
    ID: `${apiName}-${os.hostname()}`,
    Name: apiName,
    Notes: `The ${apiName} API`,
    Tags: [
      'traefik.enable=true',
      'traefik.frontend.entryPoints=http',
      'traefik.frontend.rule=Host:localhost'
    ],
    Address: ip.address(),
    Port: 8000,
    DeregisterCriticalServiceAfter: "3m",
    check: {
      id: `${apiName}-api`,
      Name: `${apiName}-api`,
      Notes : "HTTP API on port 8000 with route /healthcheck",
      http: `http://${ip.address()}:8000/healthcheck`,
      interval: "10s",
      timeout: "2s"
    }
  }

  if (registrationEnabled === true) {
  request({
   method: 'PUT',
   uri: `http://${consul}:8500/v1/agent/service/register`,
   body: JSON.stringify(register)
   }, function(error, response, body) {
  if (error == null) {
    return console.log(
        `${ip.address()} - - ` +
        `[${moment(date).utc().format('DD/MMM/YYYY:HH:mm:ss ZZ')}] ` +
        `"REGISTER ${os.hostname()}:8000" ${response.statusCode} 0 "-" ""`)
  }
  console.log(
      `${ip.address()} - - ` +
      `[${moment(date).utc().format('DD/MMM/YYYY:HH:mm:ss ZZ')}] ` +
      `"REGISTER ***ERROR*** ${error}" 500 0 "-" ""`)
  })
  setTimeout(registerService, 10000)
  }
}

function manageConsul(server, api) {
  createTerminus(server, options);
  setTimeout(registerService, 5000)
}

module.exports = manageConsul

