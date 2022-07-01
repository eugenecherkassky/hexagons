const { deployProxy } = require("@openzeppelin/truffle-upgrades");

const TVTVToken = artifacts.require("TVTV/TVTVToken");
const VotingManager = artifacts.require("VotingManager");

module.exports = async function (deployer) {
  require("dotenv").config();

  const tvtv = await TVTVToken.deployed();

  await deployProxy(VotingManager, [tvtv.address], {
    deployer,
  });
};
