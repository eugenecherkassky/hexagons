require("dotenv").config();

require("chai").use(require("chai-as-promised")).should();

const ContractFactory = require("./ContractFactory");

const Deposit = artifacts.require("Deposit");

function getAmountOnDay(day) {
  return parseInt((288 * (59000000 - day * 73972)) / 10 ** 4).toString();
}

contract("Mint", async function () {
  beforeEach(async function () {
    this.token = await ContractFactory.createTVTToken();
    this.mint = await ContractFactory.createMint(this.token.address);
    this.treasury = await ContractFactory.createTreasury(this.token.address);

    this.launchpool = await ContractFactory.createLaunchpool(
      this.mint.address,
      this.treasury.address
    );

    await this.mint.initialize([
      {
        agreement: this.launchpool.address,
        share: 100,
      },
    ]);

    await this.token.mint(this.mint.address, process.env.MINT_INITIAL_SUPPLY);
  });

  describe("Settings", function () {
    it("tracks number of coins to distribute", async function () {
      const balance = await this.mint.getBalance();

      balance.toString().should.be.equal(process.env.MINT_INITIAL_SUPPLY);
    });

    it("tracks the recipients", async function () {
      const [recipient] = await this.mint.getRecipients();

      recipient.agreement.should.be.equal(this.launchpool.address);
      recipient.share.should.be.equal("100");
    });

    it("tracks the token", async function () {
      const token = await this.mint.getToken();

      token.toString().should.equal(this.token.address);
    });
  });

  describe("Distribution", function () {
    it("tracks global distribution schedule", async function () {
      const amounts = await this.mint.getDistributionAmounts(10);

      for (let i = 0; i < amounts.length; i++) {
        amounts[i].toString().should.be.equal(getAmountOnDay(i));
      }
    });

    it("tracks distribution", async function () {
      await this.launchpool.createDeposit("depositable").should.be.fulfilled;

      const [deposit] = await this.launchpool.getDeposits();

      const depositContract = await Deposit.at(deposit.agreement);

      await this.token.approve(depositContract.address, 1);
      await depositContract.send(1).should.be.fulfilled;

      await this.mint.distribute().should.be.fulfilled;

      const amounts = await this.mint.getDistributionAmounts(10);

      const payments = await this.mint.getPayments();

      payments.length.should.be.equal(1);

      payments[0].agreement.should.be.equal(this.launchpool.address);
      payments[0].amount.should.be.equal(amounts[0].toString());

      const datetime = parseInt(Date.now() / 1000);
      payments[0].date.should.be.equal(
        (datetime - (datetime % (24 * 60 * 60))).toString()
      );
      payments[0].share.should.be.equal("100");
      payments[0].payed.should.be.equal("0");
    });
  });
});
