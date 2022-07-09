// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts-upgradeable/token/ERC721/presets/ERC721PresetMinterPauserAutoIdUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

contract TVTV is ERC721PresetMinterPauserAutoIdUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    CountersUpgradeable.Counter private _counterTracker;

    function __TVTV_init(
        string memory name,
        string memory symbol,
        string memory baseTokenURI
    ) public initializer {
        __ERC721PresetMinterPauserAutoId_init(name, symbol, baseTokenURI);
    }

    function burn(uint256 tokenId) public override {
        super.burn(tokenId);

        _counterTracker.decrement();
    }

    function getNumber() external view returns (uint256) {
        return _counterTracker.current();
    }

    function mint(address to) public override {
        super.mint(to);

        _counterTracker.increment();
    }
}
