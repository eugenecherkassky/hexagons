const TVTBTokenCrowdsale = artifacts.require("TVTB/TVTBTokenCrowdsale");
const TVTBToken = artifacts.require("TVTB/TVTBToken");

module.exports = async function (deployer) {
  require("dotenv").config();

  const tvtb = await TVTBToken.deployed();

  const crowdsale = await deployer.deploy(
    TVTBTokenCrowdsale,
    process.env.TVTB_TOKEN_RATE,
    tvtb.address
  );

  await tvtb.grantRole(await tvtb.MINTER_ROLE(), crowdsale.address);
};
