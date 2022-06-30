require("dotenv").config();
const Web3 = require("web3");

require("chai").use(require("chai-as-promised")).should();

const ContractFactory = require("../ContractFactory");

const TVTBTokenCrowdsale = artifacts.require("TVTB/TVTBTokenCrowdsale");

contract("TVTBTokenCrowdsale", async function ([account]) {
  beforeEach(async function () {
    this.tvt = await ContractFactory.createTVT();
    this.treasury = await ContractFactory.createTreasury(this.tvt.address);
    this.tvtb = await ContractFactory.createTVTBToken();

    this.crowdsale = await TVTBTokenCrowdsale.new(
      process.env.TVTB_TOKEN_RATE,
      this.treasury.address,
      this.tvtb.address
    );

    await this.tvtb.grantRole(
      await this.tvtb.MINTER_ROLE(),
      this.crowdsale.address
    );
  });

  describe("Config validation", function () {
    it("tracks the rate", async function () {
      const rate = await this.crowdsale.getRate();

      rate.toString().should.be.equal(process.env.TVTB_TOKEN_RATE);
    });

    it("tracks the token", async function () {
      const tvtb = await this.crowdsale.getToken();

      tvtb.toString().should.equal(this.tvtb.address);
    });
  });

  describe("Settings", function () {
    it("rate updating", async function () {
      const rateValue = process.env.TVTB_TOKEN_RATE * 2;

      await this.crowdsale.setRate(rateValue);

      const rate = await this.crowdsale.getRate();

      rate.toString().should.be.equal(rateValue.toString());
    });
  });

  describe("Minting", function () {
    it("mints less then one token for beneficiary", async function () {
      const value = 0;

      await this.tvt.approve(
        this.crowdsale.address,
        Web3.utils.toWei(
          (process.env.TVTB_TOKEN_RATE * value).toString(),
          "ether"
        )
      );

      await this.crowdsale.sendTransaction({
        from: account,
        value: Web3.utils.toWei(value.toString(), "ether"),
      }).should.be.rejected;
    });

    it("mints more then one token for beneficiary", async function () {
      const value = 2;

      await this.tvt.approve(
        this.crowdsale.address,
        Web3.utils.toWei(
          (process.env.TVTB_TOKEN_RATE * value).toString(),
          "ether"
        )
      );

      await this.crowdsale.sendTransaction({
        from: account,
        value: Web3.utils.toWei(value.toString(), "ether"),
      }).should.be.rejected;
    });

    it("mints tokens after purchase", async function () {
      const value = 1;

      const prevBalance = {
        treasury: await this.treasury.getBalance(),
        tvtb: await this.tvtb.balanceOf(account),
      };
      await this.tvt.approve(
        this.crowdsale.address,
        Web3.utils.toWei(
          (process.env.TVTB_TOKEN_RATE * value).toString(),
          "ether"
        )
      );

      await this.crowdsale.sendTransaction({
        from: account,
        value: Web3.utils.toWei(value.toString(), "ether"),
      }).should.be.fulfilled;

      const currentBalance = {
        treasury: await this.treasury.getBalance(),
        tvtb: await this.tvtb.balanceOf(account),
      };

      const rate = await this.crowdsale.getRate();

      currentBalance.tvtb
        .sub(prevBalance.tvtb)
        .eq(rate.mul(new web3.utils.BN(value))).should.be.true;

      currentBalance.treasury
        .sub(prevBalance.treasury)
        .toString()
        .should.be.equal(value.toString());
    });

    it("mints another token", async function () {
      const value = 1;

      await this.tvt.approve(
        this.crowdsale.address,
        Web3.utils.toWei(
          (2 * process.env.TVTB_TOKEN_RATE * value).toString(),
          "ether"
        )
      );

      await this.crowdsale.sendTransaction({
        from: account,
        value: Web3.utils.toWei(value.toString(), "ether"),
      }).should.be.fulfilled;

      await this.crowdsale.sendTransaction({
        from: account,
        value: Web3.utils.toWei(value.toString(), "ether"),
      }).should.be.rejected;
    });
  });
});
