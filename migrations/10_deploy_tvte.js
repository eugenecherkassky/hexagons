const { deployProxy } = require("@openzeppelin/truffle-upgrades");

const TVTE = artifacts.require("Landlord/TVTE");

module.exports = async function (deployer) {
  require("dotenv").config();

  await deployProxy(TVTE, [process.env.TVTE_NAME, process.env.TVTE_SYMBOL], {
    deployer,
    initializer: "__TVTE_init",
  });
};
