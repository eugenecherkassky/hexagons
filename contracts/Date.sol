// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

library Date {
    function toDate(uint256 datetime) internal pure returns (uint256) {
        return datetime - (datetime % 1 days);
    }
}
