// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/utils/Context.sol";

import "./IBankAccount.sol";

contract BankAccount is Context, IBankAccount {
    IERC20 internal _token;

    constructor(IERC20 token) {
        _token = token;
    }

    function getBalance() public view override returns (uint256) {
        return _token.balanceOf(address(this));
    }

    function getToken() external view override returns (IERC20) {
        return _token;
    }

    function transferFrom(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        return _token.transfer(to, amount);
    }

    function transferTo(uint256 amount) public virtual override returns (bool) {
        address from = _msgSender();

        return _token.transferFrom(from, address(this), amount);
    }
}
