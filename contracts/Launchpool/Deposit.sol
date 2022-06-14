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
        Deposit.ProgramParameters memory parameters
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

    receive() external payable {
        _deposit(msg.sender, msg.value / 10**18);
    }

    function isActive() public view returns (bool) {
        return isActive(block.timestamp);
    }

    function isActive(uint256 date) public view returns (bool) {
        return
            date < _getPeriodDateTime(_transactions, _periodMaximum) &&
            !_isWithdrawed();
    }

    function getBaseToCalculateReward(uint256 date)
        external
        view
        returns (uint256)
    {
        return (_getDepositedAmountOnDate(date) * _rate) / 10**2;
    }

    function getBeginDateTime() public view returns (uint256) {
        return getBeginDateTime(_transactions);
    }

    function getParameters()
        external
        view
        returns (BaseDeposit.DepositParameters memory)
    {
        return
            BaseDeposit.DepositParameters({
                amount: getBalance(),
                amountDeposit: _getTransactionsAmounts()[
                    uint8(TransactionKind.DEPOSIT)
                ],
                amountMaximum: _amountMaximum,
                amountMinimum: _amountMinimum,
                amountReward: _getTransactionsAmounts()[
                    uint8(TransactionKind.REWARD)
                ],
                beginDateTime: getBeginDateTime(),
                isActive: isActive(),
                isDepositable: _isDepositable,
                isTerminatable: _isTerminatable,
                isWithdrawable: _isWithdrawable(),
                isWithdrawed: _isWithdrawed(),
                periodMaximum: _periodMaximum,
                periodMinimum: _periodMinimum,
                program: _program,
                rate: _rate,
                terminationPenalty: _terminationPenalty
            });
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

    function _deposit(address sender, uint256 amount) private {
        _preValidateDeposit(_transactions, amount);

        Transaction storage transaction = _addTransaction(
            TransactionKind.DEPOSIT,
            sender,
            amount
        );

        _transfer(transaction);
    }

    function _isWithdrawable() private view returns (bool) {
        return _isWithdrawable(block.timestamp);
    }

    function _isWithdrawable(uint256 date) private view returns (bool) {
        return
            date < _getPeriodDateTime(_transactions, _periodMinimum) &&
            !_isWithdrawed();
    }

    function _isWithdrawed() private view returns (bool) {
        for (uint256 i = _transactions.length; i > 0; i--) {
            Transaction memory transaction = _transactions[i - 1];

            if (transaction.kind == TransactionKind.WITHDRAW) {
                return true;
            }
        }

        return false;
    }

    function _getAmountPenalty() private view returns (uint256) {
        if (
            block.timestamp > _getPeriodDateTime(_transactions, _periodMaximum)
        ) {
            return 0;
        }

        uint256 amountReward = _getTransactionsAmounts()[
            uint8(TransactionKind.REWARD)
        ];

        return (amountReward * _terminationPenalty) / 10**4;
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
        if (_isWithdrawed()) {
            revert DepositAlreadyWithdrawed();
        }

        super._preValidateWithdraw(transactions, periodMinimumDateTime);
    }
}
