const Date = artifacts.require("Date");
const Mint = artifacts.require("Mint");

module.exports = async function (deployer) {
  require("dotenv").config();

  await deployer.deploy(Date);
  await deployer.link(Date, Mint);

  deployer.deploy(Mint, process.env.REACT_APP_CONTRACT_TVT);
};
