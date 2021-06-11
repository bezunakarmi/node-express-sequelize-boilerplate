'use strict';
const CustomError = require('../../helpers/customError');

async function login(req, res, next) {
  try {

  } catch (err) {
    next(err);
  }
}

async function logout(req, res, next) {
  try {

  } catch (err) {
    next(new CustomError.Unauthorized(err.message));
  }
}


module.exports = {
  login,
  logout
};
