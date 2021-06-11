'use strict';
const models = require('../../models/index');


const User = models.users;

/***
 *
 * @param userParams
 * @returns {Promise.<*>}
 */

async function createUser(userParams) {
  return await User.create(userParams);
}


/**
 *
 * @param params
 * @returns {Promise.<Model>}
 */
async function findOneUser(params) {
  return User.findOne(params)
}


/**
 *
 * @param params
 * @returns {Promise.<*>}
 */
async function findAllUser(params) {
	return await User.findAll(params);
}

/**
 *
 * @param params
 * @param data
 * @returns {Promise.<*>}
 */
async function updateUser(params, data) {
  return  await User.update(data,
    { where: params });
}

/**
 *
 * @param params
 * @returns {Promise<void | Promise.<number> | Promise | Promise<number> | Promise<void> | *>}
 */
async function deleteUser(params) {
  return User.destroy({ where: params });
}

module.exports = {
  createUser,
  findOneUser,
  findAllUser,
  updateUser,
  deleteUser
};
