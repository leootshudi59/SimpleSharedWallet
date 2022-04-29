// "SPDX-License-Identifier: UNLICENSED"
pragma solidity >=0.7.0 <0.9.0;

import "./Allowance.sol";

contract SimpleWallet is Allowance {

    event MoneySent(address indexed _beneficiary, uint _amount);
    event MoneyReceived(address indexed _sender, uint _amount);

    function renounceOwnership() public override virtual onlyOwner {
        revert("Cannot renounce ownership");
    }

    // To withdraw money you have to be the contract owner or to be allowed
    // If you are contract owner, you can withdraw money unlimitedly
    function withdrawMoney(address payable _to, uint _amount) public ownerOrAllowed(_amount) {
        require(_amount <= address(this).balance, "There are not enough funds in the smart contract");
        if(!isOwner()) {
            reduceAllowance(msg.sender, _amount);
        }
        emit MoneySent(_to, _amount);
        _to.transfer(_amount);
    }
    
    fallback () external payable {
        emit MoneyReceived(msg.sender, msg.value);
    }
}