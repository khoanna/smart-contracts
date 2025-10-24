// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenFaucet {
    IERC20 public token;

    uint256 public amountPerClaim;

    uint256 public claimCooldown;

    mapping(address => uint256) public lastClaimTime;

    event Claimed(address indexed user, uint256 amount);

    constructor(
        address _token,
        uint256 _amountPerClaim,
        uint256 _claimCooldown
    ) {
        token = IERC20(_token);
        amountPerClaim = _amountPerClaim * 10 ** 18;
        claimCooldown = _claimCooldown;
    }

    function claim() external {
        require(
            block.timestamp >= lastClaimTime[msg.sender] + claimCooldown,
            "You must wait before claiming again."
        );

        require(
            token.transfer(msg.sender, amountPerClaim),
            "Token transfer failed."
        );

        lastClaimTime[msg.sender] = block.timestamp;

        emit Claimed(msg.sender, amountPerClaim);
    }

    function faucetBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    address public owner = msg.sender;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can execute this");
        _;
    }

    function setAmountPerClaim(uint256 _amountPerClaim) external onlyOwner {
        amountPerClaim = _amountPerClaim;
    }

    function setClaimCooldown(uint256 _claimCooldown) external onlyOwner {
        claimCooldown = _claimCooldown;
    }
}
