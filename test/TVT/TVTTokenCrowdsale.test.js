require("dotenv").config();

require("chai").use(require("chai-as-promised")).should();

const ContractFactory = require("../ContractFactory");

const getBalance = require("../utils/getBalance");

const TVTTokenCrowdsale = artifacts.require("TVT/TVTTokenCrowdsale");

contract("TVTTokenCrowdsale", async function ([owner_wallet]) {
  beforeEach(async function () {
    this.token = await ContractFactory.createTVTToken();

    this.crowdsale = await TVTTokenCrowdsale.new(
      process.env.TVT_TOKEN_RATE,
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

      rate.toString().should.be.equal(process.env.TVT_TOKEN_RATE);
    });

    it("tracks the token", async function () {
      const token = await this.crowdsale.getToken();

      token.toString().should.equal(this.token.address);
    });
  });

  describe("Settings", function () {
    it("rate updating", async function () {
      const rateValue = process.env.TVT_TOKEN_RATE * 2;

      await this.crowdsale.setRate(rateValue);

      const rate = await this.crowdsale.getRate();

      rate.toString().should.be.equal(rateValue.toString());
    });
  });

  describe("Minting", function () {
    it("mints tokens after purchase", async function () {
      const value = 1;

      const prevBalance = {
        crowdsale: await getBalance(this.crowdsale.address),
        tvt: await this.token.balanceOf(owner_wallet),
      };

      await this.crowdsale.buyTokens({
        value,
      }).should.be.fulfilled;

      const currentBalance = {
        crowdsale: await getBalance(this.crowdsale.address),
        tvt: await this.token.balanceOf(owner_wallet),
      };

      const rate = await this.crowdsale.getRate();

      currentBalance.tvt
        .sub(prevBalance.tvt)
        .eq(rate.mul(new web3.utils.BN(value))).should.be.true;

      currentBalance.crowdsale
        .sub(prevBalance.crowdsale)
        .toString()
        .should.be.equal(value.toString());
    });
  });
});
