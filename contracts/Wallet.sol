// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

import "./BankAccountUpgradeable.sol";

contract Wallet is Initializable, BankAccountUpgradeable {
    function __Wallet_init(IERC20 token) public initializer {
        __BankAccount_init(token);
    }

    function getUserUsernameChangingFee() public pure returns (uint256) {
        return 10;
    }

    function getTVTLLicencePrice(uint8) public pure returns (uint256) {
        return 10;
    }
}
