const express = require('express')
const payloadChecker = require('payload-validator')
const bodyParser = require('body-parser')
const redis = require('redis')
const process = require('process')

const expectedPayload = { score: 0 }
const redis_url = process.env.REDIS_URL || 'redis://localhost:6379'
const client = redis.createClient(redis_url)

const Prometheus = require('prom-client')
const metricsInterval = Prometheus.collectDefaultMetrics()
const gamingRequests = new Prometheus.Counter({
  name: 'gaming_requests_total',
  help: 'number of requests',
  labelNames: ['route', 'method']
})

const version = require('./version.json')

const app = module.exports = express()

app.use(bodyParser.json())

app.use((req, res, next) => {
  gamingRequests.inc({route: req.path, method: req.method})
  next()
})

app.get('/version', (req, res) => {
    res.setHeader('content-type', 'application/javascript')
    res.send(JSON.stringify({version: version.version}))
})

app.get('/metrics', (req, res) => {
  res.set('Content-Type', Prometheus.register.contentType)
  res.end(Prometheus.register.metrics())
})

app.get('/score/:userId', (req, res) => {
  client.get(
    `score:${req.params.userId}`,
    (err, result) => {
      res.setHeader('content-type', 'application/javascript')
      if (err || !result) {
        return res.send(JSON.stringify({score: 0}))
      }
      return res.send(result)
    }
  )
})

app.post('/score/:userId', (req, res) => {
  if (!req.body) {
    return res.status(400).send(
        JSON.stringify({message: 'Bad request'}))
  }
  const result = payloadChecker.validator(
                   req.body,
                   expectedPayload,
                   ['score'],
                   false
                 )
  if (!result.success) {
    return res.status(400).send(
         JSON.stringify({message: 'Bad request'}))
  }
  client.set(
    `score:${req.params.userId}`,
    JSON.stringify(req.body),
    redis.print)

  res.setHeader('content-type', 'application/javascript')
  return res.send(req.body)
})

app.listen(8080, '0.0.0.0' , () => {
    console.log(`Gaming App started on 0.0.0.0:8080`)
})

