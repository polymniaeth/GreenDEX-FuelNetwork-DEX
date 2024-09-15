// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// GreenDEX - A decentralized exchange platform

contract GreenDEX {
    // State variables
    string public name = "GreenDEX";
    address public owner;
    uint256 public greenTokenBalance;
    mapping(address => uint256) public greenTokenBalances;

    // Events
    event TokenMinted(address indexed recipient, uint256 amount);
    event TokenBurned(address indexed holder, uint256 amount);
    event TokenTransferred(address indexed from, address indexed to, uint256 amount);

    // Constructor
    constructor() {
        owner = msg.sender;
        greenTokenBalance = 1000000; // Initial supply of green tokens
        greenTokenBalances[owner] = greenTokenBalance;
    }

    // Mint new tokens
    function mintTokens(address recipient, uint256 amount) public onlyOwner {
        require(amount > 0, "Amount must be greater than zero.");
        greenTokenBalance += amount;
        greenTokenBalances[recipient] += amount;
        emit TokenMinted(recipient, amount);
    }

    // Burn tokens
    function burnTokens(uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero.");
        require(greenTokenBalances[msg.sender] >= amount, "Insufficient balance.");
        greenTokenBalances[msg.sender] -= amount;
        greenTokenBalance -= amount;
        emit TokenBurned(msg.sender, amount);
    }

    // Transfer tokens
    function transferTokens(address to, uint256 amount) public {
        require(to != address(0), "Invalid address.");
        require(amount > 0, "Amount must be greater than zero.");
        require(greenTokenBalances[msg.sender] >= amount, "Insufficient balance.");
        
        greenTokenBalances[msg.sender] -= amount;
        greenTokenBalances[to] += amount;

        emit TokenTransferred(msg.sender, to, amount);
    }

    // Modifier to restrict access to owner-only functions
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner.");
        _;
    }

    // Retrieve the balance of green tokens for a specific address
    function getBalance(address account) public view returns (uint256) {
        return greenTokenBalances[account];
    }
}
