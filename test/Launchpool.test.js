require("dotenv").config();

require("chai").use(require("chai-as-promised")).should();

const ContractFactory = require("./ContractFactory");
const depositPrograms = require("./DepositPrograms");
const timeout = require("./utils/timeout");

const Deposit = artifacts.require("Deposit");

contract("Launchpool", async function ([ownerAccount]) {
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
      const transaction = await this.launchpool.createDeposit("terminatable")
        .should.be.fulfilled;

      const [deposit] = await this.launchpool.getDeposits();

      deposit.agreement.should.be.equal(transaction.logs[0].args.deposit);
    });

    it("tracks deposit", async function () {
      await this.launchpool.createDeposit("terminatable").should.be.fulfilled;

      const [deposit] = await this.launchpool.getDeposits();
      const depositContract = await Deposit.at(deposit.agreement);

      await this.token.approve(depositContract.address, 1);
      await depositContract.send(1).should.be.fulfilled;

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

      await this.token.approve(depositContract.address, 1);
      await depositContract.send(1).should.be.fulfilled;

      (await depositContract.getBalance()).toString().should.be.equal("2");
      (await depositContract.getTransactions()).length.should.be.equal(2);
    });

    it("tracks refil", async function () {
      await this.launchpool.createDeposit("terminatable").should.be.fulfilled;

      const [deposit] = await this.launchpool.getDeposits();
      const depositContract = await Deposit.at(deposit.agreement);

      await this.token.approve(depositContract.address, 1);
      await depositContract.send(1).should.be.fulfilled;

      await this.mint.distribute();

      const prevBalance = {
        deposit: await this.token.balanceOf(depositContract.address),
        launchpool: await this.token.balanceOf(this.launchpool.address),
        mint: await this.token.balanceOf(this.mint.address),
        owner: await this.token.balanceOf(ownerAccount),
      };

      await this.launchpool.refill();

      const nextBalance = {
        deposit: await this.token.balanceOf(depositContract.address),
        launchpool: await this.token.balanceOf(this.launchpool.address),
        mint: await this.token.balanceOf(this.mint.address),
        owner: await this.token.balanceOf(ownerAccount),
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

      await this.token.approve(depositContract.address, 2);

      await depositContract.send(1).should.be.fulfilled;

      await depositContract.send(1).should.be.rejected;

      (await depositContract.getBalance()).toString().should.be.equal("1");
      (await depositContract.getTransactions()).length.should.be.equal(1);
    });

    it("tracks withdraw", async function () {
      await this.launchpool.createDeposit("depositable").should.be.fulfilled;

      const [deposit] = await this.launchpool.getDeposits();

      const depositContract = await Deposit.at(deposit.agreement);

      await this.token.approve(depositContract.address, 5);
      await depositContract.send(5).should.be.fulfilled;

      await depositContract.withdraw().should.be.rejected;

      await timeout(15 * 1000);

      // TODO
      // await deposit.close().should.be.fulfilled;

      // (await deposit.isClosed()).should.be.true;

      // (await deposit.getTransactions()).length.should.be.equal(3);

      // const prevBalance = {
      //   deposit: await deposit.getBalance(),
      //   client: await this.token.balanceOf(ownerAccount),
      //   treasury: await this.treasury.getBalance(),
      // };

      // await deposit.withdraw().should.be.fulfilled;

      // await this.token.transferFrom(
      //   deposit.address,
      //   ownerAccount,
      //   (await deposit.getBalance()).toString()
      // );

      // const currentBalance = {
      //   deposit: await deposit.getBalance(),
      //   client: await this.token.balanceOf(ownerAccount),
      //   treasury: await this.treasury.getBalance(),
      // };

      // currentBalance.deposit.toString().should.be.equal("0");

      // const transactions = await deposit.getTransactions();

      // const penaltyAmount = transactions
      //   .filter((transaction) => {
      //     return transaction.kind === "1";
      //   })
      //   .reduce(
      //     (previousValue, transaction) => previousValue + transaction.amount,
      //     0
      //   );

      // currentBalance.treasury
      //   .sub(prevBalance.treasury)
      //   .toString()
      //   .should.be.equal(penaltyAmount.toString());
    });
  });
});
