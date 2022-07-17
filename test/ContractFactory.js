const { deployProxy } = require("@openzeppelin/truffle-upgrades");

require("dotenv").config();

const Launchpool = artifacts.require("Launchpool");
const Mint = artifacts.require("Mint");
const Treasury = artifacts.require("Treasury");
const TVT = artifacts.require("TVT/TVT");
const TVTV = artifacts.require("TVTV/TVTV");
const TVTL = artifacts.require("TVTL/TVTL");
const User = artifacts.require("User");
const Wallet = artifacts.require("Wallet/Wallet");

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
  createTVTL: async (wallet, initialSupply) => {
    const tvtl = await deployProxy(
      TVTL,
      [
        process.env.TVTL_NAME,
        process.env.TVTL_SYMBOL,
        process.env.TVTL_URI,
        wallet,
        initialSupply,
      ],
      {
        initializer: "__TVTL_init",
      }
    );

    for (let tokens = 0; tokens < initialSupply; tokens += 25) {
      await tvtl.init(Math.min(25, initialSupply - tokens));
    }

    return tvtl;
  },
  createUser: (wallet) => {
    return deployProxy(User, [wallet], {
      initializer: "__User_init",
    });
  },
  createWallet: (tvt, licenses, rents) => {
    return deployProxy(Wallet, [tvt, licenses, rents], {
      initializer: "__Wallet_init",
    });
  },
};
