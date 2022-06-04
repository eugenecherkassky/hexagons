const TVTBToken = artifacts.require("TVTB/TVTBToken");

module.exports = function (deployer) {
  require("dotenv").config();

  deployer.deploy(
    TVTBToken,
    process.env.TVTB_TOKEN_NAME,
    process.env.TVTB_TOKEN_SYMBOL,
    process.env.TVTB_TOKEN_URI
  );
};
