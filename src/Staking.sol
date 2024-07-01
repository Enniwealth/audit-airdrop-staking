// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleStaking {
    address public owner;
    uint256 public totalStaked;
    mapping(address => uint256) public stakedBalances;
    mapping(address => uint256) public stakingTimestamps;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount, uint256 reward);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    function stake() public payable {
        require(msg.value > 0, "Cannot stake 0 ETH");

        if (stakedBalances[msg.sender] == 0) {
            stakingTimestamps[msg.sender] = block.timestamp;
        }

        stakedBalances[msg.sender] += msg.value;
        totalStaked += msg.value;

        emit Staked(msg.sender, msg.value);
    }

    function calculateReward(address user) public view returns (uint256) {
        uint256 stakingDuration = block.timestamp - stakingTimestamps[user];
        uint256 rewardRatePerSecond = 1e15; // Example reward rate: 0.001 ETH per second per ETH staked
        uint256 reward = stakedBalances[user] * rewardRatePerSecond * stakingDuration / 1e18;
        return reward;
    }

    function withdraw() external {
        uint256 stakedAmount = stakedBalances[msg.sender];
        require(stakedAmount > 0, "No staked balance to withdraw");

        uint256 reward = calculateReward(msg.sender);

        uint256 totalAmount = stakedAmount + reward;
        totalStaked -= stakedAmount;
        stakedBalances[msg.sender] = 0;
        stakingTimestamps[msg.sender] = 0;

        payable(msg.sender).transfer(totalAmount);

        emit Withdrawn(msg.sender, stakedAmount, reward);
    }

    function contractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {
        stake();
    }
}
