
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// GreenDEX Token Contract - Manages Green Tokens on the GreenDEX platform

contract GreenToken {
    // State variables
    string public name = "GreenToken";
    string public symbol = "GRT";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    address public owner;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Constructor
    constructor(uint256 _initialSupply) {
        owner = msg.sender;
        totalSupply = _initialSupply * 10 ** uint256(decimals);
        balanceOf[owner] = totalSupply;
    }

    // Transfer tokens from the caller's account to another account
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Invalid address.");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance.");
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // Approve an address to spend tokens on behalf of the caller
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0), "Invalid address.");

        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // Transfer tokens on behalf of an address
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Invalid address.");
        require(balanceOf[_from] >= _value, "Insufficient balance.");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded.");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    // Mint new tokens to a specific address
    function mint(address _to, uint256 _amount) public onlyOwner {
        require(_to != address(0), "Invalid address.");

        totalSupply += _amount;
        balanceOf[_to] += _amount;

        emit Transfer(address(0), _to, _amount);
    }

    // Burn tokens from a specific address
    function burn(uint256 _amount) public {
        require(balanceOf[msg.sender] >= _amount, "Insufficient balance.");

        totalSupply -= _amount;
        balanceOf[msg.sender] -= _amount;

        emit Transfer(msg.sender, address(0), _amount);
    }

    // Modifier to restrict access to owner-only functions
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner.");
        _;
    }
}
