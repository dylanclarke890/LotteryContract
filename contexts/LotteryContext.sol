// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

/**
 * @dev Provides the core functionality for a Lottery contract, specifically regarding the entries amount.
 * Provides access to various entry modifiers for use in restricting functions unless requirements for various
 * amounts are met, as well as functionality to clear the entries and increase the count that keeps track of the 
 * amount of entries.
 * @author Dylan Clarke
 */
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

    /// @dev Reverts if `entriesCount` is not greater than `minEntries`
    modifier hasEnoughEntries {
        require(entriesCount >= minEntries, "Not enough entries.");
        _;
    }

    /// @dev Reverts if `entriesCount` is less than `minEntries`
    modifier notEnoughEntries {
        require(entriesCount > minEntries, "There is enough entries.");
        _;
    }

    /// @dev Reverts if the new total of entries would exceed `maxEntries`.
    /// @param amount The amount of entries the sender is trying to buy. 
    modifier canBuyEntries(uint amount) {
        require(entriesCount + amount <= maxEntries, "No entries left.");
        _;
    }

    /// @dev Increase the current entry count.
    function _incrementCount() internal {
        entriesCount++;
    }

    /// @dev Clears the current entries and sets the entry count to zero.
    function _clearEntries() internal {
        for (uint i = 0; i < entriesCount; i++) {
           delete currentEntries[i+1];
        }
        entriesCount = 0;
    }
}