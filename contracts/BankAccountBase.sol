// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./IBankAccount.sol";

abstract contract BankAccountBase is IBankAccount {
    IERC20 internal _token;

    function __BankAccountBase_init(IERC20 token) internal {
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

    function transferTo(address from, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        return _token.transferFrom(from, address(this), amount);
    }
}
