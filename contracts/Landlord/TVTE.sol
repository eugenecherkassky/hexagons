// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts-upgradeable/token/ERC20/presets/ERC20PresetMinterPauserUpgradeable.sol";

contract TVTE is ERC20PresetMinterPauserUpgradeable {
    function __TVTE_init(string memory name, string memory symbol)
        public
        initializer
    {
        __ERC20PresetMinterPauser_init(name, symbol);
    }
}
