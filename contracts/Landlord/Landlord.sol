// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

library Landlord {
    struct LicenseParams {
        uint256 performance;
        uint256 period;
        uint256 price;
        uint8 purpose;
    }

    struct RentParams {
        uint256 period;
        uint256 price;
    }
}
