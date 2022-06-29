const Presale = artifacts.require("Presale");
const TVT = artifacts.require("TVT/TVT");

module.exports = async function (deployer) {
  require("dotenv").config();

  const tvt = await TVT.deployed();

  await deployer.deploy(Presale, tvt.address, false);
};
