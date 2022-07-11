// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

import "./Wallet.sol";

contract User is ContextUpgradeable {
    struct Profile {
        string username;
    }

    mapping(address => Profile) private _profiles;

    address[] private _users;

    Wallet private _wallet;

    function __User_init(Wallet wallet) public initializer {
        __Context_init();

        _wallet = wallet;
    }

    function getProfile() public view returns (Profile memory profile) {
        return _profiles[_msgSender()];
    }

    function getWallet() public view returns (Wallet) {
        return _wallet;
    }

    function setUsername(string memory username) external payable {
        address user = _msgSender();

        _profiles[user].username = username;

        uint256 price = _wallet.getUserUsernameChangingFee();

        require(msg.value / 10**18 == price, "Amount is not equal");

        _wallet.transferTo(user, msg.value);
    }
}
