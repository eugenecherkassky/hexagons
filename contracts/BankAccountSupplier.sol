// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./BankAccountUpgradeable.sol";
import "./Date.sol";
import "./IBankAccountSupplier.sol";

abstract contract BankAccountSupplier is
    Initializable,
    OwnableUpgradeable,
    BankAccountUpgradeable,
    IBankAccountSupplier
{
    BankAccountRecipient[] internal _recipients;

    Payment[] internal _payments;

    error BankAccountSupplierTooMuchRecipients(uint8 maxNumber);
    error BankAccountSuppliertTotalSharesIsNotValid();

    function __BankAccountSupplier_init(IERC20 token)
        internal
        onlyInitializing
    {
        __Ownable_init();
        __BankAccount_init(token);
    }

    function distribute() external virtual override {}

    function getRecipients()
        external
        view
        override
        returns (BankAccountRecipient[] memory)
    {
        return _recipients;
    }

    function getPayments() external view override returns (Payment[] memory) {
        return _payments;
    }

    function pay(address sender) external override {
        address recipient = _msgSender();

        for (uint256 i = _payments.length; i > 0; i--) {
            Payment storage payment = _payments[i - 1];

            if (recipient == address(payment.agreement)) {
                if (payment.payed != 0) {
                    return;
                }

                payment.payed = block.timestamp;

                _approvePayment(payment);

                payment.agreement.transferFromSupplier(
                    payment.date,
                    payment.amount,
                    sender
                );
            }
        }
    }

    function setRecipients(BankAccountRecipient[] memory recipients)
        external
        onlyOwner
    {
        if (type(uint8).max < recipients.length) {
            revert BankAccountSupplierTooMuchRecipients({
                maxNumber: type(uint8).max
            });
        }

        if (_getTotalShares(recipients) != 100) {
            revert BankAccountSuppliertTotalSharesIsNotValid();
        }

        delete _recipients;

        for (uint8 i = 0; i < recipients.length; i++) {
            _recipients.push(recipients[i]);
        }
    }

    function _approvePayment(Payment memory payment) private returns (bool) {
        uint256 amount = _token.allowance(
            address(this),
            address(payment.agreement)
        );

        return
            _token.approve(address(payment.agreement), amount + payment.amount);
    }

    function _createPayments(uint256 date, uint256 total) internal virtual {
        for (uint8 i = 0; i < _recipients.length; i++) {
            uint256 amount = _recipients[i].agreement.isReadyToRefill(date)
                ? (total * _recipients[i].share) / 100
                : 0;

            Payment memory payment = Payment({
                agreement: _recipients[i].agreement,
                amount: amount,
                date: date,
                payed: amount > 0 ? 0 : block.timestamp,
                share: _recipients[i].share
            });

            _payments.push(payment);
        }
    }

    function _getFirstPaymentDate() internal view returns (uint256) {
        if (_payments.length > 0) {
            return _payments[0].date;
        }

        return 0;
    }

    function _getLastPaymentDate() internal view returns (uint256) {
        if (_payments.length > 0) {
            return _payments[_payments.length - 1].date;
        }

        return 0;
    }

    function _getTotalShares(BankAccountRecipient[] memory recipients)
        private
        pure
        returns (uint8)
    {
        uint8 totalShares = 0;

        for (uint8 i = 0; i < recipients.length; i++) {
            totalShares += recipients[i].share;
        }

        return totalShares;
    }
}
