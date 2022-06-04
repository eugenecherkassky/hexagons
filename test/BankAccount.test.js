require("chai").use(require("chai-as-promised")).should();

const ContractFactory = require("./ContractFactory");

const BankAccount = artifacts.require("BankAccount");

contract("BankAccount", async function (accounts) {
  beforeEach(async function () {
    this.token = await ContractFactory.createTVTToken();

    this.bankAccount = await BankAccount.new(this.token.address);
  });

  describe("Config validation", function () {
    it("tracks the token", async function () {
      const token = await this.bankAccount.getToken();

      token.toString().should.equal(this.token.address);
    });
  });

  describe("Payments", function () {
    it("tracks balance", async function () {
      const prevBalance = {
        clientAccount: await this.token.balanceOf(accounts[0]),
        bankAccount: await this.bankAccount.getBalance(),
      };

      await this.token.approve(this.bankAccount.address, 1);

      await this.bankAccount.transferTo(1).should.be.fulfilled;

      const balance = {
        clientAccount: await this.token.balanceOf(accounts[0]),
        bankAccount: await this.bankAccount.getBalance(),
      };

      prevBalance.clientAccount
        .sub(balance.clientAccount)
        .toString()
        .should.be.equal("1");

      balance.bankAccount
        .sub(prevBalance.bankAccount)
        .toString()
        .should.be.equal("1");
    });
  });
});
