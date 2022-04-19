// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import 'Maths.sol';

abstract contract LotteryTimeLimit {
    uint16 public payoutInterval;
    uint internal startTime;
    uint public drawTime;

    constructor() {
        payoutInterval = 60 seconds;
        _newDrawTime();
    }

    modifier lotteryInProgress() {
        require(block.timestamp >= startTime && block.timestamp <= drawTime, "Lottery is not in progress.");
        _;
    }

    modifier lotteryHasEnded() {
        require(block.timestamp >= drawTime, "Lottery in progress.");
        _;
    }

    function _newDrawTime() internal {
        startTime = block.timestamp;
        drawTime = Maths.add(startTime, payoutInterval);
    }
}