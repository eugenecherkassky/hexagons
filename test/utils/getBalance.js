module.exports = async function (address) {
  const balance = await web3.eth.getBalance(address);

  return new web3.utils.BN(balance);
};
