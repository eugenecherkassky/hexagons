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
      const options = await this.launchpool.getDepositProgramOptions("base");

      const {
        amountMaximum,
        amountMinimum,
        isRefillable,
        isTerminatable,
        periodMaximum,
        periodMinimum,
        program,
        rate,
        terminationPenalty,
      } = depositPrograms[0];

      options.amountMaximum.should.be.equal(amountMaximum.toString());
      options.amountMinimum.should.be.equal(amountMinimum.toString());
      options.isRefillable.should.be.equal(isRefillable);
      options.isTerminatable.should.be.equal(isTerminatable);
      options.periodMaximum.should.be.equal(periodMaximum.toString());
      options.periodMinimum.should.be.equal(periodMinimum.toString());
      options.program.should.be.equal(program);
      options.rate.should.be.equal(rate.toString());
      options.terminationPenalty.should.be.equal(terminationPenalty.toString());
    });
  });

  describe("Deposit", function () {
    it("tracks creation", async function () {
      const transaction = await this.launchpool.createDeposit("terminatable")
        .should.be.fulfilled;

      const [depositAddress] = await this.launchpool.getDeposits();

      depositAddress.should.be.equal(transaction.logs[0].args.account);
    });

    it("tracks deposit", async function () {
      await this.launchpool.createDeposit("terminatable").should.be.fulfilled;

      const [depositAddress] = await this.launchpool.getDeposits();
      const deposit = await Deposit.at(depositAddress);

      await this.token.approve(deposit.address, 1);
      await deposit.deposit(1).should.be.fulfilled;

      (await deposit.getBalance()).toString().should.be.equal("1");
      (await deposit.getTransactions()).length.should.be.equal(1);

      const options = await this.launchpool.getDepositProgramOptions(
        "terminatable"
      );

      const beginDateTime = await deposit.getBeginDateTime();
      const periodMaximumDateTime = await deposit.getPeriodMaximumDateTime();
      const periodMinimumDateTime = await deposit.getPeriodMinimumDateTime();

      periodMinimumDateTime
        .sub(beginDateTime)
        .toString()
        .should.be.equal(options.periodMinimum);

      periodMaximumDateTime
        .sub(beginDateTime)
        .toString()
        .should.be.equal(options.periodMaximum);

      await this.token.approve(deposit.address, 1);
      await deposit.deposit(1).should.be.fulfilled;

      (await deposit.getBalance()).toString().should.be.equal("2");
      (await deposit.getTransactions()).length.should.be.equal(2);
    });

    it("tracks refil", async function () {
      await this.launchpool.createDeposit("terminatable").should.be.fulfilled;

      const [depositAddress] = await this.launchpool.getDeposits();
      const deposit = await Deposit.at(depositAddress);

      await this.token.approve(deposit.address, 1);
      await deposit.deposit(1).should.be.fulfilled;

      await this.mint.distribute();

      const prevBalance = {
        deposit: await this.token.balanceOf(deposit.address),
        launchpool: await this.token.balanceOf(this.launchpool.address),
        mint: await this.token.balanceOf(this.mint.address),
        owner: await this.token.balanceOf(ownerAccount),
      };

      await this.launchpool.refill();

      const nextBalance = {
        deposit: await this.token.balanceOf(deposit.address),
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

    it("tracks deposit, refil", async function () {
      await this.launchpool.createDeposit("nonrefillable").should.be.fulfilled;

      const [depositAddress] = await this.launchpool.getDeposits();
      const deposit = await Deposit.at(depositAddress);

      await this.token.approve(deposit.address, 2);

      await deposit.deposit(1).should.be.fulfilled;

      await deposit.deposit(1).should.be.rejected;

      (await deposit.getBalance()).toString().should.be.equal("1");
      (await deposit.getTransactions()).length.should.be.equal(1);
    });

    it("tracks close & withdraw", async function () {
      await this.launchpool.createDeposit("refillable").should.be.fulfilled;

      const [depositAddress] = await this.launchpool.getDeposits();

      const deposit = await Deposit.at(depositAddress);

      await this.token.approve(deposit.address, 5);
      await deposit.deposit(5).should.be.fulfilled;

      await deposit.close().should.be.rejected;

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
