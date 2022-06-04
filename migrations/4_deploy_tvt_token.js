const TVTToken = artifacts.require("TVT/TVTToken");

module.exports = function (deployer) {
  require("dotenv").config();

  deployer.deploy(
    TVTToken,
    process.env.TVT_TOKEN_NAME,
    process.env.TVT_TOKEN_SYMBOL,
    process.env.TVT_TOKEN_INITIAL_SUPPLY
  );
};
