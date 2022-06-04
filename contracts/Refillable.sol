// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/utils/Context.sol";

import "./IBankAccount.sol";
import "./IBankAccountSupplier.sol";

abstract contract Refillable is Context, IBankAccount {
    struct RefillableSupplier {
        IBankAccountSupplier agreement;
        uint256 reward;
    }

    RefillableSupplier[] private _refillableSuppliers;

    error RefillableSupplierNotExists(address supplier);
    error RefillableTooMuchAgreements(uint8 maxNumber);

    constructor(RefillableSupplier[] memory suppliers) {
        _setRefillableAgreements(suppliers);
    }

    function isReadyToRefill(uint256 date) external view virtual returns (bool);

    function getRefillableSuppliers()
        external
        view
        returns (RefillableSupplier[] memory)
    {
        return _refillableSuppliers;
    }

    function refill() external {
        address sender = _msgSender();

        for (uint256 i = 0; i < _refillableSuppliers.length; i++) {
            RefillableSupplier memory supplier = _refillableSuppliers[i];
            supplier.agreement.pay(sender);
        }
    }

    function transferFromSupplier(
        uint256 date,
        uint256 amount,
        address sender
    ) external {
        RefillableSupplier memory supplier = _getRefillableSupplierBySender();

        uint256 rewardAmount = _getRefillableRewardAmount(
            supplier.reward,
            amount
        );

        if (amount > rewardAmount) {
            supplier.agreement.transferFrom(
                address(this),
                amount - rewardAmount
            );

            supplier.agreement.transferFrom(sender, rewardAmount);

            _postTransferFromSupplier(date, amount - rewardAmount);
        }
    }

    function _getRefillableDecimals() internal pure virtual returns (uint8) {
        return 4;
    }

    function _getRefillableRewardAmount(uint256 reward, uint256 amount)
        private
        pure
        returns (uint256)
    {
        return (amount * reward) / 10**_getRefillableDecimals();
    }

    function _getRefillableSupplierBySender()
        private
        view
        returns (RefillableSupplier memory)
    {
        address supplier = _msgSender();

        for (uint256 i = 0; i < _refillableSuppliers.length; i++) {
            if (supplier == address(_refillableSuppliers[i].agreement)) {
                return _refillableSuppliers[i];
            }
        }

        revert RefillableSupplierNotExists(supplier);
    }

    function _postTransferFromSupplier(uint256 date, uint256 amount)
        internal
        virtual;

    function _setRefillableAgreements(RefillableSupplier[] memory suppliers)
        internal
    {
        if (type(uint8).max < suppliers.length) {
            revert RefillableTooMuchAgreements({maxNumber: type(uint8).max});
        }

        delete _refillableSuppliers;

        for (uint8 i = 0; i < suppliers.length; i++) {
            _refillableSuppliers.push(suppliers[i]);
        }
    }
}
