// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "../BaseDeposit.sol";

abstract contract DepositCondition {
    bool internal _isDepositable;

    error DepositConstraint();

    constructor(bool isDepositable) {
        _isDepositable = isDepositable;
    }

    function getIsDepositable() external view returns (bool) {
        return _isDepositable;
    }

    function _preValidateDeposit(
        BaseDeposit.Transaction[] memory transactions,
        uint256
    ) internal view virtual {
        if (!_isDepositable && transactions.length != 0) {
            revert DepositConstraint();
        }
    }
}
