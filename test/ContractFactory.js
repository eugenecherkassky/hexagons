const { deployProxy } = require("@openzeppelin/truffle-upgrades");

require("dotenv").config();

const Launchpool = artifacts.require("Launchpool");
const Mint = artifacts.require("Mint");
const Treasury = artifacts.require("Treasury");
const TVTToken = artifacts.require("TVT/TVTToken");
const TVTBToken = artifacts.require("TVTB/TVTBToken");

module.exports = {
  createLaunchpool: (treasury) => {
    return deployProxy(Launchpool, [treasury]);
  },
  createMint: (tvt) => {
    return deployProxy(Mint, [tvt]);
  },
  createTreasury: (tvt) => {
    return deployProxy(Treasury, [tvt]);
  },
  createTVTToken: () => {
    return TVTToken.new(
      process.env.TVT_TOKEN_NAME,
      process.env.TVT_TOKEN_SYMBOL,
      process.env.TVT_TOKEN_INITIAL_SUPPLY
    );
  },
  createTVTBToken: () => {
    return TVTBToken.new(
      process.env.TVTB_TOKEN_NAME,
      process.env.TVTB_TOKEN_SYMBOL,
      process.env.TVTB_TOKEN_URI
    );
  },
};
