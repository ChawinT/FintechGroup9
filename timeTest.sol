// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.7;
    
contract Timestamp {
   uint public timestamp;
   function saveTimestamp() public {
      timestamp = block.timestamp;
   }
   
   uint public duration;
   uint public newdeadline;
   function dateChange(uint _days) public {
      duration = _days * 1 days;
      newdeadline = block.timestamp + duration;
   }
   
   uint public duration2;
   uint public newdeadline2;
   function dateChangeTest(uint _minutes) public {
      duration2 = _minutes * 1 minutes;
      newdeadline2 = block.timestamp + duration2;
   }

}