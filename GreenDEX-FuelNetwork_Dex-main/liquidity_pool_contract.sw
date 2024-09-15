
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// GreenDEX Liquidity Pool Contract - Provides liquidity management for GreenDEX platform

contract GreenLiquidityPool {
    // State variables
    address public owner;
    uint256 public greenTokenReserve;
    uint256 public etherReserve;

    // Liquidity providers' balances
    mapping(address => uint256) public liquidityBalances;

    // Events
    event LiquidityAdded(address indexed provider, uint256 greenTokenAmount, uint256 etherAmount);
    event LiquidityRemoved(address indexed provider, uint256 greenTokenAmount, uint256 etherAmount);

    // Constructor
    constructor() {
        owner = msg.sender;
        greenTokenReserve = 0;
        etherReserve = 0;
    }

    // Add liquidity to the pool
    function addLiquidity(uint256 greenTokenAmount) public payable {
        require(greenTokenAmount > 0 && msg.value > 0, "Both Green Tokens and Ether must be greater than zero.");

        greenTokenReserve += greenTokenAmount;
        etherReserve += msg.value;
        liquidityBalances[msg.sender] += msg.value; // Using ether amount to track liquidity

        emit LiquidityAdded(msg.sender, greenTokenAmount, msg.value);
    }

    // Remove liquidity from the pool
    function removeLiquidity(uint256 etherAmount) public {
        require(etherAmount > 0, "Ether amount must be greater than zero.");
        require(liquidityBalances[msg.sender] >= etherAmount, "Insufficient liquidity balance.");

        uint256 greenTokenAmount = (etherAmount * greenTokenReserve) / etherReserve;

        greenTokenReserve -= greenTokenAmount;
        etherReserve -= etherAmount;
        liquidityBalances[msg.sender] -= etherAmount;

        // Transfer the removed liquidity back to the provider
        payable(msg.sender).transfer(etherAmount);
        // Assuming transfer of greenTokenAmount from the contract's balance to the provider

        emit LiquidityRemoved(msg.sender, greenTokenAmount, etherAmount);
    }

    // Get the current liquidity pool status
    function getLiquidityStatus() public view returns (uint256, uint256) {
        return (greenTokenReserve, etherReserve);
    }

    // Modifier to restrict access to owner-only functions
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner.");
        _;
    }
}
