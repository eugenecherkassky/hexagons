const TVT = artifacts.require("TVT/TVT");
const Treasury = artifacts.require("Treasury");

module.exports = async function (deployer, _network, _accounts) {
  const tvt = await TVT.deployed();

  const treasury = await deployer.deploy(Treasury, tvt.address);

  console.log("Deployed", treasury.address);
};
