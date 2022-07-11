const { deployProxy } = require("@openzeppelin/truffle-upgrades");

const User = artifacts.require("User");
const Wallet = artifacts.require("Wallet");

module.exports = async function (deployer) {
  const wallet = await Wallet.deployed();

  await deployProxy(User, [wallet.address], {
    deployer,
    initializer: "__User_init",
  });
};
