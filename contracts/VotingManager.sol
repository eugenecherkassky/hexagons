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
        bytes32 id;
        address proxy;
        IUpgradeable implementation;
        uint256 endDateTime;
        string git;
        address[] agree;
        address[] disagree;
        uint256 approvedDateTime;
    }

    struct VotingResult {
        bytes32 id;
        address proxy;
        IUpgradeable implementation;
        uint256 endDateTime;
        string git;
        uint256 agreeNumber;
        bool isAgree;
        uint256 disagreeNumber;
        bool isDisagree;
        uint256 approvedDateTime;
    }

    Voting[] internal _votings;

    TVTVToken internal _token;

    error VotingAlreadyApproved(bytes32 id);
    error VotingAlreadyEnded(bytes32 id, uint256 endDateTime);
    error VotingAlreadyVoted(bytes32 id);
    error VotingDoesNotExist(bytes32 id);
    error VotingHasNotFinished(bytes32 id, uint256 endDateTime);
    error VotingNotAuthorize();
    error VotingNotEnded(bytes32 id, uint256 endDateTime);
    error VotintApprovedIsNotPossible(bytes32 id);

    event VotingManagerAdded(bytes32 id);

    function add(
        address proxy,
        IUpgradeable implementation,
        uint256 endDateTime,
        string memory git
    ) external onlyOwner {
        address[] memory result;

        Voting memory voting = Voting({
            id: keccak256(abi.encodePacked(proxy, implementation)),
            proxy: proxy,
            implementation: implementation,
            endDateTime: endDateTime,
            git: git,
            agree: result,
            disagree: result,
            approvedDateTime: 0
        });

        _votings.push(voting);

        emit VotingManagerAdded(voting.id);
    }

    function approve(bytes32 id) external {
        Voting storage voting = _get(id);

        if (voting.approvedDateTime != 0) {
            revert VotingAlreadyApproved(id);
        }

        if (voting.agree.length <= voting.disagree.length) {
            revert VotintApprovedIsNotPossible(id);
        }

        if (voting.endDateTime > block.timestamp) {
            revert VotingNotEnded(id, voting.endDateTime);
        }

        voting.approvedDateTime = block.timestamp;
    }

    function __VotingManager_init(TVTVToken token) public initializer {
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
                id: voting.id,
                proxy: voting.proxy,
                implementation: voting.implementation,
                endDateTime: voting.endDateTime,
                git: voting.git,
                agreeNumber: voting.agree.length,
                isAgree: _isInVoters(voting.agree, voter),
                disagreeNumber: voting.disagree.length,
                isDisagree: _isInVoters(voting.disagree, voter),
                approvedDateTime: voting.approvedDateTime
            });
        }

        return votingsResult;
    }

    function getToken() external view returns (TVTVToken token) {
        return _token;
    }

    function remove(bytes32 id) external onlyOwner {
        bool found = false;

        for (uint256 i = 0; i < _votings.length - 1; i++) {
            if (!found && _votings[i].id == id) {
                found = true;
            }

            if (found) {
                _votings[i] = _votings[i + 1];
            }
        }

        _votings.pop();
    }

    function vote(bytes32 id, bool answer) external {
        address voter = _msgSender();

        if (!_hasToken(voter)) {
            revert VotingNotAuthorize();
        }

        Voting storage voting = _get(id);

        if (voting.endDateTime < block.timestamp) {
            revert VotingAlreadyEnded(id, voting.endDateTime);
        }

        if (_isVoted(voting, voter)) {
            revert VotingAlreadyVoted(id);
        }

        if (answer) {
            voting.agree.push(voter);
        } else {
            voting.disagree.push(voter);
        }
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

    function _get(bytes32 id) internal view returns (Voting storage) {
        for (uint256 i = 0; i < _votings.length; i++) {
            if (_votings[i].id == id) {
                return _votings[i];
            }
        }

        revert VotingDoesNotExist(id);
    }

    function _hasToken(address voter) internal view returns (bool) {
        return _token.balanceOf(voter) > 0;
    }
}
