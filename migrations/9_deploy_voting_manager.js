const { deployProxy } = require("@openzeppelin/truffle-upgrades");

const TVTV = artifacts.require("TVTV/TVTV");
const VotingManager = artifacts.require("VotingManager");

module.exports = async function (deployer) {
  require("dotenv").config();

  const tvtv = await TVTV.deployed();

  await deployProxy(VotingManager, [tvtv.address], {
    deployer,
    initializer: "__VotingManager_init",
  });
};
