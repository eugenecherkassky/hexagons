require("dotenv").config();

require("chai").use(require("chai-as-promised")).should();

const Web3 = require("web3");

const licenses = require("../../data/licenses");
const rents = require("../../data/rents");

const ContractFactory = require("../ContractFactory");

contract("TVTL", async function ([account]) {
  beforeEach(async function () {
    this.tvt = await ContractFactory.createTVT();

    this.wallet = await ContractFactory.createWallet(
      this.tvt.address,
      licenses,
      rents
    );

    this.tvtl = await ContractFactory.createTVTL(
      this.wallet.address,
      process.env.TVTL_INITIAL_SUPPLY
    );
  });

  describe("Settings", function () {
    it("Land", async function () {
      const land = await this.tvtl.getLand(1).should.be.fulfilled;

      land.tokenId.should.be.equal("1");
    });
  });

  describe("Api", function () {
    it("Rent", async function () {
      const { price } = await this.wallet.getLandlordRent(0).should.be
        .fulfilled;

      await this.tvt.approve(
        this.wallet.address,
        Web3.utils.toWei(price.toString(), "ether")
      ).should.be.fulfilled;

      const tokenId = 1;

      const { receipt } = await this.tvtl.rent(tokenId, {
        from: account,
        value: Web3.utils.toWei(price.toString(), "ether"),
      }).should.be.fulfilled;

      receipt.logs[2].args.land.tokenId.should.be.equal(tokenId.toString());
    });
  });
});
