'use strict';

const CustomError = require('./customError');

const whiteListedUrl = ['/login'];


function authorize(req, res, next) {
  const authorization = req.headers.authorization;
  if (whiteListedUrl.indexOf(req.url) > -1) {
    next();
  }
  else if (!authorization) {
    next(new CustomError.Unauthorized());
  }
  else {
    /**
     * Here middleware logic goes
     */
  }
}

module.exports = authorize;
