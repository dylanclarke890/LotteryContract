// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import '../contexts/Context.sol';

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 * @author Dylan Clarke
 */
abstract contract Owned is Context {
    address public owner;

    constructor() {
        owner = _msgSender();
    }

    /// @dev Restrict use to only the owner.
    modifier onlyOwner {
        require(_msgSender() == owner,  "Only the owner can do this.");
        _;
    }
}