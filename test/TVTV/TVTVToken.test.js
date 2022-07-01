require("dotenv").config();

require("chai").use(require("chai-as-promised")).should();

const ContractFactory = require("../ContractFactory");

contract("TVTVToken", function ([account]) {
  beforeEach(async function () {
    this.tvtv = await ContractFactory.createTVTVToken();
  });

  describe("Settings", function () {
    it("tracks the name", async function () {
      const name = await this.tvtv.name();
      name.should.be.equal(process.env.TVTV_TOKEN_NAME);
    });

    it("tracks the symbol", async function () {
      const symbol = await this.tvtv.symbol();
      symbol.should.be.equal(process.env.TVTV_TOKEN_SYMBOL);
    });

    it("tracks minting", async function () {
      const prevBalance = await this.tvtv.balanceOf(account);

      (await this.tvtv.getNumber()).toString().should.be.equal("0");

      await this.tvtv.mint(account).should.be.fulfilled;

      (await this.tvtv.getNumber()).toString().should.be.equal("1");

      const currentBalance = await this.tvtv.balanceOf(account);

      currentBalance.sub(prevBalance).toString().should.be.equal("1");
    });

    it("tracks burning", async function () {
      (await this.tvtv.getNumber()).toString().should.be.equal("0");

      const { receipt } = await this.tvtv.mint(account);

      (await this.tvtv.getNumber()).toString().should.be.equal("1");

      await this.tvtv.burn(receipt.logs[0].args.tokenId.toString());

      (await this.tvtv.getNumber()).toString().should.be.equal("0");
    });
  });
});
