const TVT = artifacts.require("TVT/TVT");

module.exports = function (deployer) {
  require("dotenv").config();

  deployer.deploy(
    TVT,
    process.env.TVT_TOKEN_NAME,
    process.env.TVT_TOKEN_SYMBOL
  );
};
