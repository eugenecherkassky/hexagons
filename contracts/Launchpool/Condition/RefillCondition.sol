// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "../BaseDeposit.sol";

abstract contract RefillCondition {
    bool internal _isRefillable;

    error RefillConstraint();

    constructor(bool isRefillable) {
        _isRefillable = isRefillable;
    }

    function getIsRefillable() external view returns (bool) {
        return _isRefillable;
    }

    function _preValidateDeposit(
        BaseDeposit.Transaction[] memory transactions,
        uint256
    ) internal view virtual {
        if (!_isRefillable && transactions.length != 0) {
            revert RefillConstraint();
        }
    }
}
