// "SPDX-License-Identifier: UNLICENSED"
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
