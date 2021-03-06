// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

import "./BankAccountBase.sol";

abstract contract BankAccountUpgradeable is
    Initializable,
    ContextUpgradeable,
    BankAccountBase
{
    function __BankAccount_init(IERC20 token) internal onlyInitializing {
        __Context_init();

        _token = token;
    }

    function transferTo(uint256 amount) public virtual override returns (bool) {
        address from = _msgSender();

        return _transferTo(from, amount);
    }
}
