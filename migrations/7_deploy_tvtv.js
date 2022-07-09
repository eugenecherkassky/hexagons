const { deployProxy } = require("@openzeppelin/truffle-upgrades");

const TVTV = artifacts.require("TVTV/TVTV");

module.exports = async function (deployer) {
  require("dotenv").config();

  await deployProxy(
    TVTV,
    [process.env.TVTV_NAME, process.env.TVTV_SYMBOL, process.env.TVTV_URI],
    {
      deployer,
      initializer: "__TVTV_init",
    }
  );
};
