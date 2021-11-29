var Registry = artifacts.require('./Registry.sol');
var DataDappContract = artifacts.require('./DataDappContract.sol');

module.exports = function (deployer) {
  deployer.deploy(Registry);
  deployer.deploy(DataDappContract);
};
