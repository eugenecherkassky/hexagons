const { deployProxy } = require("@openzeppelin/truffle-upgrades");

const licenses = require("../data/licenses");
const rents = require("../data/rents");

const TVT = artifacts.require("TVT/TVT");
const Wallet = artifacts.require("Wallet");

module.exports = async function (deployer) {
  const tvt = await TVT.deployed();

  await deployProxy(Wallet, [tvt.address, licenses, rents], {
    deployer,
    initializer: "__Wallet_init",
  });
};
