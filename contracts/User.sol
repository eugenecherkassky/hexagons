// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

import "./Wallet.sol";

contract User is Initializable, OwnableUpgradeable {
    struct Profile {
        string username;
    }

    mapping(address => Profile) private _profiles;

    address[] private _users;

    Wallet private _wallet;

    function __User_init(Wallet wallet) public initializer {
        __Ownable_init();

        _wallet = wallet;
    }

    function getProfile() public view returns (Profile memory profile) {
        return _profiles[_msgSender()];
    }

    function setUsername(string memory username) external {
        address user = _msgSender();

        _profiles[user].username = username;

        _wallet.transferTo(user, _wallet.getUserUsernameChangingFee());
    }
}
