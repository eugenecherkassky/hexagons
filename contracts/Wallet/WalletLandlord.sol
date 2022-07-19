// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../Landlord/Landlord.sol";

abstract contract WalletLandlord is Initializable, OwnableUpgradeable {
    Landlord.LicenseParams[] private _landlordLicensesParams;

    Landlord.RentParams[] private _landlordRentsParams;

    function __WalletLandlord_init(
        Landlord.LicenseParams[] memory licensesParams,
        Landlord.RentParams[] memory rentsParams
    ) public initializer {
        __Ownable_init();

        setLandlordLicensesParams(licensesParams);
        setLandlordRentsParams(rentsParams);
    }

    function getLandlordLicenseParams(uint8 licenseId)
        public
        view
        returns (Landlord.LicenseParams memory)
    {
        return _landlordLicensesParams[licenseId];
    }

    function getLandlordLicensesParams()
        public
        view
        returns (Landlord.LicenseParams[] memory)
    {
        return _landlordLicensesParams;
    }

    function getLandlordRentParams(uint256 rentId)
        public
        view
        returns (Landlord.RentParams memory)
    {
        return _landlordRentsParams[rentId];
    }

    function getLandlordRentsParams()
        public
        view
        returns (Landlord.RentParams[] memory)
    {
        return _landlordRentsParams;
    }

    function setLandlordLicensesParams(
        Landlord.LicenseParams[] memory licensesParams
    ) public onlyOwner {
        delete _landlordLicensesParams;

        for (uint8 i = 0; i < licensesParams.length; i++) {
            _landlordLicensesParams.push(licensesParams[i]);
        }
    }

    function setLandlordRentsParams(Landlord.RentParams[] memory rentsParams)
        public
        onlyOwner
    {
        delete _landlordRentsParams;

        for (uint8 i = 0; i < rentsParams.length; i++) {
            _landlordRentsParams.push(rentsParams[i]);
        }
    }
}
