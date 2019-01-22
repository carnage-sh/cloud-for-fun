const Prometheus = require('prom-client')
const metricsInterval = Prometheus.collectDefaultMetrics()
const onFinished = require('on-finished')

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
const gamingRequestsDistribution = new Prometheus.Histogram({
  name: 'gaming_requests_msecs',
  help: 'distribution of request response time (millisecs)',
  labelNames: ['route', 'method'],
  buckets: [1, 5, 20, 50, 200, 500, 1000]
})
const gamingRequestsSummary = new Prometheus.Summary({
  name: 'gaming_requests_msecs_summary',
  help: 'summary of request response time (millisecs)',
  labelNames: ['route', 'method'],
  percentiles: [0.9, 0.95, 0.99, 0.999],
  maxAgeSeconds: 600,
  ageBuckets: 10
})

const updateScore = (user, val) => {
  gamingScores.set({user: user}, val, Date.now())
}

const middleware = (req, res, next) => {
  req.startTime = Date.now()

  onFinished(req, (err, req) => {
    const time = Date.now() - req.startTime
    gamingRequestsDistribution
      .observe({route: req.path, method: req.method}, time)
    if (req.path === "/version" && req.method === "GET") {
      gamingRequestsSummary
        .observe({route: req.path, method: req.method}, time)
    }
  })
  gamingRequests.inc({route: req.path, method: req.method}, 1, Date.now())
  next()
}

const metrics = (req, res) => {
  res.set('Content-Type', Prometheus.register.contentType)
  res.end(Prometheus.register.metrics())
}

module.exports = { middleware, metrics, updateScore }

