require("dotenv").config();

require("chai").use(require("chai-as-promised")).should();

const licensesParams = require("../data/licensesParams");
const rentsParams = require("../data/rentsParams");

const ContractFactory = require("./ContractFactory");

contract("Wallet", async function () {
  beforeEach(async function () {
    this.tvt = await ContractFactory.createTVT();
    this.wallet = await ContractFactory.createWallet(
      this.tvt.address,
      licensesParams,
      rentsParams
    );
  });

  describe("Landlord", function () {
    it("Licenses params", async function () {
      const landlordLicensesParams =
        await this.wallet.getLandlordLicensesParams().should.be.fulfilled;

      licensesParams.forEach((licenseParams, i) => {
        ["performance", "period", "purpose", "price"].forEach((field) => {
          landlordLicensesParams[i][field].should.be.equal(
            licenseParams[field].toString()
          );
        });
      });
    });

    it("Rents params", async function () {
      const landlordRentsParams = await this.wallet.getLandlordRentsParams()
        .should.be.fulfilled;

      rentsParams.forEach((rentParams, i) => {
        ["period", "price"].forEach((field) => {
          landlordRentsParams[i][field].should.be.equal(
            rentParams[field].toString()
          );
        });
      });
    });
  });

  describe("User", function () {
    it("Username setting price", async function () {
      const price = await this.wallet.getUserSetUsernamePrice().should.be
        .fulfilled;

      price.toString().should.be.equal("1");
    });
  });
});
