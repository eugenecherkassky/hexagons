const { deployProxy } = require("@openzeppelin/truffle-upgrades");

const licensesParams = require("../data/licensesParams");
const rentsParams = require("../data/rentsParams");

const TVT = artifacts.require("TVT/TVT");
const Wallet = artifacts.require("Wallet");

module.exports = async function (deployer) {
  const tvt = await TVT.deployed();

  await deployProxy(Wallet, [tvt.address, licensesParams, rentsParams], {
    deployer,
    initializer: "__Wallet_init",
  });
};
