// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

contract TVTToken is ERC20PresetMinterPauser {
    // initialSupply - how many tokens will be minted when contract will be created.
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) ERC20PresetMinterPauser(name, symbol) {
        // initialSupply - possible value could be passed 100 * (10 ** uint256(decimals()))
        _mint(_msgSender(), initialSupply * 10**uint256(decimals()));
    }
}
