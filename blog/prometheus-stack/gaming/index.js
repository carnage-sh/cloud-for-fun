const express = require('express')
const payloadChecker = require('payload-validator')
const bodyParser = require('body-parser')
const redis = require('redis')
const process = require('process')

const expectedPayload = { score: 0 }
const redis_url = process.env.REDIS_URL || 'redis://localhost:6379'
const client = redis.createClient(redis_url)

const prometheus = require('./prometheus')

const version = require('./version.json')

const app = module.exports = express()

app.use(bodyParser.json())

app.use(prometheus.middleware)

app.get('/version', (req, res) => {
    res.setHeader('content-type', 'application/javascript')
    res.send(JSON.stringify({version: version.version}))
})

app.get('/metrics', prometheus.metrics)

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
    JSON.stringify(req.body))
  prometheus.updateScore(req.params.userId, req.body.score)
  res.setHeader('content-type', 'application/javascript')
  return res.send(req.body)
})

app.listen(8080, '0.0.0.0' , () => {
    console.log(`Gaming App started on 0.0.0.0:8080`)
})

