// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import 'Context.sol';

abstract contract Owned is Context {
    address public owner;

    constructor() {
        owner = _msgSender();
    }

    modifier onlyOwner {
        require(_msgSender() == owner,  "Only the owner can do this.");
        _;
    }
}