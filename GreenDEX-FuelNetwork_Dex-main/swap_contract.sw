// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// GreenDEX Swap Contract - Enables token swapping on GreenDEX platform

contract GreenSwap {
    // State variables
    address public owner;
    uint256 public greenTokenReserve;
    uint256 public etherReserve;
    mapping(address => uint256) public greenTokenBalances;

    // Events
    event SwapExecuted(address indexed user, uint256 etherAmount, uint256 greenTokenAmount);

    // Constructor
    constructor() {
        owner = msg.sender;
        greenTokenReserve = 1000000; // Initial reserve of green tokens
    }

    // Swap Ether for Green Tokens
    function swapEtherForGreenTokens() public payable {
        require(msg.value > 0, "Ether amount must be greater than zero.");
        uint256 tokensToSwap = getGreenTokenAmount(msg.value);
        require(greenTokenReserve >= tokensToSwap, "Insufficient Green Token reserve.");
        
        greenTokenBalances[msg.sender] += tokensToSwap;
        greenTokenReserve -= tokensToSwap;
        etherReserve += msg.value;

        emit SwapExecuted(msg.sender, msg.value, tokensToSwap);
    }

    // Swap Green Tokens for Ether
    function swapGreenTokensForEther(uint256 greenTokenAmount) public {
        require(greenTokenAmount > 0, "Green Token amount must be greater than zero.");
        require(greenTokenBalances[msg.sender] >= greenTokenAmount, "Insufficient Green Token balance.");
        
        uint256 etherToTransfer = getEtherAmount(greenTokenAmount);
        require(etherReserve >= etherToTransfer, "Insufficient Ether reserve.");
        
        greenTokenBalances[msg.sender] -= greenTokenAmount;
        greenTokenReserve += greenTokenAmount;
        etherReserve -= etherToTransfer;
        
        payable(msg.sender).transfer(etherToTransfer);

        emit SwapExecuted(msg.sender, etherToTransfer, greenTokenAmount);
    }

    // Get the amount of Green Tokens for a given amount of Ether
    function getGreenTokenAmount(uint256 etherAmount) public view returns (uint256) {
        // Simple constant product formula: amount = etherAmount * greenTokenReserve / etherReserve
        require(etherReserve > 0, "No Ether reserve available.");
        return (etherAmount * greenTokenReserve) / etherReserve;
    }

    // Get the amount of Ether for a given amount of Green Tokens
    function getEtherAmount(uint256 greenTokenAmount) public view returns (uint256) {
        // Simple constant product formula: amount = greenTokenAmount * etherReserve / greenTokenReserve
        require(greenTokenReserve > 0, "No Green Token reserve available.");
        return (greenTokenAmount * etherReserve) / greenTokenReserve;
    }

    // Modifier to restrict access to owner-only functions
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner.");
        _;
    }
    
    // Add liquidity to the reserves
    function addLiquidity(uint256 greenTokenAmount) public payable onlyOwner {
        require(greenTokenAmount > 0 && msg.value > 0, "Both Green Tokens and Ether must be greater than zero.");
        greenTokenReserve += greenTokenAmount;
        etherReserve += msg.value;
    }
}
