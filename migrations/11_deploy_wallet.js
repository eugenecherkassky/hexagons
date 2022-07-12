const { deployProxy } = require("@openzeppelin/truffle-upgrades");

const licences = require("../data/licences.json");
const rents = require("../data/rents.json");

const TVT = artifacts.require("TVT/TVT");
const Wallet = artifacts.require("Wallet");

module.exports = async function (deployer) {
  const tvt = await TVT.deployed();

  await deployProxy(Wallet, [tvt.address, licences, rents], {
    deployer,
    initializer: "__Wallet_init",
  });
};
