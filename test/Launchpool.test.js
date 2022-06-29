require("dotenv").config();

require("chai").use(require("chai-as-promised")).should();

const ContractFactory = require("./ContractFactory");
const depositPrograms = require("./DepositPrograms");
const timeout = require("./utils/timeout");

const Deposit = artifacts.require("Deposit");

contract("Launchpool", async function ([account]) {
  beforeEach(async function () {
    this.tvt = await ContractFactory.createTVT();
    this.mint = await ContractFactory.createMint(this.tvt.address);
    this.treasury = await ContractFactory.createTreasury(this.tvt.address);

    this.launchpool = await ContractFactory.createLaunchpool(
      this.treasury.address
    );

    this.launchpool.setDepositPrograms(depositPrograms);

    this.launchpool.setRefillableSuppliers([
      {
        agreement: this.mint.address,
        reward: process.env.LAUNCHPOOL_MINT_REFIL_REWARD,
      },
      {
        agreement: this.treasury.address,
        reward: process.env.LAUNCHPOOL_TREASURY_REFIL_REWARD,
      },
    ]);

    await this.mint.setRecipients([
      {
        agreement: this.launchpool.address,
        share: 100,
      },
    ]);

    await this.tvt.mint(process.env.MINT_INITIAL_SUPPLY);
    await this.tvt.transfer(this.mint.address, process.env.MINT_INITIAL_SUPPLY);
  });

  describe("Settings", function () {
    it("tracks refil reward", async function () {
      const [mint, treasury] = await this.launchpool.getRefillableSuppliers();

      mint.agreement.should.be.equal(this.mint.address);
      mint.reward.should.be.equal(process.env.LAUNCHPOOL_MINT_REFIL_REWARD);

      treasury.agreement.should.be.equal(this.treasury.address);
      treasury.reward.should.be.equal(
        process.env.LAUNCHPOOL_TREASURY_REFIL_REWARD
      );
    });

    it("tracks deposit program options", async function () {
      const parameters = await this.launchpool.getDepositProgram(
        depositPrograms[0].program
      );

      const {
        amountMaximum,
        amountMinimum,
        isDepositable,
        isTerminatable,
        periodMaximum,
        periodMinimum,
        program,
        rate,
        terminationPenalty,
      } = depositPrograms[0];

      parameters.amountMaximum.should.be.equal(amountMaximum.toString());
      parameters.amountMinimum.should.be.equal(amountMinimum.toString());
      parameters.isDepositable.should.be.equal(isDepositable);
      parameters.isTerminatable.should.be.equal(isTerminatable);
      parameters.periodMaximum.should.be.equal(periodMaximum.toString());
      parameters.periodMinimum.should.be.equal(periodMinimum.toString());
      parameters.program.should.be.equal(program);
      parameters.rate.should.be.equal(rate.toString());
      parameters.terminationPenalty.should.be.equal(
        terminationPenalty.toString()
      );
    });
  });

  describe("Deposit", function () {
    it("tracks creation", async function () {
      const { logs } = await this.launchpool.createDeposit("terminatable")
        .should.be.fulfilled;

      const [deposit] = await this.launchpool.getDeposits();

      deposit.agreement.should.be.equal(logs[logs.length - 1].args.deposit);
    });

    it("tracks deposit", async function () {
      await this.launchpool.createDeposit("terminatable").should.be.fulfilled;

      const [deposit] = await this.launchpool.getDeposits();
      const depositContract = await Deposit.at(deposit.agreement);

      await this.tvt.approve(depositContract.address, 1);
      await depositContract.deposit(1).should.be.fulfilled;

      (await depositContract.getBalance()).toString().should.be.equal("1");
      (await depositContract.getTransactions()).length.should.be.equal(1);

      const options = await this.launchpool.getDepositProgram("terminatable");

      const beginDateTime = await depositContract.getBeginDateTime();
      const periodMaximumDateTime =
        await depositContract.getPeriodMaximumDateTime();
      const periodMinimumDateTime =
        await depositContract.getPeriodMinimumDateTime();

      periodMinimumDateTime
        .sub(beginDateTime)
        .toString()
        .should.be.equal(options.periodMinimum);

      periodMaximumDateTime
        .sub(beginDateTime)
        .toString()
        .should.be.equal(options.periodMaximum);

      await this.tvt.approve(depositContract.address, 1);
      await depositContract.deposit(1).should.be.fulfilled;

      (await depositContract.getBalance()).toString().should.be.equal("2");
      (await depositContract.getTransactions()).length.should.be.equal(2);
    });

    it("tracks refil", async function () {
      await this.launchpool.createDeposit("terminatable").should.be.fulfilled;

      const [deposit] = await this.launchpool.getDeposits();
      const depositContract = await Deposit.at(deposit.agreement);

      await this.tvt.approve(depositContract.address, 1);
      await depositContract.deposit(1).should.be.fulfilled;

      await this.mint.distribute();

      const prevBalance = {
        deposit: await this.tvt.balanceOf(depositContract.address),
        launchpool: await this.tvt.balanceOf(this.launchpool.address),
        mint: await this.tvt.balanceOf(this.mint.address),
        owner: await this.tvt.balanceOf(account),
      };

      await this.launchpool.refill();

      const nextBalance = {
        deposit: await this.tvt.balanceOf(depositContract.address),
        launchpool: await this.tvt.balanceOf(this.launchpool.address),
        mint: await this.tvt.balanceOf(this.mint.address),
        owner: await this.tvt.balanceOf(account),
      };

      prevBalance.mint
        .sub(nextBalance.mint)
        .sub(nextBalance.launchpool.sub(prevBalance.launchpool))
        .sub(nextBalance.owner.sub(prevBalance.owner))
        .toString()
        .should.be.equal("0");

      const transferedAmount = await this.launchpool.getTransfersAmount(
        parseInt(Date.now() / 1000)
      );

      transferedAmount
        .sub(nextBalance.launchpool.sub(prevBalance.launchpool))
        .toString()
        .should.be.equal("0");
    });

    it("tracks deposit, deposit", async function () {
      await this.launchpool.createDeposit(
        "not depositable"
      ).should.be.fulfilled;

      const [deposit] = await this.launchpool.getDeposits();
      const depositContract = await Deposit.at(deposit.agreement);

      await this.tvt.approve(depositContract.address, 2);

      await depositContract.deposit(1).should.be.fulfilled;

      await depositContract.deposit(1).should.be.rejected;

      (await depositContract.getBalance()).toString().should.be.equal("1");
      (await depositContract.getTransactions()).length.should.be.equal(1);
    });

    it("tracks withdraw", async function () {
      await this.launchpool.createDeposit("depositable").should.be.fulfilled;

      const [deposit] = await this.launchpool.getDeposits();

      const depositContract = await Deposit.at(deposit.agreement);

      await this.tvt.approve(depositContract.address, 5);
      await depositContract.deposit(5).should.be.fulfilled;

      await depositContract.withdraw().should.be.rejected;

      await timeout(15 * 1000);

      const prevBalance = {
        deposit: await depositContract.getBalance(),
        client: await this.tvt.balanceOf(account),
        treasury: await this.treasury.getBalance(),
      };

      await depositContract.withdraw().should.be.fulfilled;

      (await depositContract.getTransactions()).length.should.be.equal(3);

      const currentBalance = {
        deposit: await depositContract.getBalance(),
        client: await this.tvt.balanceOf(account),
        treasury: await this.treasury.getBalance(),
      };

      currentBalance.deposit.toString().should.be.equal("0");

      const transactions = await depositContract.getTransactions();

      const penaltyAmount = transactions
        .filter((transaction) => {
          return transaction.kind === "1";
        })
        .reduce(
          (previousValue, transaction) => previousValue + transaction.amount,
          0
        );

      currentBalance.treasury
        .sub(prevBalance.treasury)
        .toString()
        .should.be.equal(penaltyAmount.toString());
    });
  });
});
