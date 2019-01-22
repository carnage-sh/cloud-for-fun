const Prometheus = require('prom-client')
const metricsInterval = Prometheus.collectDefaultMetrics()
const gamingRequests = new Prometheus.Counter({
  name: 'gaming_requests_total',
  help: 'number of requests',
  labelNames: ['route', 'method']
})
const gamingScores = new Prometheus.Gauge({
  name: 'gaming_scores',
  help: 'User scores',
  labelNames: ['user']
})

const updateScore = (user, val) => {
  gamingScores.set({user: user}, val, Date.now())
}

const startMiddleware = (req, res, next) => {
  gamingRequests.inc({route: req.path, method: req.method}, 1, Date.now())
  next()
}

const metrics = (req, res) => {
  res.set('Content-Type', Prometheus.register.contentType)
  res.end(Prometheus.register.metrics())
}

const endMiddleware = (req, res, next) => {
  next()
}

module.exports = { startMiddleware, endMiddleware, metrics, updateScore }

