const consul = require('./express-consul')
const express = require('express')
const morgan  = require('morgan')
const process = require('process')
const version = require('./version.json')

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

consul(app, "color")

