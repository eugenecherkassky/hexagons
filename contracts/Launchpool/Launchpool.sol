// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import "../Date.sol";
import "../Refillable.sol";
import "./ILaunchpool.sol";
import "./Deposit.sol";

/**
 * @dev Launchpool
 */
contract Launchpool is BankAccount, Refillable, Initializable, ILaunchpool {
    struct DepositListItems {
        address agreement;
        Deposit.DepositParameters parameters;
    }

    Deposit[] private _deposits;

    Deposit.ProgramParameters[] private _depositPrograms;

    mapping(address => Deposit[]) private _ownerDeposits;

    mapping(uint256 => mapping(address => uint256)) private _rewards;

    mapping(uint256 => uint256) private _transfers;

    IBankAccount private _treasury;

    error LaunchpoolDepositProgramNotExists(string program);

    event LaunchpoolDepositCreated(Deposit deposit);

    constructor(
        IBankAccount treasury,
        Deposit.ProgramParameters[] memory depositPrograms,
        Refillable.RefillableSupplier[] memory refillableAgreements
    ) BankAccount(treasury.getToken()) Refillable(refillableAgreements) {
        initialize(depositPrograms, refillableAgreements);

        _treasury = treasury;
    }

    function createDeposit(string memory program) external {
        address owner = _msgSender();

        Deposit deposit = new Deposit(
            this,
            _treasury,
            getDepositProgram(program)
        );

        _deposits.push(deposit);

        _ownerDeposits[owner].push(deposit);

        deposit.transferOwnership(owner);

        emit LaunchpoolDepositCreated(deposit);
    }

    function initialize(
        Deposit.ProgramParameters[] memory depositPrograms,
        Refillable.RefillableSupplier[] memory refillableAgreements
    ) public initializer {
        delete _depositPrograms;

        for (uint8 i = 0; i < depositPrograms.length; i++) {
            _depositPrograms.push(depositPrograms[i]);
        }

        _setRefillableAgreements(refillableAgreements);
    }

    function isReadyToRefill(uint256 date)
        external
        view
        override
        returns (bool)
    {
        if (_hasActiveDepositsOnDate(date)) {
            return true;
        }

        return false;
    }

    function getDeposits() external view returns (DepositListItems[] memory) {
        address owner = _msgSender();

        DepositListItems[] memory deposits = new DepositListItems[](
            _ownerDeposits[owner].length
        );

        for (uint256 i = 0; i < _ownerDeposits[owner].length; i++) {
            Deposit deposit = _ownerDeposits[owner][i];

            deposits[i] = DepositListItems({
                agreement: address(deposit),
                parameters: deposit.getParameters()
            });
        }

        return deposits;
    }

    function getDepositProgram(string memory program)
        public
        view
        returns (Deposit.ProgramParameters memory)
    {
        for (uint8 i = 0; i < _depositPrograms.length; i++) {
            if (_isEqual(_depositPrograms[i].program, program)) {
                return _depositPrograms[i];
            }
        }

        revert LaunchpoolDepositProgramNotExists(program);
    }

    function getDepositPrograms()
        public
        view
        returns (Deposit.ProgramParameters[] memory)
    {
        return _depositPrograms;
    }

    function getTransfersAmount(uint256 date) external view returns (uint256) {
        return _transfers[_getKey(date)];
    }

    function transferDailyRewards() external override {
        // TODO can be runned not only by deposit
        address deposit = _msgSender();

        uint256 amount = _getDepositRewards(deposit);

        this.getToken().approve(deposit, amount);

        Deposit(deposit).reward(amount);
    }

    function _calculateRewards(uint256 date) private {
        uint256 totalRate = 0;

        for (uint256 i = 0; i < _deposits.length; i++) {
            if (_deposits[i].isActive(date)) {
                uint256 rate = _deposits[i].getBaseToCalculateReward(date);

                _rewards[_getKey(date)][address(_deposits[i])] = rate;

                totalRate += rate;
            }
        }

        if (totalRate == 0) {
            return;
        }

        for (uint256 i = 0; i < _deposits.length; i++) {
            if (_deposits[i].isActive(date)) {
                uint256 rate = _rewards[_getKey(date)][address(_deposits[i])];

                _rewards[_getKey(date)][address(_deposits[i])] =
                    (rate * _transfers[_getKey(date)]) /
                    totalRate;
            }
        }
    }

    function _hasActiveDepositsOnDate(uint256 date)
        private
        view
        returns (bool)
    {
        for (uint256 i = 0; i < _deposits.length; i++) {
            if (_deposits[i].isActive(date)) {
                return true;
            }
        }

        return false;
    }

    function _isEqual(string memory program1, string memory program2)
        private
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked(program1)) ==
            keccak256(abi.encodePacked(program2)));
    }

    function _getDepositRewards(address deposit)
        private
        view
        returns (uint256)
    {
        uint256 amount;

        uint256 date = Deposit(deposit).getBeginDateTime();
        uint256 end = Deposit(deposit).getPeriodMaximumDateTime();

        while (date <= end) {
            amount += _rewards[_getKey(date)][address(deposit)];
            date += 1 days;
        }

        return amount;
    }

    function _getKey(uint256 date) private pure returns (uint256) {
        return Date.toDate(date);
    }

    function _postTransferFromSupplier(uint256 date, uint256 amount)
        internal
        override
    {
        _transfers[_getKey(date)] += amount;

        _calculateRewards(date - 1 days);
    }
}
