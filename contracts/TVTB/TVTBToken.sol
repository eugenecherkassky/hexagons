// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract TVTBToken is ERC721PresetMinterPauserAutoId {
    using Counters for Counters.Counter;

    Counters.Counter private _counterTracker;

    constructor(
        string memory name,
        string memory symbol,
        string memory baseTokenURI
    ) ERC721PresetMinterPauserAutoId(name, symbol, baseTokenURI) {}

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
