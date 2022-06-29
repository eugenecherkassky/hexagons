const { deployProxy } = require("@openzeppelin/truffle-upgrades");
require("dotenv").config();

require("chai").use(require("chai-as-promised")).should();

const ContractFactory = require("./ContractFactory");

const PollManager = artifacts.require("PollManager");
const TVTBTokenCrowdsale = artifacts.require("TVTB/TVTBTokenCrowdsale");

const params = {
  proxy: "0xD433a665e2E699413709812a748c4f3d98a00f8D",
  implementation: "0xcfc1D33F825c35F525fD087dE24Cf64c1Ee9a9C3",
  startDateTime: Math.floor(new Date().getTime() / 1000) - 1000,
  endDateTime: Math.floor(new Date().getTime() / 1000) + 10000,
};

contract("PollManager", async function ([account]) {
  beforeEach(async function () {
    this.tvtb = await ContractFactory.createTVTBToken();

    this.crowdsale = await TVTBTokenCrowdsale.new(
      process.env.TVTB_TOKEN_RATE,
      this.tvtb.address
    );

    await this.tvtb.grantRole(
      await this.tvtb.MINTER_ROLE(),
      this.crowdsale.address
    );

    this.pollManager = await deployProxy(PollManager, [this.tvtb.address]);
  });

  describe("Config validation", function () {
    it("tracks the token settings", async function () {
      const tvtb = await this.pollManager.getToken();

      tvtb.toString().should.equal(this.tvtb.address);
    });

    it("tracks poll creation", async function () {
      await this.pollManager.create(
        params.proxy,
        params.implementation,
        params.startDateTime,
        params.endDateTime
      );

      const polls = await this.pollManager.getResult();

      polls.length.should.be.equal(1);

      polls[0].proxy.should.equal(params.proxy);
      polls[0].implementation.should.equal(params.implementation);

      polls[0].startDateTime.should.equal(params.startDateTime.toString());
      polls[0].endDateTime.should.equal(params.endDateTime.toString());

      polls[0].agreeNumber.should.equal("0");
      polls[0].disagreeNumber.should.equal("0");
    });
  });

  describe("Voting", function () {
    it("tracks voting without token", async function () {
      await this.pollManager.vote(0, true).should.be.rejected;
    });

    it("tracks voting, yes", async function () {
      await this.pollManager.create(
        params.proxy,
        params.implementation,
        params.startDateTime,
        params.endDateTime
      ).should.be.fulfilled;

      await this.crowdsale.buyTokens(account, {
        value: 1,
      }).should.be.fulfilled;

      await this.pollManager.vote(0, true).should.be.fulfilled;

      const [poll] = await this.pollManager.getResult();

      poll.agreeNumber.should.equal("1");
      poll.disagreeNumber.should.equal("0");

      await this.pollManager.vote(0, true).should.be.rejected;
    });

    it("tracks voating, no", async function () {
      await this.pollManager.create(
        params.proxy,
        params.implementation,
        params.startDateTime,
        params.endDateTime
      );

      await this.crowdsale.buyTokens(account, {
        value: 1,
      }).should.be.fulfilled;

      await this.pollManager.vote(0, false).should.be.fulfilled;

      const [poll] = await this.pollManager.getResult();

      poll.agreeNumber.should.equal("0");
      poll.disagreeNumber.should.equal("1");

      await this.pollManager.vote(0, true).should.be.rejected;
    });
  });
});
