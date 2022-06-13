// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./IBankAccount.sol";
import "./Refillable.sol";

struct BankAccountRecipient {
    Refillable agreement;
    uint8 share;
}

struct Payment {
    Refillable agreement;
    uint256 amount;
    uint256 date;
    uint256 payed;
    uint8 share;
}

interface IBankAccountSupplier is IBankAccount {
    function getRecipients()
        external
        view
        returns (BankAccountRecipient[] memory);

    function distribute() external;

    function getPayments() external view returns (Payment[] memory);

    function pay(address sender) external;
}
