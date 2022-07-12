// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

abstract contract WalletUser is Initializable, OwnableUpgradeable {
    function __WalletUser_init() public initializer {
        __Ownable_init();
    }

    function getUserSetUsernamePrice() public pure returns (uint256) {
        return 1;
    }
}
