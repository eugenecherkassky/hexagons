// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

import "../Crowdsale.sol";
import "../IBankAccount.sol";

/**
 * @title TVTTokenCrowdsale
 * @dev Extension of ERC20Crowdsale contract whose tokens are minted in each purchase.
 * Token ownership should be transferred to TVTTokenCrowdsale for minting.
 */
contract TVTTokenCrowdsale is Crowdsale {
    using SafeERC20 for IERC20;

    // The token being sold
    ERC20PresetMinterPauser private _token;

    constructor(
        uint256 rate,
        IBankAccount wallet,
        ERC20PresetMinterPauser token
    ) Crowdsale(rate, wallet) {
        require(
            address(token) != address(0),
            "Crowdsale: token is the zero address"
        );

        _token = token;
    }

    /**
     * @return the token being sold.
     */
    function getToken() public view returns (ERC20PresetMinterPauser) {
        return ERC20PresetMinterPauser(address(_token));
    }

    /**
     * @dev Overrides delivery by minting tokens upon purchase.
     * @param beneficiary Token purchaser
     * @param tokenAmount Number of tokens to be minted
     */
    function _deliverTokens(address beneficiary, uint256 tokenAmount)
        internal
        override
    {
        getToken().mint(beneficiary, tokenAmount);
    }
}
