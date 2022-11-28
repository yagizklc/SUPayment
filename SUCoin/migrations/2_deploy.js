// migrations/2_deploy.js
const SUCoin = artifacts.require('SUCoin');

module.exports = async function (deployer) {
  await deployer.deploy(SUCoin);

};