const { deployProxy } = require("@openzeppelin/truffle-upgrades");

require("dotenv").config();

const Launchpool = artifacts.require("Launchpool");
const Mint = artifacts.require("Mint");
const Treasury = artifacts.require("Treasury");
const TVT = artifacts.require("TVT/TVT");
const TVTV = artifacts.require("TVTV/TVTV");
const User = artifacts.require("User");
const Wallet = artifacts.require("Wallet");

module.exports = {
  createLaunchpool: (treasury) => {
    return deployProxy(Launchpool, [treasury], {
      initializer: "__Launchpool_init",
    });
  },
  createMint: (tvt) => {
    return deployProxy(Mint, [tvt], {
      initializer: "__Mint_init",
    });
  },
  createTreasury: (tvt) => {
    return deployProxy(Treasury, [tvt], {
      initializer: "__Treasury_init",
    });
  },
  createTVT: () => {
    return TVT.new(process.env.TVT_NAME, process.env.TVT_SYMBOL);
  },
  createTVTV: () => {
    return deployProxy(
      TVTV,
      [process.env.TVTV_NAME, process.env.TVTV_SYMBOL, process.env.TVTV_URI],
      {
        initializer: "__TVTV_init",
      }
    );
  },
  createUser: (wallet) => {
    return deployProxy(User, [wallet], {
      initializer: "__User_init",
    });
  },
  createWallet: (tvt) => {
    return deployProxy(Wallet, [tvt], {
      initializer: "__Wallet_init",
    });
  },
};
