// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../Landlord/Landlord.sol";

abstract contract WalletLandlord is Initializable, OwnableUpgradeable {
    Landlord.License[] private _landlordLicenses;

    Landlord.Rent[] private _landlordRents;

    function __WalletLandlord_init(
        Landlord.License[] memory licenses,
        Landlord.Rent[] memory rents
    ) public initializer {
        __Ownable_init();

        setLandlordLicenses(licenses);
        setLandlordRents(rents);
    }

    function getLandlordLicense(uint8 licenseId)
        public
        view
        returns (Landlord.License memory)
    {
        return _landlordLicenses[licenseId];
    }

    function getLandlordLicenses()
        public
        view
        returns (Landlord.License[] memory)
    {
        return _landlordLicenses;
    }

    function getLandlordRent(uint256 rentId)
        public
        view
        returns (Landlord.Rent memory)
    {
        return _landlordRents[rentId];
    }

    function getLandlordRents() public view returns (Landlord.Rent[] memory) {
        return _landlordRents;
    }

    function setLandlordLicenses(Landlord.License[] memory licenses)
        public
        onlyOwner
    {
        delete _landlordLicenses;

        for (uint8 i = 0; i < licenses.length; i++) {
            _landlordLicenses.push(licenses[i]);
        }
    }

    function setLandlordRents(Landlord.Rent[] memory rents) public onlyOwner {
        delete _landlordRents;

        for (uint8 i = 0; i < rents.length; i++) {
            _landlordRents.push(rents[i]);
        }
    }
}
