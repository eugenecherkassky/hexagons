// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "../IBankAccount.sol";

interface ILaunchpool is IBankAccount {
    function transferDailyRewards() external;
}
