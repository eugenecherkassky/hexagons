// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IBankAccount {
    function getBalance() external view returns (uint256);

    function getToken() external view returns (IERC20);

    function transferFrom(address to, uint256 amount) external returns (bool);

    function transferTo(uint256 amount) external returns (bool);
}
