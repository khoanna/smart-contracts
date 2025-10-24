// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SimpleDAOVote {
    IERC20 public governanceToken;
    address public owner;
    uint256 public proposalCount;

    constructor(address _token) {
        governanceToken = IERC20(_token); 
        owner = msg.sender;
    }

    enum VoteOption { None, Yes, No }

    struct Proposal {
        string description;
        uint256 yesVotes;
        uint256 noVotes;
        uint256 startTime;
        uint256 endTime;
        bool executed;
    }

    mapping(uint256 => mapping(address => VoteOption)) public voteRecords;
    mapping(uint256 => Proposal) public proposals;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier proposalExists(uint256 proposalId) {
        require(proposalId < proposalCount, "Invalid proposal ID");
        _;
    }

    function createProposal(string memory _description, uint256 _durationInSeconds) external onlyOwner {
        proposals[proposalCount] = Proposal({
            description: _description,
            yesVotes: 0,
            noVotes: 0,
            startTime: block.timestamp,
            endTime: block.timestamp + _durationInSeconds,
            executed: false
        });
        proposalCount++;
    }

    function vote(uint256 proposalId, bool support) external proposalExists(proposalId) {
        Proposal storage p = proposals[proposalId];
        require(block.timestamp >= p.startTime && block.timestamp <= p.endTime, "Voting closed");
        require(voteRecords[proposalId][msg.sender] == VoteOption.None, "Already voted");

        uint256 weight = governanceToken.balanceOf(msg.sender);
        require(weight > 0, "No governance token");

        if (support) {
            p.yesVotes += weight;
            voteRecords[proposalId][msg.sender] = VoteOption.Yes;
        } else {
            p.noVotes += weight;
            voteRecords[proposalId][msg.sender] = VoteOption.No;
        }
    }

    function getProposal(uint256 proposalId) external view proposalExists(proposalId)
        returns (string memory description, uint256 yes, uint256 no, uint256 start, uint256 end, bool executed)
    {
        Proposal storage p = proposals[proposalId];
        return (p.description, p.yesVotes, p.noVotes, p.startTime, p.endTime, p.executed);
    }

    function getAllProposals() external view returns (
        string[] memory descriptions,
        uint256[] memory yesVotes,
        uint256[] memory noVotes,
        uint256[] memory starts,
        uint256[] memory ends,
        bool[] memory executed
    ) {
        descriptions = new string[](proposalCount);
        yesVotes = new uint256[](proposalCount);
        noVotes = new uint256[](proposalCount);
        starts = new uint256[](proposalCount);
        ends = new uint256[](proposalCount);
        executed = new bool[](proposalCount);

        for (uint256 i = 0; i < proposalCount; i++) {
            Proposal storage p = proposals[i];
            descriptions[i] = p.description;
            yesVotes[i] = p.yesVotes;
            noVotes[i] = p.noVotes;
            starts[i] = p.startTime;
            ends[i] = p.endTime;
            executed[i] = p.executed;
        }
    }

    function hasVoted(uint256 proposalId, address user) external view returns (VoteOption) {
        return voteRecords[proposalId][user];
    }
}
