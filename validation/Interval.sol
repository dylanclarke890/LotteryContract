// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import '../libraries/Maths.sol';

abstract contract Interval {
    uint16 public payoutInterval;
    uint internal startTime;
    uint public drawTime;

    constructor() {
        payoutInterval = 60 seconds;
        _newDrawTime();
    }

    modifier inProgress() {
        uint time = block.timestamp;
        require(time >= startTime && time <= drawTime, "Not in progress.");
        _;
    }

    modifier notInProgress() {
        uint time = block.timestamp;
        require(time >= drawTime || time < startTime, "In progress.");
        _;
    }

    function _newDrawTime() internal {
        startTime = block.timestamp;
        drawTime = Maths.add(startTime, payoutInterval);
    }
}