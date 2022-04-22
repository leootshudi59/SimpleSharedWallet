// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract SimpleWallet {

    address owner;

    constructor() {
        owner = msg.sender;
    }  

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not owner");
        _;
    }

    function withdrawMoney(address payable _to, uint _amount) public onlyOwner {
        _to.transfer(_amount);
    }
    
    fallback () external payable {

    }
}