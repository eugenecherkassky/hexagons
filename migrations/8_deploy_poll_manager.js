const { deployProxy } = require("@openzeppelin/truffle-upgrades");

const TVTBToken = artifacts.require("TVTB/TVTBToken");
const PollManager = artifacts.require("PollManager");

module.exports = async function (deployer) {
  require("dotenv").config();

  const tvtb = await TVTBToken.deployed();

  await deployProxy(PollManager, [tvtb.address], {
    deployer,
  });
};
