const express = require('express')
const process = require('process')
const morgan  = require('morgan')
const version = require('./version.json')
const http = require('http')
const consul = require('./consul-client')
const argv = require('minimist')(process.argv.slice(2));
const color = argv["color"] || "red"

const app = module.exports = express()

app.use(morgan('combined'))

app.get('/version', (req, res) => {
    res.setHeader('content-type', 'application/json')
    res.send(JSON.stringify({version: version.version}))
})

app.get('/', (req, res) => {
    res.setHeader('content-type', 'application/json')
    res.send(JSON.stringify({color}))
})

const server = http.createServer(app);

consul(server, "color")

server.listen(8000, '0.0.0.0' , () => {
    console.log(`Gaming App started on 0.0.0.0:8000`)
})

