// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";

import "../Crowdsale.sol";
import "../IBankAccount.sol";

/**
 * @title TVTBTokenCrowdsale
 * @dev Extension of Crowdsale contract whose tokens are minted in each purchase.
 * Token ownership should be transferred to TVTBTokenCrowdsale for minting.
 */
contract TVTBTokenCrowdsale is Crowdsale {
    // The token being sold
    ERC721PresetMinterPauserAutoId private _token;

    error TVTTokenAlreadyBought();
    error TVTTokenOnlyOne();

    constructor(
        uint256 rate,
        IBankAccount wallet,
        ERC721PresetMinterPauserAutoId token
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
    function getToken() public view returns (ERC721PresetMinterPauserAutoId) {
        return ERC721PresetMinterPauserAutoId(address(_token));
    }

    function _balanceOf(address beneficiary) internal view returns (uint256) {
        return getToken().balanceOf(beneficiary);
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
        for (uint256 i = 0; i < tokenAmount; i++) {
            getToken().mint(beneficiary);
        }
    }

    /**
     * @dev Determines how ETH is stored/forwarded on purchases.
     */
    function _forwardFunds(uint256 weiAmount) internal override {
        if (_rate != 0) {
            super._forwardFunds(weiAmount);
        }
    }

    /**
     * @dev Override to extend the way in which ether is converted to tokens.
     * @param weiAmount Value in wei to be converted into tokens
     * @return Number of tokens that can be purchased with the specified _weiAmount
     */
    function _getTokenAmount(uint256 weiAmount)
        internal
        view
        override
        returns (uint256)
    {
        if (_rate == 0) {
            return 1;
        }

        return super._getTokenAmount(weiAmount);
    }

    function _preValidatePurchase(address beneficiary, uint256 weiAmount)
        internal
        view
        override
    {
        super._preValidatePurchase(beneficiary, weiAmount);

        uint256 tokenAmount = _getTokenAmount(weiAmount);

        if (tokenAmount != 1) {
            revert TVTTokenOnlyOne();
        }

        uint256 balance = _balanceOf(beneficiary);

        if (balance != 0) {
            revert TVTTokenAlreadyBought();
        }
    }
}
