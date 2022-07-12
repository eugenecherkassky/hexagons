// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../BankAccountUpgradeable.sol";

import "./WalletLandlord.sol";
import "./WalletUser.sol";

contract Wallet is
    Initializable,
    BankAccountUpgradeable,
    WalletLandlord,
    WalletUser
{
    function __Wallet_init(
        IERC20 token,
        Landlord.License[] memory licenses,
        Landlord.Rent[] memory rents
    ) public initializer {
        __BankAccount_init(token);
        __WalletLandlord_init(licenses, rents);
        __WalletUser_init();
    }
}
