require("dotenv").config();

require("chai").use(require("chai-as-promised")).should();
const Web3 = require("web3");

const ContractFactory = require("./ContractFactory");

contract("User", async function ([account]) {
  beforeEach(async function () {
    this.tvt = await ContractFactory.createTVT();
    this.wallet = await ContractFactory.createWallet(this.tvt.address);
    this.user = await ContractFactory.createUser(this.wallet.address);
  });

  describe("Settings", function () {
    it("Wallet price validation", async function () {
      const name = await this.tvt.name();

      name.toString().should.be.equal(process.env.TVT_NAME);
    });

    it("Wallet price validation", async function () {
      const price = await this.wallet.getUserSetUsernamePrice();

      price.toString().should.be.equal("1");
    });

    it("Username changing", async function () {
      const username = "test_account";

      const price = await this.wallet.getUserSetUsernamePrice().should.be
        .fulfilled;

      await this.tvt.approve(
        this.wallet.address,
        Web3.utils.toWei(price.toString(), "ether")
      ).should.be.fulfilled;

      await this.user.setUsername(username, {
        from: account,
        value: Web3.utils.toWei(price.toString(), "ether"),
      }).should.be.fulfilled;

      const profile = await this.user.getProfile();

      username.toString().should.be.equal(profile.username);
    });
  });
});
