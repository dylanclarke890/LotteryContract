// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

library Random {
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