require("dotenv").config();

require("chai").use(require("chai-as-promised")).should();

const ContractFactory = require("../ContractFactory");

const getBalance = require("../utils/getBalance");

const TVTBTokenCrowdsale = artifacts.require("TVTB/TVTBTokenCrowdsale");

contract("TVTBTokenCrowdsale", async function ([account]) {
  beforeEach(async function () {
    this.token = await ContractFactory.createTVTBToken();

    this.crowdsale = await TVTBTokenCrowdsale.new(
      process.env.TVTB_TOKEN_RATE,
      this.token.address
    );

    await this.token.grantRole(
      await this.token.MINTER_ROLE(),
      this.crowdsale.address
    );
  });

  describe("Config validation", function () {
    it("tracks the rate", async function () {
      const rate = await this.crowdsale.getRate();

      rate.toString().should.be.equal(process.env.TVTB_TOKEN_RATE);
    });

    it("tracks the token", async function () {
      const token = await this.crowdsale.getToken();

      token.toString().should.equal(this.token.address);
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
      await this.crowdsale.buyTokens({ value: 0 }).should.be.rejected;
    });

    it("mints more then one token for beneficiary", async function () {
      await this.crowdsale.buyTokens({ value: 2 }).should.be.rejected;
    });

    it("mints tokens after purchase", async function () {
      const value = 1;

      const prevBalance = {
        crowdsale: await getBalance(this.crowdsale.address),
        tvtb: await this.token.balanceOf(account),
      };

      await this.crowdsale.buyTokens({ value }).should.be.fulfilled;

      const currentBalance = {
        crowdsale: await getBalance(this.crowdsale.address),
        tvtb: await this.token.balanceOf(account),
      };

      const rate = await this.crowdsale.getRate();

      currentBalance.tvtb
        .sub(prevBalance.tvtb)
        .eq(rate.mul(new web3.utils.BN(value))).should.be.true;

      currentBalance.crowdsale
        .sub(prevBalance.crowdsale)
        .toString()
        .should.be.equal(value.toString());
    });

    it("mints another token", async function () {
      await this.crowdsale.buyTokens({ value: 1 }).should.be.fulfilled;

      await this.crowdsale.buyTokens({ value: 1 }).should.be.rejected;
    });

    it("mints free token", async function () {
      const value = 1;

      const prevBalance = {
        crowdsale: await getBalance(this.crowdsale.address),
        tvtb: await this.token.balanceOf(account),
      };

      await this.crowdsale.setRate(0);

      await this.crowdsale.buyTokens({
        value,
      }).should.be.fulfilled;

      const currentBalance = {
        crowdsale: await getBalance(this.crowdsale.address),
        tvtb: await this.token.balanceOf(account),
      };

      currentBalance.tvtb
        .sub(prevBalance.tvtb)
        .toString()
        .should.be.equal(value.toString());

      currentBalance.crowdsale
        .sub(prevBalance.crowdsale)
        .toString()
        .should.be.equal(value.toString());
    });
  });
});
