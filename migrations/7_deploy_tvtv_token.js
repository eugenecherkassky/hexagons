const TVTVToken = artifacts.require("TVTV/TVTVToken");

module.exports = function (deployer) {
  require("dotenv").config();

  deployer.deploy(
    TVTVToken,
    process.env.TVTV_TOKEN_NAME,
    process.env.TVTV_TOKEN_SYMBOL,
    process.env.TVTV_TOKEN_URI
  );
};
