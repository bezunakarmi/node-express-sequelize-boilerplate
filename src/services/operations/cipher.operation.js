'use strict';

const bcrypt = require('bcryptjs');

async function generateHash(password) {
  return bcrypt.hashSync(password, 10)
}

async function compareHash(password, hash) {
  return bcrypt.compareSync(password, hash)
}

module.exports = {
  generateHash,
  compareHash
};
