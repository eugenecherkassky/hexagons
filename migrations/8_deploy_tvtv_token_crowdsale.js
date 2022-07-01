const Treasury = artifacts.require("Treasury");
const TVTVTokenCrowdsale = artifacts.require("TVTV/TVTVTokenCrowdsale");
const TVTVToken = artifacts.require("TVTV/TVTVToken");

module.exports = async function (deployer) {
  require("dotenv").config();

  const tvtv = await TVTVToken.deployed();
  const treasury = await Treasury.deployed();

  const crowdsale = await deployer.deploy(
    TVTVTokenCrowdsale,
    process.env.TVTV_TOKEN_RATE,
    treasury.address,
    tvtv.address
  );

  await tvtv.grantRole(await tvtv.MINTER_ROLE(), crowdsale.address);
};
