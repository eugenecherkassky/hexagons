// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/utils/Context.sol";

import "./BankAccountBase.sol";

abstract contract BankAccount is Context, BankAccountBase {
    constructor(IERC20 token) {
        _token = token;
    }

    function transferTo(uint256 amount) public virtual override returns (bool) {
        address from = _msgSender();

        return _transferTo(from, amount);
    }
}
