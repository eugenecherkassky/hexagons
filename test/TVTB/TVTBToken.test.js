require("dotenv").config();

require("chai").use(require("chai-as-promised")).should();

const ContractFactory = require("../ContractFactory");

contract("TVTBToken", function ([client_wallet]) {
  beforeEach(async function () {
    this.token = await ContractFactory.createTVTBToken();
  });

  describe("Settings", function () {
    it("tracks the name", async function () {
      const name = await this.token.name();
      name.should.be.equal(process.env.TVTB_TOKEN_NAME);
    });

    it("tracks the symbol", async function () {
      const symbol = await this.token.symbol();
      symbol.should.be.equal(process.env.TVTB_TOKEN_SYMBOL);
    });

    it("tracks minting", async function () {
      const prevBalance = await this.token.balanceOf(client_wallet);

      (await this.token.getNumber()).toString().should.be.equal("0");

      await this.token.mint(client_wallet).should.be.fulfilled;

      (await this.token.getNumber()).toString().should.be.equal("1");

      const currentBalance = await this.token.balanceOf(client_wallet);

      currentBalance.sub(prevBalance).toString().should.be.equal("1");
    });

    it("tracks burning", async function () {
      (await this.token.getNumber()).toString().should.be.equal("0");

      const { receipt } = await this.token.mint(client_wallet);

      (await this.token.getNumber()).toString().should.be.equal("1");

      await this.token.burn(receipt.logs[0].args.tokenId.toString());

      (await this.token.getNumber()).toString().should.be.equal("0");
    });
  });
});
