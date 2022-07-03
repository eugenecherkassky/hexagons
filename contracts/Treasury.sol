// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./BankAccountSupplier.sol";

contract Treasury is Initializable, BankAccountSupplier {
    function __Treasury_init(IERC20 token) public initializer {
        __BankAccountSupplier_init(token);
    }
}
