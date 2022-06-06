// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./BaseDeposit.sol";
import "./ILaunchpool.sol";

import "./Condition/AmountCondition.sol";
import "./Condition/PeriodCondition.sol";
import "./Condition/RefillCondition.sol";
import "./Condition/TerminationCondition.sol";

contract Deposit is
    BaseDeposit,
    AmountCondition,
    PeriodCondition,
    RefillCondition,
    TerminationCondition,
    ReentrancyGuard
{
    string private _program;

    uint8 private _rate;

    error DepositAlreadyClosed();

    constructor(
        ILaunchpool launchpool,
        IBankAccount treasury,
        BaseDeposit.Options memory options
    )
        BaseDeposit(launchpool, treasury)
        AmountCondition(options.amountMaximum, options.amountMinimum)
        PeriodCondition(options.periodMaximum, options.periodMinimum)
        RefillCondition(options.isRefillable)
        TerminationCondition(options.isTerminatable, options.terminationPenalty)
    {
        _program = options.program;
        _rate = options.rate;
    }

    function close() external onlyOwner nonReentrant {
        _preValidateClose(
            _transactions,
            _getPeriodDateTime(_transactions, _periodMinimum)
        );

        _launchpool.transferDailyRewards();

        uint256 penaltyAmount = _getPenaltyAmount();

        _addTransaction(
            TransactionKind.WITHDRAW,
            _msgSender(),
            getBalance() - penaltyAmount
        );

        if (penaltyAmount > 0) {
            _addTransaction(
                TransactionKind.PENALTY,
                address(_treasury),
                penaltyAmount
            );
        }
    }

    function isActive() external view returns (bool) {
        return isActive(block.timestamp);
    }

    function isActive(uint256 date) public view returns (bool) {
        return
            date < _getPeriodDateTime(_transactions, _periodMaximum) &&
            !isClosed(date);
    }

    function isClosed() public view returns (bool) {
        return isClosed(block.timestamp);
    }

    function isClosed(uint256 date) public view returns (bool) {
        for (uint256 i = _transactions.length; i > 0; i--) {
            Transaction memory transaction = _transactions[i - 1];

            if (
                transaction.kind == TransactionKind.WITHDRAW &&
                transaction.created <= date
            ) {
                return true;
            }
        }

        return false;
    }

    function getBaseToCalculateReward(uint256 date)
        external
        view
        returns (uint256)
    {
        return (_getDepositedAmountOnDate(date) * _rate) / 10**2;
    }

    function getBeginDateTime() external view returns (uint256) {
        return getBeginDateTime(_transactions);
    }

    function getPeriodMaximumDateTime() external view returns (uint256) {
        return _getPeriodDateTime(_transactions, _periodMaximum);
    }

    function getPeriodMinimumDateTime() external view returns (uint256) {
        return _getPeriodDateTime(_transactions, _periodMinimum);
    }

    function getProgram() external view returns (string memory) {
        return _program;
    }

    function getRate() external view returns (uint8) {
        return _rate;
    }

    function refill(uint256 amount) external {
        _preValidateDeposit(_transactions, amount);

        Transaction storage transaction = _addTransaction(
            TransactionKind.DEPOSIT,
            _msgSender(),
            amount
        );

        _transfer(transaction);
    }

    function withdraw() external onlyOwner {
        for (uint256 i = 0; i < _transactions.length; i++) {
            if (
                _transactions[i].kind == TransactionKind.PENALTY ||
                _transactions[i].kind == TransactionKind.WITHDRAW
            ) {
                _transfer(_transactions[i]);
            }
        }
    }

    function _getPenaltyAmount() private view returns (uint256) {
        if (
            block.timestamp > _getPeriodDateTime(_transactions, _periodMaximum)
        ) {
            return 0;
        }

        uint256 rewardAmount = _getRewardAmount();

        return (rewardAmount * _terminationPenalty) / 10**4;
    }

    function _getRewardAmount() private view returns (uint256) {
        return _getTransactionsAmounts()[uint8(TransactionKind.REWARD)];
    }

    function _preValidateClose(
        Transaction[] memory transactions,
        uint256 periodMinimumDateTime
    ) internal view override(PeriodCondition, TerminationCondition) {
        if (isClosed()) {
            revert DepositAlreadyClosed();
        }

        super._preValidateClose(transactions, periodMinimumDateTime);
    }

    function _preValidateDeposit(
        Transaction[] memory transactions,
        uint256 amount
    ) internal view override(AmountCondition, RefillCondition) {
        super._preValidateDeposit(transactions, amount);
    }
}
