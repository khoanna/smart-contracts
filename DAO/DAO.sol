// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DAOMembership {
    struct Voting {
        uint256 approve;
        uint256 disApprove;
        bool needVote;
        mapping(address => bool) isVote;
    }

    mapping(address => Voting) Vote;
    mapping(address => bool) isApplying;
    mapping(address => Voting) removeVote;

    uint256 memCount;
    mapping(address => bool) isMem;
    mapping(address => bool) usedToMem;

    constructor() {
        isMem[msg.sender] = true;
        usedToMem[msg.sender] = true;
        memCount++;
    }

    //To apply for membership of DAO
    function applyForEntry() public {
        require(memCount > 0);
        require(!isApplying[msg.sender]);
        require(!isMem[msg.sender], "Already member!");
        require(!usedToMem[msg.sender], "Used to member!");
        Vote[msg.sender].needVote = true;
        isApplying[msg.sender] = true;
    }

    //To approve the applicant for membership of DAO
    function approveEntry(address _applicant) public {
        require(Vote[_applicant].isVote[msg.sender] == false);
        require(isMem[msg.sender], "Not member!");
        require(Vote[_applicant].needVote == true);
        Vote[_applicant].approve++;
        Vote[_applicant].isVote[msg.sender] = true;
        if (
            Vote[_applicant].approve * 1000000 >=
            ((memCount * 30000000) * 1000000) / 100000000
        ) {
            Vote[_applicant].needVote = false;
            isMem[_applicant] = true;
            usedToMem[msg.sender] = true;
            memCount++;
        }
    }

    //To disapprove the applicant for membership of DAO
    function disapproveEntry(address _applicant) public {
        require(Vote[_applicant].isVote[msg.sender] == false);
        require(isMem[msg.sender], "Not member!");
        require(Vote[_applicant].needVote == true);
        Vote[_applicant].disApprove++;
        Vote[_applicant].isVote[msg.sender] = true;
        if (
            Vote[_applicant].disApprove * 1000000 >=
            ((memCount * 70000000) * 1000000) / 100000000
        ) {
            Vote[_applicant].needVote = false;
        }
    }

    //To remove a member from DAO
    function removeMember(address _memberToRemove) public {
        require(isMem[msg.sender], "Not member!");
        require(removeVote[_memberToRemove].isVote[msg.sender] == false);
        require(isMem[_memberToRemove]);
        require(_memberToRemove != msg.sender);
        removeVote[_memberToRemove].approve++;
        removeVote[_memberToRemove].isVote[msg.sender] == true;
        if (
            removeVote[_memberToRemove].approve * 1000000 >=
            (((memCount-1) * 70000000) * 1000000) / 100000000
        ) {
            isMem[_memberToRemove] = false;
            memCount--;
        }
    }

    //To leave DAO
    function leave() public {
        require(isMem[msg.sender], "Not member!");
        isMem[msg.sender] = false;
        memCount--;
    }

    //To check membership of DAO
    function isMember(address _user) public view returns (bool) {
        require(isMem[msg.sender]);
        return isMem[_user];
    }

    //To check total number of members of the DAO
    function totalMembers() public view returns (uint256) {
        require(isMem[msg.sender]);
        return memCount;
    }
}
