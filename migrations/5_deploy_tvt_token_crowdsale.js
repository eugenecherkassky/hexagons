const TVTTokenCrowdsale = artifacts.require("TVT/TVTTokenCrowdsale");
const TVTToken = artifacts.require("TVT/TVTToken");

module.exports = async function (deployer) {
  require("dotenv").config();

  const token = await TVTToken.deployed();

  await deployer.deploy(
    TVTTokenCrowdsale,
    process.env.TVT_TOKEN_RATE,
    token.address
  );
};
