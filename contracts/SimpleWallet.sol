// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract Allowance is Ownable {

    using SafeMath for uint;
    event AllowanceChanged(address indexed _forWho, address indexed fromWhom, uint oldAmount, uint newAmount);

    mapping (address => uint) public allowance;

    function isOwner() public view returns(bool) {
        return owner() == msg.sender;
    }
    // Gives to a wallet address the allowance to withdraw a certain amout
    function setAllowance(address _who, uint _amountAllowed) public onlyOwner {
        emit AllowanceChanged(_who, msg.sender, allowance[_who], _amountAllowed);

        allowance[_who] = _amountAllowed;
    }
    
    function reduceAllowance(address _who, uint _amountToReduce) internal {
        emit AllowanceChanged(_who, msg.sender, allowance[_who], allowance[_who].sub(_amountToReduce));
        allowance[_who] = allowance[_who].sub(_amountToReduce);
    }

    modifier ownerOrAllowed(uint _amount) {
        require(owner() == msg.sender || allowance[msg.sender] >= _amount, "You are not allowed");
        _;
    }
}


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