// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "../BaseDeposit.sol";

/**
 * @dev Amount condition.
 */
abstract contract AmountCondition {
    uint256 internal _amountMaximum;

    uint256 internal _amountMinimum;

    error AmountMaximumConstraint(uint256 amountMaximum, uint256 amount);
    error AmountMinimumConstraint(uint256 amountMinimum, uint256 amount);

    constructor(uint256 maximum, uint256 minimum) {
        _amountMaximum = maximum;
        _amountMinimum = minimum;
    }

    function _getAmount(BaseDeposit.Transaction[] memory transactions)
        internal
        pure
        returns (uint256)
    {
        uint256 amount = 0;

        for (uint256 i = 0; i < transactions.length; i++) {
            amount += transactions[i].amount;
        }

        return amount;
    }

    function _preValidateDeposit(
        BaseDeposit.Transaction[] memory transactions,
        uint256 amount
    ) internal view virtual {
        if (_amountMinimum > amount && transactions.length == 0) {
            revert AmountMinimumConstraint({
                amountMinimum: _amountMinimum,
                amount: amount
            });
        }

        uint256 amountExpected = _getAmount(transactions) + amount;

        if (_amountMaximum < amountExpected) {
            revert AmountMaximumConstraint({
                amountMaximum: _amountMaximum,
                amount: amountExpected
            });
        }
    }
}
