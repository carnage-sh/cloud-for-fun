const express = require('express')
const version = require('./version.json')
const Prometheus = require('prom-client')
const metricsInterval = Prometheus.collectDefaultMetrics()
const simpleapiCalls = new Prometheus.Counter({
  name: 'simpleapi_requests',
  help: 'number of requests',
  labelNames: ['route', 'method']
})

const app = express()

app.use((req, res, next) => {
  simpleapiCalls.inc({route: req.path, method: req.method})
  next()
})

app.get('/', (req, res) => {
    res.setHeader('content-type', 'application/javascript')
    res.send(JSON.stringify({message: 'OK'}))
})

app.get('/version', (req, res) => {
    res.setHeader('content-type', 'application/javascript')
    res.send(JSON.stringify({version: version.version}))
})

app.get('/metrics', (req, res) => {
  res.set('Content-Type', Prometheus.register.contentType)
  res.end(Prometheus.register.metrics())
})

app.listen(8080, '0.0.0.0' , () => console.log(`Example app listening on 0.0.0.0:8080`))

