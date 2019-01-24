const { createTerminus } = require('@godaddy/terminus');

function onSignal () {
  console.log('server is starting cleanup');
  return Promise.all([
    // your clean logic, like closing database connections
  ]);
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
  timeout: 1000,
  onSignal,
  onShutdown
};

function terminus(server) {
   createTerminus(server, options);
}

module.exports = terminus
