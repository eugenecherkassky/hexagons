const TVTTokenCrowdsale = artifacts.require("TVT/TVTTokenCrowdsale");
const TVTToken = artifacts.require("TVT/TVTToken");

module.exports = async function (deployer) {
  require("dotenv").config();

  const tvtb = await TVTToken.deployed();

  const crowdsale = await deployer.deploy(
    TVTTokenCrowdsale,
    process.env.TVT_TOKEN_RATE,
    tvtb.address
  );

  await tvtb.grantRole(await tvtb.MINTER_ROLE(), crowdsale.address);
};
