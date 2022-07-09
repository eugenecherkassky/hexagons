// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts-upgradeable/token/ERC721/presets/ERC721PresetMinterPauserAutoIdUpgradeable.sol";

contract TVTH is ERC721PresetMinterPauserAutoIdUpgradeable {
    function __TVTH_init(
        string memory name,
        string memory symbol,
        string memory baseTokenURI
    ) public initializer {
        __ERC721PresetMinterPauserAutoId_init(name, symbol, baseTokenURI);
    }
}
