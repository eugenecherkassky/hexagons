// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

import "./TVTV/TVTVToken.sol";

import "./IUpgradeable.sol";

/**
 * @title Voating manager
 */
contract VotingManager is
    Initializable,
    ContextUpgradeable,
    OwnableUpgradeable
{
    struct Voting {
        address proxy;
        IUpgradeable implementation;
        uint256 startDateTime;
        uint256 endDateTime;
        address[] agree;
        address[] disagree;
    }

    struct VotingResult {
        address proxy;
        IUpgradeable implementation;
        uint256 startDateTime;
        uint256 endDateTime;
        uint256 agreeNumber;
        bool isAgree;
        uint256 disagreeNumber;
        bool isDisagree;
    }

    Voting[] internal _votings;

    TVTVToken internal _token;

    error VotingAlreadyFinished(uint256 index, uint256 endDateTime);
    error VotingAlreadyVoted(uint256 index);
    error VotingDoesNotExist(uint256 index);
    error VotingHasNotFinished(uint256 index, uint256 endDateTime);
    error VotingHasNotStarted(uint256 index, uint256 startDateTime);
    error VotingNotAuthorize();

    function add(
        address proxy,
        IUpgradeable implementation,
        uint256 startDateTime,
        uint256 endDateTime
    ) external onlyOwner {
        address[] memory result;

        Voting memory voting = Voting({
            proxy: proxy,
            implementation: implementation,
            startDateTime: startDateTime,
            endDateTime: endDateTime,
            agree: result,
            disagree: result
        });

        _votings.push(voting);
    }

    function initialize(TVTVToken token) public initializer {
        __Context_init();
        __Ownable_init();

        _token = token;
    }

    function getResult() external view returns (VotingResult[] memory) {
        address voter = _msgSender();

        VotingResult[] memory votingsResult = new VotingResult[](
            _votings.length
        );

        for (uint256 i = 0; i < _votings.length; i++) {
            Voting memory voting = _votings[i];

            votingsResult[i] = VotingResult({
                proxy: voting.proxy,
                implementation: voting.implementation,
                startDateTime: voting.startDateTime,
                endDateTime: voting.endDateTime,
                agreeNumber: voting.agree.length,
                isAgree: _isInVoters(voting.agree, voter),
                disagreeNumber: voting.disagree.length,
                isDisagree: _isInVoters(voting.disagree, voter)
            });
        }

        return votingsResult;
    }

    function getToken() external view returns (TVTVToken token) {
        return _token;
    }

    function remove(uint256 index) external onlyOwner {
        if (!_isExists(index)) {
            revert VotingDoesNotExist(index);
        }

        for (uint256 i = index; i < _votings.length - 1; i++) {
            _votings[i] = _votings[i + 1];
        }

        _votings.pop();
    }

    function vote(uint256 index, bool answer) external {
        address voter = _msgSender();

        if (!_hasToken(voter)) {
            revert VotingNotAuthorize();
        }

        Voting storage voting = _get(index);

        if (voting.startDateTime > block.timestamp) {
            revert VotingHasNotStarted(index, voting.startDateTime);
        }

        if (voting.endDateTime < block.timestamp) {
            revert VotingAlreadyFinished(index, voting.endDateTime);
        }

        if (_isVoted(voting, voter)) {
            revert VotingAlreadyVoted(index);
        }

        if (answer) {
            voting.agree.push(voter);
        } else {
            voting.disagree.push(voter);
        }
    }

    function _isExists(uint256 index) internal view returns (bool) {
        return 0 <= index && index <= _votings.length - 1;
    }

    function _isInVoters(address[] memory voters, address voter)
        internal
        pure
        returns (bool)
    {
        for (uint256 i = 0; i < voters.length; i++) {
            if (voters[i] == voter) {
                return true;
            }
        }

        return false;
    }

    function _isVoted(Voting memory voting, address voter)
        internal
        pure
        returns (bool)
    {
        return
            _isInVoters(voting.agree, voter) ||
            _isInVoters(voting.disagree, voter);
    }

    function _get(uint256 index) internal view returns (Voting storage) {
        if (!_isExists(index)) {
            revert VotingDoesNotExist(index);
        }

        return _votings[index];
    }

    function _hasToken(address voter) internal view returns (bool) {
        return _token.balanceOf(voter) > 0;
    }
}
