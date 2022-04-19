// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

abstract contract LotteryContext {
    mapping(uint => address) public currentEntries;
    uint16 public entriesCount;
    uint8 internal minEntries; 
    uint16 internal maxEntries;
    uint64 public entryCost;

    constructor() {
        entriesCount = 0;
        minEntries = 2;
        maxEntries = 1000;
        entryCost = 0.05 ether;
    }

    modifier hasEnoughEntries {
        require(entriesCount >= minEntries, "Not enough entries yet.");
        _;
    }

    modifier notEnoughEntries {
        require(entriesCount > minEntries, "There is enough entries.");
        _;
    }

    modifier canBuyEntries(uint amount) {
        require(entriesCount + amount < maxEntries, "No entries left.");
        _;
    }

    function _incrementCount() internal {
        entriesCount++;
    }

    function _clearEntries() internal {
        for (uint i = 0; i < entriesCount; i++) {
           delete currentEntries[i+1];
        }
        entriesCount = 0;
    }
}