// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../BankAccountUpgradeable.sol";
import "../Date.sol";
import "../IUpgradeable.sol";
import "../Refillable.sol";

import "./Deposit.sol";
import "./ILaunchpool.sol";

/**
 * @dev Launchpool
 */
contract Launchpool is
    Initializable,
    OwnableUpgradeable,
    BankAccountUpgradeable,
    Refillable,
    ILaunchpool,
    IUpgradeable
{
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
    error LaunchpoolTooMuchDepositPrograms(uint8 maxNumber);

    event LaunchpoolDepositCreated(Deposit deposit);

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

    function initialize(IBankAccount treasury) public initializer {
        __Ownable_init();
        __BankAccount_init(treasury.getToken());
        __Refillable_init();

        _treasury = treasury;
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

    function getName() external pure override returns (string memory) {
        return "Launchpool";
    }

    function getTransfersAmount(uint256 date) external view returns (uint256) {
        return _transfers[_getKey(date)];
    }

    function setDepositPrograms(
        Deposit.ProgramParameters[] memory depositPrograms
    ) external onlyOwner {
        if (type(uint8).max < depositPrograms.length) {
            revert LaunchpoolTooMuchDepositPrograms({
                maxNumber: type(uint8).max
            });
        }

        delete _depositPrograms;

        for (uint8 i = 0; i < depositPrograms.length; i++) {
            _depositPrograms.push(depositPrograms[i]);
        }
    }

    function transferDailyRewards() external override {
        // TODO can be runned not only by deposit
        address payable deposit = payable(_msgSender());

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

    function _getDepositRewards(address payable deposit)
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
