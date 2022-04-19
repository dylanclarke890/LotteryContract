// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import '../libraries/Maths.sol';

/**
 * @dev Contract module which provides a basic interval mechanism where certain actions cannot be performed
 * after/outside the interval, and provided functionality to refresh the interval.
 *
 * This module is used through inheritance. It will make available the modifiers
 * `inProgress` and `notInProgress`, which can be applied to your functions to restrict their use to
 * during the interval/after the interval has elapsed.
 * @author Dylan Clarke
 */
abstract contract Interval {
    uint16 public interval;
    uint internal startTime;
    uint public endTime;

    constructor() {
        interval = 60 seconds;
        _newTimer();
    }

    /// @dev Restricts use to within the interval duration.
    modifier inProgress() {
        uint time = block.timestamp;
        require(time >= startTime && time <= endTime, "Not in progress.");
        _;

    }

    /// @dev Restricts use to before/after the interval duration.
    modifier notInProgress() {
        uint time = block.timestamp;
        require(time >= endTime || time < startTime, "In progress.");
        _;
    }

    /// @dev Starts a new timer based on the current time and `interval`. 
    function _newTimer() internal {
        startTime = block.timestamp;
        endTime = Maths.add(startTime, interval);
    }
}