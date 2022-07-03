const { deployProxy } = require("@openzeppelin/truffle-upgrades");
require("dotenv").config();
const Web3 = require("web3");

require("chai").use(require("chai-as-promised")).should();

const ContractFactory = require("./ContractFactory");
const timeout = require("./utils/timeout");

const VotingManager = artifacts.require("VotingManager");
const TVTVTokenCrowdsale = artifacts.require("TVTV/TVTVTokenCrowdsale");

contract("VotingManager", async function ([account]) {
  beforeEach(async function () {
    this.params = {
      proxy: "0xD433a665e2E699413709812a748c4f3d98a00f8D",
      implementation: "0xcfc1D33F825c35F525fD087dE24Cf64c1Ee9a9C3",
      endDateTime: Math.floor(new Date().getTime() / 1000) + 5,
      git: "http://git.com",
    };

    this.tvt = await ContractFactory.createTVT();
    this.treasury = await ContractFactory.createTreasury(this.tvt.address);
    this.tvtv = await ContractFactory.createTVTVToken();

    this.crowdsale = await TVTVTokenCrowdsale.new(
      process.env.TVTV_TOKEN_RATE,
      this.treasury.address,
      this.tvtv.address
    ).should.be.fulfilled;

    await this.tvtv.grantRole(
      await this.tvtv.MINTER_ROLE(),
      this.crowdsale.address
    ).should.be.fulfilled;

    this.votingManager = await deployProxy(VotingManager, [this.tvtv.address], {
      initializer: "__VotingManager_init",
    });
  });

  describe("Config validation", function () {
    it("tracks the token settings", async function () {
      const tvtv = await this.votingManager.getToken().should.be.fulfilled;

      tvtv.toString().should.equal(this.tvtv.address);
    });

    it("tracks voting creating && remove", async function () {
      const { logs } = await this.votingManager.add(
        this.params.proxy,
        this.params.implementation,
        this.params.endDateTime,
        this.params.git
      ).should.be.fulfilled;

      const votingId = logs[logs.length - 1].args.id;

      await this.votingManager.add(
        this.params.implementation,
        this.params.proxy,
        this.params.endDateTime,
        this.params.git
      ).should.be.fulfilled;

      let votings = await this.votingManager.getResult().should.be.fulfilled;

      votings.length.should.be.equal(2);

      votings[0].id.should.equal(votingId);
      votings[0].proxy.should.equal(this.params.proxy);
      votings[0].implementation.should.equal(this.params.implementation);
      votings[0].endDateTime.should.equal(this.params.endDateTime.toString());
      votings[0].git.should.equal(this.params.git);
      votings[0].agreeNumber.should.equal("0");
      votings[0].isAgree.should.be.false;
      votings[0].disagreeNumber.should.equal("0");
      votings[0].isDisagree.should.be.false;
      votings[0].approvedDateTime.should.equal("0");

      await this.votingManager.remove(votingId).should.be.fulfilled;

      votings = await this.votingManager.getResult().should.be.fulfilled;

      votings.length.should.be.equal(1);

      votings[0].id.should.not.equal(votingId);
    });
  });

  describe("Voting", function () {
    it("tracks voting without token", async function () {
      const { logs } = await this.votingManager.add(
        this.params.proxy,
        this.params.implementation,
        this.params.endDateTime,
        this.params.git
      ).should.be.fulfilled;
      const votingId = logs[logs.length - 1].args.id;
      await this.votingManager.vote(votingId, true).should.be.rejected;
    });
    it("tracks voting, yes", async function () {
      const { logs } = await this.votingManager.add(
        this.params.proxy,
        this.params.implementation,
        this.params.endDateTime,
        this.params.git
      ).should.be.fulfilled;
      const votingId = logs[logs.length - 1].args.id;
      const value = 1;
      await this.tvt.approve(
        this.crowdsale.address,
        Web3.utils.toWei(
          (process.env.TVTV_TOKEN_RATE * value).toString(),
          "ether"
        )
      ).should.be.fulfilled;
      await this.crowdsale.sendTransaction({
        from: account,
        value: Web3.utils.toWei(value.toString(), "ether"),
      }).should.be.fulfilled;
      await this.votingManager.vote(votingId, true).should.be.fulfilled;
      const [voting] = await this.votingManager.getResult();
      voting.agreeNumber.should.equal("1");
      voting.isAgree.should.be.true;
      voting.disagreeNumber.should.equal("0");
      voting.isDisagree.should.be.false;
      await this.votingManager.vote(votingId, true).should.be.rejected;
    });
    it("tracks voating, no", async function () {
      const { logs } = await this.votingManager.add(
        this.params.proxy,
        this.params.implementation,
        this.params.endDateTime,
        this.params.git
      ).should.be.fulfilled;
      const votingId = logs[logs.length - 1].args.id;
      const value = 1;
      await this.tvt.approve(
        this.crowdsale.address,
        Web3.utils.toWei(
          (process.env.TVTV_TOKEN_RATE * value).toString(),
          "ether"
        )
      ).should.be.fulfilled;
      await this.crowdsale.sendTransaction({
        from: account,
        value: Web3.utils.toWei(value.toString(), "ether"),
      }).should.be.fulfilled;
      await this.votingManager.vote(votingId, false).should.be.fulfilled;
      const [voting] = await this.votingManager.getResult();
      voting.agreeNumber.should.equal("0");
      voting.isAgree.should.be.false;
      voting.disagreeNumber.should.equal("1");
      voting.isDisagree.should.be.true;
      await this.votingManager.vote(votingId, true).should.be.rejected;
    });
  });

  describe("Approve", function () {
    it("tracks approve in case of more agree than disagree", async function () {
      const { logs } = await this.votingManager.add(
        this.params.proxy,
        this.params.implementation,
        this.params.endDateTime,
        this.params.git
      ).should.be.fulfilled;

      const votingId = logs[logs.length - 1].args.id;

      const value = 1;
      await this.tvt.approve(
        this.crowdsale.address,
        Web3.utils.toWei(
          (process.env.TVTV_TOKEN_RATE * value).toString(),
          "ether"
        )
      ).should.be.fulfilled;

      await this.crowdsale.sendTransaction({
        from: account,
        value: Web3.utils.toWei(value.toString(), "ether"),
      }).should.be.fulfilled;

      await this.votingManager.vote(votingId, true).should.be.fulfilled;

      await timeout(10 * 1000);

      await this.votingManager.approve(votingId).should.be.fulfilled;

      const [voting] = await this.votingManager.getResult().should.be.fulfilled;

      voting.approvedDateTime.should.not.equal("0");
    });

    it("tracks approve in case of more disagree than agree", async function () {
      const { logs } = await this.votingManager.add(
        this.params.proxy,
        this.params.implementation,
        this.params.endDateTime,
        this.params.git
      ).should.be.fulfilled;

      const votingId = logs[logs.length - 1].args.id;

      const value = 1;
      await this.tvt.approve(
        this.crowdsale.address,
        Web3.utils.toWei(
          (process.env.TVTV_TOKEN_RATE * value).toString(),
          "ether"
        )
      ).should.be.fulfilled;

      await this.crowdsale.sendTransaction({
        from: account,
        value: Web3.utils.toWei(value.toString(), "ether"),
      }).should.be.fulfilled;

      await this.votingManager.vote(votingId, false).should.be.fulfilled;

      await timeout(15 * 1000);

      await this.votingManager.approve(votingId).should.be.rejected;

      const [voting] = await this.votingManager.getResult().should.be.fulfilled;

      voting.approvedDateTime.should.equal("0");
    });
  });
});
