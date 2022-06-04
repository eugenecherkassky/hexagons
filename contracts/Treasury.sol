// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./BankAccountSupplier.sol";

contract Treasury is BankAccountSupplier {
    constructor(IERC20 token) BankAccountSupplier(token) {}
}
