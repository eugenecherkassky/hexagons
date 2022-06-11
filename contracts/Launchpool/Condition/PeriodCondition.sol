// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "../BaseDeposit.sol";

/**
 * @dev Period condition.
 */
abstract contract PeriodCondition {
    uint256 internal _periodMaximum;
    uint256 internal _periodMinimum;

    error PeriodMinimumConstraint(uint256 periodMinimumDateTime);

    constructor(uint256 maximum, uint256 minimum) {
        _periodMaximum = maximum;
        _periodMinimum = minimum;
    }

    function getBeginDateTime(BaseDeposit.Transaction[] memory transactions)
        public
        pure
        returns (uint256)
    {
        if (transactions.length > 0) {
            return transactions[0].payed;
        }

        return 0;
    }

    function _getPeriodDateTime(
        BaseDeposit.Transaction[] memory transactions,
        uint256 period
    ) internal pure returns (uint256) {
        uint256 beginDateTime = getBeginDateTime(transactions);

        if (beginDateTime == 0) {
            return 0;
        }

        return beginDateTime + period;
    }

    function _preValidateWithdraw(
        BaseDeposit.Transaction[] memory,
        uint256 periodMinimumDateTime
    ) internal view virtual {
        if (periodMinimumDateTime > block.timestamp) {
            revert PeriodMinimumConstraint({
                periodMinimumDateTime: periodMinimumDateTime
            });
        }
    }
}
