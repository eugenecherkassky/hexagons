const Treasury = artifacts.require("Treasury");

module.exports = async function (deployer) {
  require("dotenv").config();

  const treasury = await deployer.deploy(
    Treasury,
    process.env.REACT_APP_CONTRACT_TVT
  );

  // console.log("Deployed", treasury.address);
};
