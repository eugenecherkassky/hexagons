// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

import "./TVTB/TVTBToken.sol";

import "./IUpgradeable.sol";

/**
 * @title Poll manager
 */
contract PollManager is Initializable, ContextUpgradeable, OwnableUpgradeable {
    struct Poll {
        address proxy;
        IUpgradeable implementation;
        uint256 startDateTime;
        uint256 endDateTime;
        address[] agree;
        address[] disagree;
    }

    struct PollResult {
        address proxy;
        IUpgradeable implementation;
        uint256 startDateTime;
        uint256 endDateTime;
        uint256 agreeNumber;
        bool isAgree;
        uint256 disagreeNumber;
        bool isDisagree;
    }

    Poll[] internal _polls;

    TVTBToken internal _token;

    error PollAlreadyFinished(uint256 index, uint256 endDateTime);
    error PollAlreadyVoted(uint256 index);
    error PollDoesNotExist(uint256 index);
    error PollHasNotFinished(uint256 index, uint256 endDateTime);
    error PollHasNotStarted(uint256 index, uint256 startDateTime);
    error PollNotAuthorize();

    function create(
        address proxy,
        IUpgradeable implementation,
        uint256 startDateTime,
        uint256 endDateTime
    ) external {
        address[] memory result;

        Poll memory poll = Poll({
            proxy: proxy,
            implementation: implementation,
            startDateTime: startDateTime,
            endDateTime: endDateTime,
            agree: result,
            disagree: result
        });

        _polls.push(poll);
    }

    function initialize(TVTBToken token) public initializer {
        __Context_init();
        __Ownable_init();

        _token = token;
    }

    function getResult() external view returns (PollResult[] memory) {
        address voter = _msgSender();

        PollResult[] memory pollsResult = new PollResult[](_polls.length);

        for (uint256 i = 0; i < _polls.length; i++) {
            Poll memory poll = _polls[i];

            pollsResult[i] = PollResult({
                proxy: poll.proxy,
                implementation: poll.implementation,
                startDateTime: poll.startDateTime,
                endDateTime: poll.endDateTime,
                agreeNumber: poll.agree.length,
                isAgree: _isAgree(poll, voter),
                disagreeNumber: poll.disagree.length,
                isDisagree: _isDisagree(poll, voter)
            });
        }

        return pollsResult;
    }

    function getToken() external view returns (TVTBToken token) {
        return _token;
    }

    function vote(uint256 index, bool answer) external {
        address voter = _msgSender();

        if (!_hasToken(voter)) {
            revert PollNotAuthorize();
        }

        Poll storage poll = _get(index);

        if (poll.startDateTime > block.timestamp) {
            revert PollHasNotStarted(index, poll.startDateTime);
        }

        if (poll.endDateTime < block.timestamp) {
            revert PollAlreadyFinished(index, poll.endDateTime);
        }

        if (_isVoted(poll, voter)) {
            revert PollAlreadyVoted(index);
        }

        if (answer) {
            poll.agree.push(voter);
        } else {
            poll.disagree.push(voter);
        }
    }

    function _isAgree(Poll memory poll, address voter)
        internal
        pure
        returns (bool)
    {
        for (uint256 i = 0; i < poll.agree.length; i++) {
            if (poll.agree[i] == voter) {
                return true;
            }
        }

        return false;
    }

    function _isDisagree(Poll memory poll, address voter)
        internal
        pure
        returns (bool)
    {
        for (uint256 i = 0; i < poll.disagree.length; i++) {
            if (poll.disagree[i] == voter) {
                return true;
            }
        }

        return false;
    }

    function _isExists(uint256 index) internal view returns (bool) {
        return 0 <= index && index <= _polls.length - 1;
    }

    function _isVoted(Poll memory poll, address voter)
        internal
        pure
        returns (bool)
    {
        return _isAgree(poll, voter) || _isDisagree(poll, voter);
    }

    function _get(uint256 index) internal view returns (Poll storage) {
        if (!_isExists(index)) {
            revert PollDoesNotExist(index);
        }

        return _polls[index];
    }

    function _hasToken(address voter) internal view returns (bool) {
        return _token.balanceOf(voter) > 0;
    }
}
