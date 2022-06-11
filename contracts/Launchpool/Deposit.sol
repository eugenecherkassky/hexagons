// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./BaseDeposit.sol";
import "./ILaunchpool.sol";

import "./Condition/AmountCondition.sol";
import "./Condition/DepositCondition.sol";
import "./Condition/PeriodCondition.sol";
import "./Condition/TerminationCondition.sol";

contract Deposit is
    BaseDeposit,
    AmountCondition,
    DepositCondition,
    PeriodCondition,
    TerminationCondition,
    ReentrancyGuard
{
    string private _program;

    uint8 private _rate;

    error DepositAlreadyWithdrawed();

    constructor(
        ILaunchpool launchpool,
        IBankAccount treasury,
        BaseDeposit.ProgramParameters memory parameters
    )
        BaseDeposit(launchpool, treasury)
        AmountCondition(parameters.amountMaximum, parameters.amountMinimum)
        DepositCondition(parameters.isDepositable)
        PeriodCondition(parameters.periodMaximum, parameters.periodMinimum)
        TerminationCondition(
            parameters.isTerminatable,
            parameters.terminationPenalty
        )
    {
        _program = parameters.program;
        _rate = parameters.rate;
    }

    function deposit(uint256 amount) external {
        _preValidateDeposit(_transactions, amount);

        Transaction storage transaction = _addTransaction(
            TransactionKind.DEPOSIT,
            _msgSender(),
            amount
        );

        _transfer(transaction);
    }

    function isActive() public view returns (bool) {
        return isActive(block.timestamp);
    }

    function isActive(uint256 date) public view returns (bool) {
        return
            date < _getPeriodDateTime(_transactions, _periodMaximum) &&
            !isWithdrawed();
    }

    function isWithdrawable() external view returns (bool) {
        return isWithdrawable(block.timestamp);
    }

    function isWithdrawable(uint256 date) public view returns (bool) {
        return
            date < _getPeriodDateTime(_transactions, _periodMinimum) &&
            !isWithdrawed();
    }

    function isWithdrawed() public view returns (bool) {
        for (uint256 i = _transactions.length; i > 0; i--) {
            Transaction memory transaction = _transactions[i - 1];

            if (transaction.kind == TransactionKind.WITHDRAW) {
                return true;
            }
        }

        return false;
    }

    function getAmountDeposit() external view returns (uint256) {
        return _getTransactionsAmounts()[uint8(TransactionKind.DEPOSIT)];
    }

    function getAmountReward() public view returns (uint256) {
        return _getTransactionsAmounts()[uint8(TransactionKind.REWARD)];
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

    function withdraw() external onlyOwner nonReentrant {
        _preValidateWithdraw(
            _transactions,
            _getPeriodDateTime(_transactions, _periodMinimum)
        );

        _close();

        for (uint256 i = 0; i < _transactions.length; i++) {
            if (
                _transactions[i].kind == TransactionKind.PENALTY ||
                _transactions[i].kind == TransactionKind.WITHDRAW
            ) {
                _transfer(_transactions[i]);
            }
        }
    }

    function _close() private {
        _launchpool.transferDailyRewards();

        uint256 amountPenalty = _getAmountPenalty();

        _addTransaction(
            TransactionKind.WITHDRAW,
            _msgSender(),
            getBalance() - amountPenalty
        );

        if (amountPenalty > 0) {
            _addTransaction(
                TransactionKind.PENALTY,
                address(_treasury),
                amountPenalty
            );
        }
    }

    function _getAmountPenalty() private view returns (uint256) {
        if (
            block.timestamp > _getPeriodDateTime(_transactions, _periodMaximum)
        ) {
            return 0;
        }

        uint256 rewardAmount = getAmountReward();

        return (rewardAmount * _terminationPenalty) / 10**4;
    }

    function _preValidateDeposit(
        Transaction[] memory transactions,
        uint256 amount
    ) internal view override(AmountCondition, DepositCondition) {
        super._preValidateDeposit(transactions, amount);
    }

    function _preValidateWithdraw(
        Transaction[] memory transactions,
        uint256 periodMinimumDateTime
    ) internal view override(PeriodCondition, TerminationCondition) {
        if (isWithdrawed()) {
            revert DepositAlreadyWithdrawed();
        }

        super._preValidateWithdraw(transactions, periodMinimumDateTime);
    }
}
