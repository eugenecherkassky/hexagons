const { deployProxy } = require("@openzeppelin/truffle-upgrades");

const TVTL = artifacts.require("Landlord/TVTL");
const Wallet = artifacts.require("Wallet");

const lands = require("../data/lands.json");
const licences = require("../data/licences.json");

module.exports = async function (deployer) {
  require("dotenv").config();

  const wallet = await Wallet.deployed();

  await deployProxy(
    TVTL,
    [
      process.env.TVTL_NAME,
      process.env.TVTL_SYMBOL,
      process.env.TVTL_URI,
      lands,
      licences,
      wallet.address,
    ],
    {
      deployer,
      initializer: "__TVTL_init",
    }
  );
};
