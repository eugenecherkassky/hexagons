require("dotenv").config();

require("chai").use(require("chai-as-promised")).should();

const ContractFactory = require("../ContractFactory");

contract("TVTBToken", function ([account]) {
  beforeEach(async function () {
    this.tvtb = await ContractFactory.createTVTBToken();
  });

  describe("Settings", function () {
    it("tracks the name", async function () {
      const name = await this.tvtb.name();
      name.should.be.equal(process.env.TVTB_TOKEN_NAME);
    });

    it("tracks the symbol", async function () {
      const symbol = await this.tvtb.symbol();
      symbol.should.be.equal(process.env.TVTB_TOKEN_SYMBOL);
    });

    it("tracks minting", async function () {
      const prevBalance = await this.tvtb.balanceOf(account);

      (await this.tvtb.getNumber()).toString().should.be.equal("0");

      await this.tvtb.mint(account).should.be.fulfilled;

      (await this.tvtb.getNumber()).toString().should.be.equal("1");

      const currentBalance = await this.tvtb.balanceOf(account);

      currentBalance.sub(prevBalance).toString().should.be.equal("1");
    });

    it("tracks burning", async function () {
      (await this.tvtb.getNumber()).toString().should.be.equal("0");

      const { receipt } = await this.tvtb.mint(account);

      (await this.tvtb.getNumber()).toString().should.be.equal("1");

      await this.tvtb.burn(receipt.logs[0].args.tokenId.toString());

      (await this.tvtb.getNumber()).toString().should.be.equal("0");
    });
  });
});
