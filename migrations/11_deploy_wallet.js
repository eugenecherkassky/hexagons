const { deployProxy } = require("@openzeppelin/truffle-upgrades");

const TVT = artifacts.require("TVT/TVT");
const Wallet = artifacts.require("Wallet");

module.exports = async function (deployer) {
  const tvt = await TVT.deployed();

  await deployProxy(Wallet, [tvt.address], {
    deployer,
    initializer: "__Wallet_init",
  });
};
