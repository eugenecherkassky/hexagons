const { deployProxy } = require("@openzeppelin/truffle-upgrades");

const Date = artifacts.require("Date");
const Launchpool = artifacts.require("Launchpool/Launchpool");
const Mint = artifacts.require("Mint");
const Treasury = artifacts.require("Treasury");

const depositPrograms = require("../test/DepositPrograms");

module.exports = async function (deployer) {
  require("dotenv").config();

  const mint = await Mint.deployed();
  const treasury = await Treasury.deployed();

  await deployer.link(Date, Launchpool);

  const launchpool = await deployProxy(Launchpool, [treasury.address], {
    deployer,
    initializer: "__Launchpool_init",
  });

  launchpool.setDepositPrograms(depositPrograms);

  launchpool.setRefillableSuppliers([
    {
      agreement: mint.address,
      reward: process.env.LAUNCHPOOL_MINT_REFIL_REWARD,
    },
    {
      agreement: treasury.address,
      reward: process.env.LAUNCHPOOL_TREASURY_REFIL_REWARD,
    },
  ]);

  mint.setRecipients([
    {
      agreement: launchpool.address,
      share: 100,
    },
  ]);
};
