const Presale = artifacts.require("Presale");
const TVT = artifacts.require("TVT/TVT");

module.exports = async function (deployer, _network, _accounts) {
  require("dotenv").config();

  const tvt = await TVT.deployed();

  const presale = await deployer.deploy(Presale, tvt.address, false);

  console.log("Deployed", presale.address);
};
