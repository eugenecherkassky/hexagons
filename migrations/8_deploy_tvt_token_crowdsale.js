const Treasury = artifacts.require("Treasury");
const TVTTokenCrowdsale = artifacts.require("TVT/TVTTokenCrowdsale");
const TVTToken = artifacts.require("TVT/TVTToken");

module.exports = async function (deployer) {
  require("dotenv").config();

  const tvt = await TVTToken.deployed();
  const treasury = await Treasury.deployed();

  const crowdsale = await deployer.deploy(
    TVTTokenCrowdsale,
    process.env.TVT_TOKEN_RATE,
    treasury.address,
    tvt.address
  );

  await tvt.grantRole(await tvt.MINTER_ROLE(), crowdsale.address);
};
