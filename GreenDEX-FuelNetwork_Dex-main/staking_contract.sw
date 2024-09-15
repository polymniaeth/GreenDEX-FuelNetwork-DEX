// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// GreenDEX Staking Contract - Enables staking of Green Tokens for rewards

contract GreenStaking {
    // State variables
    address public owner;
    uint256 public rewardRate; // Reward rate per block
    uint256 public totalStaked;
    
    // Mapping of staked balances and reward balances
    mapping(address => uint256) public stakedBalances;
    mapping(address => uint256) public rewardBalances;

    // Events
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardsClaimed(address indexed user, uint256 reward);

    // Constructor
    constructor(uint256 _rewardRate) {
        owner = msg.sender;
        rewardRate = _rewardRate;
    }

    // Stake Green Tokens
    function stakeTokens(uint256 _amount) public {
        require(_amount > 0, "Amount must be greater than zero.");
        
        // Transfer the tokens to this contract for staking (assuming the tokens are approved)
        // Assume there is a transferFrom function in the GreenToken contract
        stakedBalances[msg.sender] += _amount;
        totalStaked += _amount;

        emit Staked(msg.sender, _amount);
    }

    // Unstake Green Tokens
    function unstakeTokens(uint256 _amount) public {
        require(_amount > 0, "Amount must be greater than zero.");
        require(stakedBalances[msg.sender] >= _amount, "Insufficient staked balance.");

        stakedBalances[msg.sender] -= _amount;
        totalStaked -= _amount;

        // Transfer the unstaked tokens back to the user
        // Assume there is a transfer function in the GreenToken contract

        emit Unstaked(msg.sender, _am
