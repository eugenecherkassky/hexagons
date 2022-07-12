// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

library Landlord {
    struct License {
        uint256 performance;
        uint256 period;
        uint256 price;
        uint8 purpose;
    }

    struct Rent {
        uint256 period;
        uint256 price;
    }
}
