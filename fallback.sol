// You will beat this level if
//	 you claim ownership of the contract
//	 you reduce its balance to 0

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Explanation:
// 	As the name indicates, fallback function is used to serve as a 'fallback' solution for receiving ether when
// 	the sender do not know your ABI. Typically, it is called when a non-existent function is called on the contract.
//  	It has no argument, nor name. Most importantly, it requires "payable" marker. Because of fallback function's public nature, 
//  	it opens up a backdoor for outside world. When the fallback function involves logic of changin the ownership, it could be
// 	a recipe for disaster. This is exactly what's going on here.  

// Solution:
//	To change the ownership of the contract, we should take a look at the fallback function itself: 	 	
// 		require(msg.value > 0 && contributions[msg.sender] > 0);
// 	this line here requires two conditions: 
// 		1) the function call needs to has some value;
// 		2) the sender address needs to be stored in the contributions map already when the call initiates.
//  	To achieve this, we can call the contribute() function in the console with an arbitrary value larger than 0.001 ether,
// 	then we can transfer and arbitrary amount again to claim the ownership. To reduce its balance to zero, we can simply use
// 	contract.withdraw()
// Code:
// 	await contract.contribute({value:123})
// 	await contract.sendTransaction({from: player, value: toWei("0.1")})
// 	await contract.withdraw()


// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import '@openzeppelin/contracts/math/SafeMath.sol';

contract Fallback {

  using SafeMath for uint256;
  mapping(address => uint) public contributions;
  address payable public owner;

  constructor() public {
    owner = msg.sender;
    contributions[msg.sender] = 1000 * (1 ether);
  }

  modifier onlyOwner {
        require(
            msg.sender == owner,
            "caller is not the owner"
        );
        _;
    }

  function contribute() public payable {
    require(msg.value < 0.001 ether);
    contributions[msg.sender] += msg.value;
    if(contributions[msg.sender] > contributions[owner]) {
      owner = msg.sender;
    }
  }

  function getContribution() public view returns (uint) {
    return contributions[msg.sender];
  }

  function withdraw() public onlyOwner {
    owner.transfer(address(this).balance);
  }

  fallback() external payable {
    require(msg.value > 0 && contributions[msg.sender] > 0);
    owner = msg.sender;
  }
}
