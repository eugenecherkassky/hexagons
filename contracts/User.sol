// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./Wallet/Wallet.sol";

contract User is OwnableUpgradeable {
    struct Profile {
        string username;
    }

    mapping(address => Profile) private _profiles;

    address[] private _users;

    Wallet private _wallet;

    function __User_init(Wallet wallet) public initializer {
        __Ownable_init();

        setWallet(wallet);
    }

    function getProfile() public view returns (Profile memory profile) {
        address sender = _msgSender();

        return _profiles[sender];
    }

    function getWallet() public view returns (Wallet) {
        return _wallet;
    }

    function setUsername(string memory username) external payable {
        address sender = _msgSender();

        _profiles[sender].username = username;

        uint256 price = _wallet.getUserSetUsernamePrice();

        require(msg.value / 10**18 == price, "Amount is not equal");

        _wallet.transferTo(sender, msg.value);
    }

    function setWallet(Wallet wallet) public onlyOwner {
        _wallet = wallet;
    }
}
