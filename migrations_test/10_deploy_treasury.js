const Treasury = artifacts.require("Treasury");

module.exports = function (deployer) {
  require("dotenv").config();

  deployer.deploy(Treasury, process.env.REACT_APP_CONTRACT_TVT);
};
