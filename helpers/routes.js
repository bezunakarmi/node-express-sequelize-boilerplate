'use strict';

const directory = require('require-dir');

module.exports = {
  route
};

function route(app) {
  let routes = directory('../src/routes');
  for (let i in routes) {
    app.use('/', routes[i]);
  }
}