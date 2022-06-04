require("dotenv").config();

require("chai").use(require("chai-as-promised")).should();

const Ballot = artifacts.require("Ballot");
const TVTBToken = artifacts.require("TVTB/TVTBToken");
const TVTBTokenCrowdsale = artifacts.require("TVTB/TVTBTokenCrowdsale");

contract("Ballot", async function ([owner_wallet]) {
  beforeEach(async function () {
    this.token = await TVTBToken.new(
      process.env.TVTB_TOKEN_NAME,
      process.env.TVTB_TOKEN_SYMBOL,
      process.env.TVTB_TOKEN_URI
    );

    this.crowdsale = await TVTBTokenCrowdsale.new(
      process.env.TVTB_TOKEN_RATE,
      this.token.address
    );

    await this.token.grantRole(
      await this.token.MINTER_ROLE(),
      this.crowdsale.address
    );

    this.ballot = await Ballot.new(this.token.address);

    const startDate = Math.floor(new Date().getTime() / 1000) - 1000;
    const endDate = startDate + 10000;

    await this.ballot.createPoll("https://google.com", startDate, endDate);
  });

  describe("Config validation", function () {
    it("tracks the token settings", async function () {
      const token = await this.ballot.getToken();

      token.toString().should.equal(this.token.address);
    });
  });

  describe("Voting", function () {
    it("tracks voting without token", async function () {
      await this.ballot.vote().should.be.rejected;
    });

    it("tracls voting", async function () {
      await this.crowdsale.buyTokens({
        value: 1,
      }).should.be.fulfilled;

      await this.ballot.vote();

      let poll = await this.ballot.getLast();

      poll.approvers.includes(owner_wallet).should.be.true;

      await this.ballot.close();

      poll = await this.ballot.getLast();

      poll.totalNumberOfVoters.should.be.equal("1");
    });

    it("tracks another try to vote", async function () {
      await this.crowdsale.buyTokens({
        value: 1,
      }).should.be.fulfilled;

      await this.ballot.vote().should.be.fulfilled;
      await this.ballot.vote().should.be.rejected;
    });
  });
});
