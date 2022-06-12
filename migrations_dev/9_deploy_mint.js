const TVT = artifacts.require("TVT/TVT");
const Date = artifacts.require("Date");
const Mint = artifacts.require("Mint");

module.exports = async function (deployer, _network, _accounts) {
  require("dotenv").config();

  const tvt = await TVT.deployed();

  await deployer.deploy(Date);
  await deployer.link(Date, Mint);

  const mint = await deployer.deploy(Mint, tvt.address);

  // await tvt.mint(mint.address, process.env.MINT_INITIAL_SUPPLY);

  console.log("Deployed", mint.address);
};
