'use strict';

let jwt = require('jsonwebtoken');

/**
 * Decode the jwt token
 * @param token{String}
 * @param secretKey{String}
 */
async function decode(token, secretKey) {
  return new Promise(function (resolve, reject) {
    jwt.verify(token, secretKey, function (err, payload) {
      if (err) {
        reject(err)
      } else {
        resolve(payload)
      }
    });
  });
}

/**
 * Create a jwt token
 * @param user{Object}
 * @param secretKey{String}
 * @param expiresIn{Object}
 */
async function encode(user, secretKey, expiresIn={}) {
  const payload = {
    id: user.id,
    name: user.name,
    email: user.email,
    role: user.role,
    active: user.active
  };
  return new Promise(function (resolve, reject) {
    jwt.sign(payload, secretKey, expiresIn ,function (err, token) {
      if (err) {
        reject(err);
      } else {
        resolve(token);
      }
    });
  });
}

module.exports = {
  decode,
  encode
};
