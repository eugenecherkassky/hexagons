// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../BankAccount.sol";

import "./ILaunchpool.sol";

/**
 * @dev Base deposit
 */
abstract contract BaseDeposit is Ownable, AccessControl, BankAccount {
    struct Options {
        uint256 amountMaximum;
        uint256 amountMinimum;
        bool isRefillable;
        bool isTerminatable;
        uint256 periodMaximum;
        uint256 periodMinimum;
        string program;
        uint8 rate;
        uint8 terminationPenalty;
    }

    enum TransactionKind {
        DEPOSIT,
        PENALTY,
        REWARD,
        WITHDRAW
    }

    struct Transaction {
        TransactionKind kind;
        address account;
        uint256 amount;
        uint256 created;
        uint256 payed;
    }

    bytes32 public constant REWARD_ROLE = keccak256("REWARD_ROLE");

    ILaunchpool internal _launchpool;

    Transaction[] internal _transactions;

    IBankAccount internal _treasury;

    constructor(ILaunchpool launchpool, IBankAccount treasury)
        Ownable()
        BankAccount(launchpool.getToken())
    {
        _launchpool = launchpool;
        _treasury = treasury;

        _grantRole(DEFAULT_ADMIN_ROLE, address(_launchpool));
        _grantRole(REWARD_ROLE, address(_launchpool));
    }

    function getLaunchpool() external view returns (ILaunchpool) {
        return _launchpool;
    }

    function getTransactions() external view returns (Transaction[] memory) {
        return _transactions;
    }

    function getTreasury() external view returns (IBankAccount) {
        return _treasury;
    }

    function reward(uint256 amount) external onlyRole(REWARD_ROLE) {
        Transaction storage transaction = _addTransaction(
            TransactionKind.REWARD,
            _msgSender(),
            amount
        );

        _transfer(transaction);
    }

    function transferFrom(address, uint256)
        public
        pure
        override
        returns (bool)
    {
        return false;
    }

    function transferTo(uint256) public pure override returns (bool) {
        return false;
    }

    function _addTransaction(
        TransactionKind kind,
        address account,
        uint256 amount
    ) internal virtual returns (Transaction storage) {
        Transaction memory transaction = Transaction({
            account: account,
            amount: amount,
            created: block.timestamp,
            kind: kind,
            payed: 0
        });

        _transactions.push(transaction);

        return _transactions[_transactions.length - 1];
    }

    function _getDepositedAmountOnDate(uint256 date)
        public
        view
        returns (uint256)
    {
        uint256 amount = 0;

        for (uint256 i = 0; i < _transactions.length; i++) {
            if (_transactions[i].created > date - 1 days) {
                return amount;
            }

            if (_transactions[i].kind == TransactionKind.DEPOSIT) {
                amount += _transactions[i].amount;
            }
        }

        return amount;
    }

    function _getTransactionsAmounts()
        internal
        view
        returns (uint256[] memory)
    {
        uint256[] memory amounts = new uint256[](4);

        for (uint256 i = 0; i < _transactions.length; i++) {
            amounts[uint8(_transactions[i].kind)] += _transactions[i].amount;
        }

        return amounts;
    }

    function _transfer(Transaction storage transaction)
        internal
        virtual
        returns (bool)
    {
        require(transaction.payed == 0, "Transaction is already payed");

        transaction.payed = block.timestamp;

        if (transaction.kind == TransactionKind.DEPOSIT) {
            return super.transferTo(transaction.amount);
        }

        return super.transferFrom(transaction.account, transaction.amount);
    }
}
