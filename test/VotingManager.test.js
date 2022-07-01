const { deployProxy } = require("@openzeppelin/truffle-upgrades");
require("dotenv").config();
const Web3 = require("web3");

require("chai").use(require("chai-as-promised")).should();

const ContractFactory = require("./ContractFactory");

const VotingManager = artifacts.require("VotingManager");
const TVTVTokenCrowdsale = artifacts.require("TVTV/TVTVTokenCrowdsale");

const params = {
  proxy: "0xD433a665e2E699413709812a748c4f3d98a00f8D",
  implementation: "0xcfc1D33F825c35F525fD087dE24Cf64c1Ee9a9C3",
  startDateTime: Math.floor(new Date().getTime() / 1000) - 1000,
  endDateTime: Math.floor(new Date().getTime() / 1000) + 10000,
};

contract("VotingManager", async function ([account]) {
  beforeEach(async function () {
    this.tvt = await ContractFactory.createTVT();
    this.treasury = await ContractFactory.createTreasury(this.tvt.address);
    this.tvtv = await ContractFactory.createTVTVToken();

    this.crowdsale = await TVTVTokenCrowdsale.new(
      process.env.TVTV_TOKEN_RATE,
      this.treasury.address,
      this.tvtv.address
    );

    await this.tvtv.grantRole(
      await this.tvtv.MINTER_ROLE(),
      this.crowdsale.address
    );

    this.votingManager = await deployProxy(VotingManager, [this.tvtv.address]);
  });

  describe("Config validation", function () {
    it("tracks the token settings", async function () {
      const tvtv = await this.votingManager.getToken();

      tvtv.toString().should.equal(this.tvtv.address);
    });

    it("tracks voting creating && remove", async function () {
      await this.votingManager.add(
        params.proxy,
        params.implementation,
        params.startDateTime,
        params.endDateTime
      ).should.be.fulfilled;

      await this.votingManager.add(
        params.proxy,
        params.implementation,
        params.startDateTime,
        params.endDateTime
      ).should.be.fulfilled;

      let votings = await this.votingManager.getResult();

      votings.length.should.be.equal(2);

      votings[0].proxy.should.equal(params.proxy);
      votings[0].implementation.should.equal(params.implementation);

      votings[0].startDateTime.should.equal(params.startDateTime.toString());
      votings[0].endDateTime.should.equal(params.endDateTime.toString());

      votings[0].agreeNumber.should.equal("0");
      votings[0].isAgree.should.be.false;
      votings[0].disagreeNumber.should.equal("0");
      votings[0].isDisagree.should.be.false;

      await this.votingManager.remove(0);

      votings = await this.votingManager.getResult();

      votings.length.should.be.equal(1);
    });
  });

  describe("Voting", function () {
    it("tracks voting without token", async function () {
      await this.votingManager.vote(0, true).should.be.rejected;
    });

    it("tracks voting, yes", async function () {
      await this.votingManager.add(
        params.proxy,
        params.implementation,
        params.startDateTime,
        params.endDateTime
      ).should.be.fulfilled;

      const value = 1;
      await this.tvt.approve(
        this.crowdsale.address,
        Web3.utils.toWei(
          (process.env.TVTV_TOKEN_RATE * value).toString(),
          "ether"
        )
      );

      await this.crowdsale.sendTransaction({
        from: account,
        value: Web3.utils.toWei(value.toString(), "ether"),
      }).should.be.fulfilled;

      await this.votingManager.vote(0, true).should.be.fulfilled;

      const [voting] = await this.votingManager.getResult();

      voting.agreeNumber.should.equal("1");
      voting.isAgree.should.be.true;
      voting.disagreeNumber.should.equal("0");
      voting.isDisagree.should.be.false;

      await this.votingManager.vote(0, true).should.be.rejected;
    });

    it("tracks voating, no", async function () {
      await this.votingManager.add(
        params.proxy,
        params.implementation,
        params.startDateTime,
        params.endDateTime
      );

      const value = 1;
      await this.tvt.approve(
        this.crowdsale.address,
        Web3.utils.toWei(
          (process.env.TVTV_TOKEN_RATE * value).toString(),
          "ether"
        )
      );

      await this.crowdsale.sendTransaction({
        from: account,
        value: Web3.utils.toWei(value.toString(), "ether"),
      }).should.be.fulfilled;

      await this.votingManager.vote(0, false).should.be.fulfilled;

      const [voting] = await this.votingManager.getResult();

      voting.agreeNumber.should.equal("0");
      voting.isAgree.should.be.false;
      voting.disagreeNumber.should.equal("1");
      voting.isDisagree.should.be.true;

      await this.votingManager.vote(0, true).should.be.rejected;
    });
  });
});
