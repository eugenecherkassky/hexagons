require("dotenv").config();

require("chai").use(require("chai-as-promised")).should();

const ContractFactory = require("./ContractFactory");

contract("User", async function () {
  beforeEach(async function () {
    this.tvt = await ContractFactory.createTVT();
    this.wallet = await ContractFactory.createWallet(this.tvt.address);
    this.user = await ContractFactory.createUser(this.wallet.address);
  });

  describe("Settings", function () {
    it("username", async function () {
      const username = "test_account";

      await this.user.setUsername(username);

      const profile = await this.user.getProfile();

      username.toString().should.be.equal(profile.username);
    });
  });
});
