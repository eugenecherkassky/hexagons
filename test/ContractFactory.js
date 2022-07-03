const { deployProxy } = require("@openzeppelin/truffle-upgrades");

require("dotenv").config();

const Launchpool = artifacts.require("Launchpool");
const Mint = artifacts.require("Mint");
const Treasury = artifacts.require("Treasury");
const TVT = artifacts.require("TVT/TVT");
const TVTVToken = artifacts.require("TVTV/TVTVToken");

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
    return TVT.new(process.env.TVT_TOKEN_NAME, process.env.TVT_TOKEN_SYMBOL);
  },
  createTVTVToken: () => {
    return TVTVToken.new(
      process.env.TVTV_TOKEN_NAME,
      process.env.TVTV_TOKEN_SYMBOL,
      process.env.TVTV_TOKEN_URI
    );
  },
};
