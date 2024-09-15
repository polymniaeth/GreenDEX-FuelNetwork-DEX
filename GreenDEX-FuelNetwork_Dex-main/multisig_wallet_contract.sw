// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// GreenDEX Multisig Wallet Contract - Provides multisig wallet functionality for GreenDEX platform

contract GreenMultisigWallet {
    // State variables
    address[] public owners;
    uint256 public requiredSignatures;
    uint256 public transactionCount;

    struct Transaction {
        address destination;
        uint256 value;
        bool executed;
        uint256 signatureCount;
    }

    mapping(uint256 => Transaction) public transactions;
    mapping(uint256 => mapping(address => bool)) public confirmations;

    // Events
    event Deposit(address indexed sender, uint256 value);
    event Submission(uint256 indexed transactionId);
    event Confirmation(address indexed sender, uint256 indexed transactionId);
    event Execution(uint256 indexed transactionId);
    event ExecutionFailure(uint256 indexed transactionId);

    // Modifiers
    modifier onlyOwner() {
        require(isOwner(msg.sender), "Caller is not an owner.");
        _;
    }

    modifier transactionExists(uint256 transactionId) {
        require(transactions[transactionId].destination != address(0), "Transaction does not exist.");
        _;
    }

    modifier confirmed(uint256 transactionId, address owner) {
        require(confirmations[transactionId][owner], "Transaction not confirmed.");
        _;
    }

    modifier notConfirmed(uint256 transactionId, address owner) {
        require(!confirmations[transactionId][owner], "Transaction already confirmed.");
        _;
    }

    modifier notExecuted(uint256 transactionId) {
        require(!transactions[transactionId].executed, "Transaction already executed.");
        _;
    }

    // Constructor
    constructor(address[] memory _owners, uint256 _requiredSignatures) {
        require(_owners.length > 0, "Owners required.");
        require(_requiredSignatures > 0 && _requiredSignatures <= _owners.length, "Invalid number of required signatures.");

        for (uint256 i = 0; i < _owners.length; i++) {
            require(_owners[i] != address(0), "Invalid owner.");
            owners.push(_owners[i]);
        }

        requiredSignatures = _requiredSignatures;
    }

    // Deposit funds into the wallet
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    // Submit a transaction
    function submitTransaction(address destination, uint256 value) public onlyOwner {
        uint256 transactionId = addTransaction(destination, value);
        emit Submission(transactionId);
    }

    // Confirm a transaction
    function confirmTransaction(uint256 transactionId) public onlyOwner transactionExists(transactionId) notConfirmed(transactionId, msg.sender) {
        confirmations[transactionId][msg.sender] = true;
        transactions[transactionId].signatureCount += 1;

        emit Confirmation(msg.sender, transactionId);

        executeTransaction(transactionId);
    }

    // Execute a confirmed transaction
    function executeTransaction(uint256 transactionId) public onlyOwner transactionExists(transactionId) notExecuted(transactionId) {
        if (isConfirmed(transactionId)) {
            Transaction storage txn = transactions[transactionId];
            txn.executed = true;

            (bool success, ) = txn.destination.call{value: txn.value}("");
            if (success) {
                emit Execution(transactionId);
            } else {
                txn.executed = false;
                emit ExecutionFailure(transactionId);
            }
        }
    }

    // Add a new transaction to the list
    function addTransaction(address destination, uint256 value) internal returns (uint256) {
        uint256 transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination: destination,
            value: value,
            executed: false,
            signatureCount: 0
        });
        transactionCount += 1;
        return transactionId;
    }

    // Check if a transaction is confirmed
    function isConfirmed(uint256 transactionId) public view returns (bool) {
        return transactions[transactionId].signatureCount >= requiredSignatures;
    }

    // Check if an address is an owner
    function isOwner(address _owner) internal view returns (bool) {
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == _owner) {
                return true;
            }
        }
        return false;
    }
}
