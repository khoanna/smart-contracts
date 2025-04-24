// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract SmartRanking {
    struct Info {
        uint256 rollNumber;
        uint256 mark;
        uint256 currentRank;
    }

    Info[] public ranking;

    //this function insterts the roll number and corresponding marks of a student
    function insertMarks(uint256 _rollNumber, uint256 _marks) public {
        uint256 temp = ranking.length+1;
        for (uint256 i = 0; i < ranking.length; ++i) {
            if (_marks > ranking[i].mark) {
                if (ranking[i].currentRank < temp)
                    temp = ranking[i].currentRank;
                ranking[i].currentRank++;
            }
        }
        Info memory info = Info({
            rollNumber: _rollNumber,
            mark: _marks,
            currentRank: temp
        });
        ranking.push(info);
    }

    //this function returnsthe marks obtained by the student as per the rank
    function scoreByRank(uint256 rank) public view returns (uint256) {
        require(ranking.length > 0);
        for (uint256 i = 0; i < ranking.length; i++) {
            if (ranking[i].currentRank == rank) return ranking[i].mark;
        }
        revert();
    }

    //this function returns the roll number of a student as per the rank
    function rollNumberByRank(uint256 rank) public view returns (uint256) {
        require(ranking.length > 0);
        for (uint256 i = 0; i < ranking.length; i++) {
            if (ranking[i].currentRank == rank) return ranking[i].rollNumber;
        }
        revert();
    }
}
