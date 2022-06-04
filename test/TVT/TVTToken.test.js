require("dotenv").config();

require("chai").use(require("chai-as-promised")).should();

const ether = require("../utils/ether");

const ContractFactory = require("../ContractFactory");

contract("TVTToken", function () {
  beforeEach(async function () {
    this.token = await ContractFactory.createTVTToken();
  });

  describe("TVTToken", function () {
    it("tracks the name", async function () {
      const name = await this.token.name();
      name.should.be.equal(process.env.TVT_TOKEN_NAME);
    });

    it("tracks the symbol", async function () {
      const symbol = await this.token.symbol();
      symbol.should.be.equal(process.env.TVT_TOKEN_SYMBOL);
    });

    it("tracks the initial supply", async function () {
      const totalSupply = await this.token.totalSupply();

      totalSupply
        .toString()
        .should.be.equal(ether(process.env.TVT_TOKEN_INITIAL_SUPPLY));
    });
  });
});
