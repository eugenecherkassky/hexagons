// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/utils/Context.sol";

import "./TVTB/TVTBToken.sol";

/**
 * @title Ballot
 * @dev It's a basic contract for ballot
 */
contract Ballot is Context {
    struct Poll {
        string url;
        uint256 startDateTime;
        uint256 endDateTime;
        address[] approvers;
        uint256 totalNumberOfVoters;
    }

    Poll[] private _polls;

    TVTBToken private _token;

    error BallotAlreadyFinished(uint256 endDateTime);
    error BallotAlreadyVoted();
    error BallotHasNotFinished(uint256 endDateTime);
    error BallotHasNotStarted(uint256 startDateTime);
    error BallotNotAuthorize();

    constructor(TVTBToken token) {
        _token = token;
    }

    function close() external {
        Poll storage poll = _polls[_polls.length - 1];

        // if (poll.endDateTime > block.timestamp) {
        //     revert BallotHasNotFinished(poll.endDateTime)
        // }

        poll.totalNumberOfVoters = _getNumber();
    }

    function createPoll(
        string memory url,
        uint256 startDateTime,
        uint256 endDateTime
    ) external {
        Poll memory poll;

        poll.endDateTime = endDateTime;
        poll.startDateTime = startDateTime;
        poll.url = url;

        _polls.push(poll);
    }

    function getAll() external view returns (Poll[] memory) {
        return _polls;
    }

    function getLast() external view returns (Poll memory) {
        return _polls[_polls.length - 1];
    }

    /**
     * @return the token being sold.
     */
    function getToken() public view returns (TVTBToken) {
        return TVTBToken(address(_token));
    }

    function vote() external {
        address voter = _msgSender();

        Poll storage poll = _polls[_polls.length - 1];

        if (poll.startDateTime > block.timestamp) {
            revert BallotHasNotStarted(poll.startDateTime);
        }

        if (poll.endDateTime < block.timestamp) {
            revert BallotAlreadyFinished(poll.endDateTime);
        }

        if (!_hasToken(voter)) {
            revert BallotNotAuthorize();
        }

        if (_isVoted(poll.approvers, voter)) {
            revert BallotAlreadyVoted();
        }

        _polls[_polls.length - 1].approvers.push(voter);
    }

    function _getNumber() private view returns (uint256) {
        return getToken().getNumber();
    }

    function _isVoted(address[] memory approvers, address voter)
        private
        pure
        returns (bool)
    {
        for (uint256 i = 0; i < approvers.length; i++) {
            if (approvers[i] == voter) {
                return true;
            }
        }

        return false;
    }

    function _hasToken(address voter) private view returns (bool) {
        return getToken().balanceOf(voter) > 0;
    }
}
