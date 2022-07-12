require("dotenv").config();

require("chai").use(require("chai-as-promised")).should();
const Web3 = require("web3");

const licenses = require("../data/licenses");
const rents = require("../data/rents");

const ContractFactory = require("./ContractFactory");

contract("User", async function ([account]) {
  beforeEach(async function () {
    this.tvt = await ContractFactory.createTVT();
    this.wallet = await ContractFactory.createWallet(
      this.tvt.address,
      licenses,
      rents
    );
    this.user = await ContractFactory.createUser(this.wallet.address);
  });

  describe("API", function () {
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

      const balance = await this.tvt.balanceOf(this.wallet.address).should.be
        .fulfilled;

      price.toString().should.be.equal(balance.toString());
    });
  });
});
