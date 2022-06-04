const TVTToken = artifacts.require("TVT/TVTToken");
const Date = artifacts.require("Date");
const Mint = artifacts.require("Mint");

module.exports = async function (deployer, _network, _accounts) {
  require("dotenv").config();

  const token = await TVTToken.deployed();

  await deployer.deploy(Date);
  await deployer.link(Date, Mint);

  const mint = await deployer.deploy(Mint, token.address);

  await token.mint(mint.address, process.env.MINT_INITIAL_SUPPLY);

  console.log("Deployed", mint.address);
};
