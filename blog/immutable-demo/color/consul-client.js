const ip = require('ip')
const os = require('os')
const moment = require('moment')
const request = require('request')

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
   uri: "http://192.168.1.146:8500/v1/agent/service/register",
   multipart: [{
       'content-type':'application/json',
       body: JSON.stringify(register)
   }]}, function(error, request, body) {
  if (error == null) {
    return console.log(
        `${ip.address()} - - ` +
        `[${moment(date).utc().format('DD/MMM/YYYY:HH:mm:ss ZZ')}] ` +
        `"REGISTER ${os.hostname()}:8000" 200 0 "-" ""`)
  }
  console.log(
      `${ip.address()} - - ` +
      `[${moment(date).utc().format('DD/MMM/YYYY:HH:mm:ss ZZ')}] ` +
      `"REGISTER ***ERROR*** ${error}" 500 0 "-" ""`)
  })
  setTimeout(updateService, 10000)
}

module.exports = { updateService }

