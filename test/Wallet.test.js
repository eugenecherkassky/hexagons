require("dotenv").config();

require("chai").use(require("chai-as-promised")).should();

const licenses = require("../data/licenses");
const rents = require("../data/rents");

const ContractFactory = require("./ContractFactory");

contract("Wallet", async function () {
  beforeEach(async function () {
    this.tvt = await ContractFactory.createTVT();
    this.wallet = await ContractFactory.createWallet(
      this.tvt.address,
      licenses,
      rents
    );
  });

  describe("Landlord", function () {
    it("Licenses", async function () {
      const landlordLicenses = await this.wallet.getLandlordLicenses().should.be
        .fulfilled;

      licenses.forEach((license, i) => {
        ["performance", "period", "purpose", "price"].forEach((field) => {
          landlordLicenses[i][field].should.be.equal(license[field].toString());
        });
      });
    });

    it("Rents", async function () {
      const landlordRents = await this.wallet.getLandlordRents().should.be
        .fulfilled;

      rents.forEach((rent, i) => {
        ["period", "price"].forEach((field) => {
          landlordRents[i][field].should.be.equal(rent[field].toString());
        });
      });
    });
  });

  describe("User", function () {
    it("Username setting price", async function () {
      const price = await this.wallet.getUserSetUsernamePrice();

      price.toString().should.be.equal("1");
    });
  });
});
