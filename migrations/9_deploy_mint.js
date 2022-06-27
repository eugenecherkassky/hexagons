const { deployProxy } = require("@openzeppelin/truffle-upgrades");

const Date = artifacts.require("Date");
const Mint = artifacts.require("Mint");
const TVT = artifacts.require("TVT/TVT");

module.exports = async function (deployer) {
  require("dotenv").config();

  const tvt = await TVT.deployed();

  await deployer.deploy(Date);
  await deployer.link(Date, Mint);

  const mint = await deployProxy(Mint, [tvt.address], {
    deployer,
  });

  tvt.transfer(mint.address, process.env.MINT_INITIAL_SUPPLY);
};
