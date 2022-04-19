// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

/**
 * @title Helper library for pseudo random number generation.
 * @author Dylan Clarke
 */
library Random {
    /**
     * @dev Uses information about the current block and sender to create
     * a seed which is used to return the random number.
     * @param upTo The max size of the random number.
     * @param sender The address of the original `msg.sender`. Used as part of the seed generation.
     * @return A pseudo-random number. 
     */
    function ranUint(uint upTo, address sender) public view returns(uint) {
        uint seed = uint(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
            block.gaslimit + 
            ((uint(keccak256(abi.encodePacked(sender)))) / (block.timestamp)) +
            block.number
        )));
        return (seed - ((seed / 1000) * 1000)) % upTo;
    }
}