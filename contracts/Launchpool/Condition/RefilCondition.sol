// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "../BaseDeposit.sol";

/**
 * @dev Refil condition.
 */
abstract contract RefilCondition {
    bool internal _isRefillable;

    error RefilConstraint();

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
            revert RefilConstraint();
        }
    }
}
