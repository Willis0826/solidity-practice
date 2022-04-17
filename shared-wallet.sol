// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract SharedWallet {
    address private _owner;

    // users list, true is enalbe, false is disalbe
    mapping(address => bool) private _users;

    // sender must be the owner
    modifier isOwner() {
        require(msg.sender == _owner);
        _;
    }

    // sender must be the owner or a valid user
    modifier isValid() {
        require(msg.sender == _owner || _users[msg.sender]);
        _;
    }

    // event
    event DepositFunds(address from, uint amount);
    event WithdrawFunds(address from, uint amount);
    event TransferFunds(address from, address to, uint amount);

    constructor() {
        // the creator is the owner of the shared wallet
        _owner = msg.sender;
    }

    function addUser(address user) isOwner public {
        _users[user] = true;
    }

    function removeUser(address user) isOwner public {
        _users[user] = false;
    }

    // anyone can deposit to this wallet
    receive () external payable {
        emit DepositFunds(msg.sender, msg.value);
    }

    // deposit
    function deposit () public payable {
        require(msg.value > 0);
        emit DepositFunds(msg.sender, msg.value);
    }

    // withdraw
    function withdraw (uint amount) isValid public {
        require(address(this).balance >= amount);
        payable(msg.sender).transfer(amount);
        emit WithdrawFunds(msg.sender, amount);
    }

    // transfer
    function transfer (uint amount, address payable to) isValid public {
        require(address(this).balance >= amount);
        payable(to).transfer(amount);
        emit TransferFunds(msg.sender, to, amount);
    }

    // check wallet balance
    function balance() public view returns (uint256) {
        return address(this).balance;
    }
}
