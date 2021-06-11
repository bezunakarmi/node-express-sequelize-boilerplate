'use strict';

const HttpStatus = require('http-status');
const CustomError = require('./customError');

module.exports = handler;

function handler(err, req, res, next) {
  let code;
  if (err instanceof CustomError.NotFound) {
    code = HttpStatus.NOT_FOUND;
    res.status(HttpStatus.NOT_FOUND);
  }
  else if (err instanceof CustomError.BadRequest) {
    code = HttpStatus.BAD_REQUEST;
    res.status(HttpStatus.BAD_REQUEST);
  }
  else if (err instanceof CustomError.Unauthorized) {
    code = HttpStatus.UNAUTHORIZED;
    res.status(HttpStatus.UNAUTHORIZED);
  }
  else {
    code = HttpStatus.BAD_REQUEST;
    res.status(HttpStatus.BAD_REQUEST);
  }

  res.json({
    error: {
      code,
      message: err.message
    },
    success: false
  })
}