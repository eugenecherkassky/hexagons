// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "../BaseDeposit.sol";

/**
 * @dev Termination condition.
 */
abstract contract TerminationCondition {
    bool internal _isTerminatable;

    uint8 internal _terminationPenalty;

    error TerminationConstraint();

    constructor(bool isTerminatable, uint8 terminationPenalty) {
        _isTerminatable = isTerminatable;
        _terminationPenalty = terminationPenalty;
    }

    function getIsTerminatable() external view returns (bool) {
        return _isTerminatable;
    }

    function getTerminationPenalty() external view returns (uint8) {
        return _terminationPenalty;
    }

    function _preValidateClose(
        BaseDeposit.Transaction[] memory,
        uint256 periodMinimumDateTime
    ) internal view virtual {
        if (!_isTerminatable && periodMinimumDateTime > block.timestamp) {
            revert TerminationConstraint();
        }
    }
}
