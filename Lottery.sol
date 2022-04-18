// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

contract Lottery {
    address payable internal owner;
    mapping(address => uint16) public entries;
    bool paused;
    uint16 public entriesLeft; 
    uint public startTime;
    uint public drawTime;
    uint64 public entryCost;
    uint16 public payoutInterval;

    modifier lotteryInProgress() {
        require(block.timestamp >= startTime && block.timestamp <= drawTime);
        _;
    }

    constructor(address payable _owner) {
        owner = _owner;
        paused = false;

        entriesLeft = 500;
        entryCost = 0.05 ether;
        payoutInterval = 1 hours;
        startTime = block.timestamp;
        drawTime = block.timestamp + payoutInterval;
    }

    function buyEntryTicket()
     external 
     payable 
     lotteryInProgress 
     returns(uint16) {
         require(entriesLeft > 0, "No entries left for this draw.");
        require(msg.value >= entryCost, "Not enough ether sent.");

        entries[address(msg.sender)]++;
        entriesLeft--;
        return entriesLeft;
    }

    function getTotalPot() public view returns (uint) {
        return address(this).balance;
    }

    function getEntriesLeft() public view returns (uint16) {
        return entriesLeft;
    }
}