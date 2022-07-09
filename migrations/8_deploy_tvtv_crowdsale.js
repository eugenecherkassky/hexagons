const Treasury = artifacts.require("Treasury");
const TVTVCrowdsale = artifacts.require("TVTV/TVTVCrowdsale");
const TVTV = artifacts.require("TVTV/TVTV");

module.exports = async function (deployer) {
  require("dotenv").config();

  const tvtv = await TVTV.deployed();
  const treasury = await Treasury.deployed();

  const crowdsale = await deployer.deploy(
    TVTVCrowdsale,
    process.env.TVTV_RATE,
    treasury.address,
    tvtv.address
  );

  await tvtv.grantRole(await tvtv.MINTER_ROLE(), crowdsale.address);
};
