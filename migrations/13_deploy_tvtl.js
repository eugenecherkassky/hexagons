const { deployProxy } = require("@openzeppelin/truffle-upgrades");

const TVTL = artifacts.require("Landlord/TVTL");
const Wallet = artifacts.require("Wallet");

module.exports = async function (deployer) {
  require("dotenv").config();

  const wallet = await Wallet.deployed();

  const tvtl = await deployProxy(
    TVTL,
    [
      process.env.TVTL_NAME,
      process.env.TVTL_SYMBOL,
      process.env.TVTL_URI,
      wallet.address,
      process.env.TVTL_INITIAL_SUPPLY,
    ],
    {
      deployer,
      initializer: "__TVTL_init",
    }
  );

  const initialSupply = +process.env.TVTL_INITIAL_SUPPLY;

  for (let tokens = 0; tokens < initialSupply; tokens += 25) {
    await tvtl.init(Math.min(25, initialSupply - tokens));
  }
};
