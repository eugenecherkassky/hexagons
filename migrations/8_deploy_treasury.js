const TVTToken = artifacts.require("TVT/TVTToken");
const Treasury = artifacts.require("Treasury");

module.exports = async function (deployer, _network, _accounts) {
  const token = await TVTToken.deployed();

  const treasury = await deployer.deploy(Treasury, token.address);

  console.log("Deployed", treasury.address);
};
