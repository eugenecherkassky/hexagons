const TVTBToken = artifacts.require("TVTB/TVTBToken");
const Ballot = artifacts.require("Ballot");

module.exports = async function (deployer, _network, _accounts) {
  require("dotenv").config();

  const token = await TVTBToken.deployed();

  const ballot = await deployer.deploy(Ballot, token.address);

  console.log("Deployed", ballot.address);
};
