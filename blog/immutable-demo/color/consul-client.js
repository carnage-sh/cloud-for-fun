const ip = require('ip')
const os = require('os')
const moment = require('moment')
const request = require('request')
const process = require('process')
const consul = process.env.CONSUL_HOSTNAME || "localhost"

function updateService() {
  const date = new Date();
  const register = {
    ID: `${os.hostname()}`,
    Name: 'color',
    Tags: [ 'api' ],
    Address: `${ip.address()}`,
    Port: 8000
  }

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
  setTimeout(updateService, 10000)
}

module.exports = { updateService }

