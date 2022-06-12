const TVTBTokenCrowdsale = artifacts.require("TVTB/TVTBTokenCrowdsale");
const TVTBToken = artifacts.require("TVTB/TVTBToken");

module.exports = async function (deployer, _network, _accounts) {
  require("dotenv").config();

  const token = await TVTBToken.deployed();

  const crowdsale = await deployer.deploy(
    TVTBTokenCrowdsale,
    process.env.TVTB_TOKEN_RATE,
    token.address
  );

  console.log("Deployed", crowdsale.address);
};
