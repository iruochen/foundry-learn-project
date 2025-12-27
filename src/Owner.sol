// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Owner {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    event ChangeOwner(address indexed caller, address indexed newOwner);

    error NotOwner(address caller);

    function changeOwner(address newOwner) public onlyOwner {
        owner = newOwner;
        emit ChangeOwner(msg.sender, newOwner);
    }

    function changeOwner2(address newOwner) public {
        if (msg.sender != owner) revert NotOwner(msg.sender);
        owner = newOwner;
        emit ChangeOwner(msg.sender, newOwner);
    }
}
