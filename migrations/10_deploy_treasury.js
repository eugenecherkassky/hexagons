const { deployProxy } = require("@openzeppelin/truffle-upgrades");

const Treasury = artifacts.require("Treasury");
const TVT = artifacts.require("TVT/TVT");

module.exports = async function (deployer) {
  const tvt = await TVT.deployed();

  await deployProxy(Treasury, [tvt.address], {
    deployer,
  });
};
