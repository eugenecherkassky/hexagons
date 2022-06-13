// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./BankAccountSupplier.sol";

contract Mint is BankAccountSupplier {
    constructor(IERC20 token) BankAccountSupplier(token) {}

    function distribute() external override {
        uint256 date = _getLastPaymentDate();

        if (date == 0) {
            date = Date.toDate(block.timestamp);
        }

        uint256 firstDate = _getFirstPaymentDate();

        if (firstDate == 0) {
            firstDate = Date.toDate(block.timestamp);
        }

        while (date < block.timestamp) {
            _createPayments(date, _getAmountOnDay((date - firstDate) / 1 days));

            date += 1 days;
        }
    }

    function getDistributionAmounts(uint256 numberOfDays)
        external
        view
        returns (uint256[] memory)
    {
        uint256[] memory amounts = new uint256[](numberOfDays);

        for (uint256 i = 0; i < numberOfDays; i++) {
            amounts[i] = _getAmountOnDay(i);
        }

        return amounts;
    }

    function _getAmountOnDay(uint256 day) private view returns (uint256) {
        uint256 balance = getBalance();

        uint256 amount = (288 * (59 * 10**6 - day * 73972)) / 10**4;

        if (balance < amount) {
            return balance;
        }

        return amount;
    }
}
