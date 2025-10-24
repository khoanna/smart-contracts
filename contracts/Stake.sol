// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ConstantK.sol";
import "./VNST.sol";

contract Staking {
    CPAMM public token;
    VNST public  rewardToken;
    enum StakingDuration { DAYS_30, DAYS_60, DAYS_90 }

    struct Stake {
        uint256 amount;       
        uint256 startTime;   
        StakingDuration duration; 
        bool withdrawn;       
    }

    mapping(address => Stake[]) public stakes;

    uint256 public constant REWARD_30 = 5;   
    uint256 public constant REWARD_60 = 8; 
    uint256 public constant REWARD_90 = 17;  
    uint256 public constant BASIS_POINTS = 100;

    constructor(address _stakingToken, address _rewardToken) {
        token = CPAMM(_stakingToken);
        rewardToken = VNST(_rewardToken);
    }

    function stake(uint256 amount, StakingDuration _duration) external {
        require(amount > 0, "Invalid input!");

        require(token.transferFrom(msg.sender, address(this), amount * 10 ** 18), "Transfer failed!");

        stakes[msg.sender].push(Stake({
            amount: amount,
            startTime: block.timestamp,
            duration: _duration,
            withdrawn: false
        }));
    }

    function withdraw(uint256 stakeIndex) external {
        require(stakeIndex < stakes[msg.sender].length, "Error!");
        Stake storage userStake = stakes[msg.sender][stakeIndex];
        require(!userStake.withdrawn, "Withdrawn!");

        uint256 stakingPeriod;
        uint256 reward;
        if (userStake.duration == StakingDuration.DAYS_30) {
            stakingPeriod = 30 days;
            reward = REWARD_30;
        } else if (userStake.duration == StakingDuration.DAYS_60) {
            stakingPeriod = 60 days;
            reward = REWARD_60;
        } else if (userStake.duration == StakingDuration.DAYS_90) {
            stakingPeriod = 90 days;
            reward = REWARD_90;
        }
        require(block.timestamp >= userStake.startTime + stakingPeriod, "Staking not ended");
        userStake.withdrawn = true;
        require(rewardToken.transfer(msg.sender, (userStake.amount * reward * 10 **18)/BASIS_POINTS), "Withdrawn Failed!");
        require(token.transfer(msg.sender, userStake.amount * 10 **18), "Withdrawn Failed!");
    }

    function getUserStakes(address user) external view returns (Stake[] memory) {
        return stakes[user];
    }

}