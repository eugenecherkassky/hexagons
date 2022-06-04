require("dotenv").config();

const Launchpool = artifacts.require("Launchpool");
const Mint = artifacts.require("Mint");
const Treasury = artifacts.require("Treasury");
const TVTToken = artifacts.require("TVT/TVTToken");
const TVTBToken = artifacts.require("TVTB/TVTBToken");

const depositOptions = require("./DepositOptions");

module.exports = {
  createLaunchpool: function (mint, treasury) {
    return Launchpool.new(treasury, depositOptions, [
      {
        agreement: mint,
        reward: process.env.LAUNCHPOOL_MINT_REFIL_REWARD,
      },
      {
        agreement: treasury,
        reward: process.env.LAUNCHPOOL_TREASURY_REFIL_REWARD,
      },
    ]);
  },
  createMint: function (token) {
    return Mint.new(token);
  },
  createTreasury: function (token) {
    return Treasury.new(token);
  },
  createTVTToken: function () {
    return TVTToken.new(
      process.env.TVT_TOKEN_NAME,
      process.env.TVT_TOKEN_SYMBOL,
      process.env.TVT_TOKEN_INITIAL_SUPPLY
    );
  },
  createTVTBToken: function () {
    return TVTBToken.new(
      process.env.TVTB_TOKEN_NAME,
      process.env.TVTB_TOKEN_SYMBOL,
      process.env.TVTB_TOKEN_URI
    );
  },
};
