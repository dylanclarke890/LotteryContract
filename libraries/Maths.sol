// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

library Maths {
    function add(uint a, uint b) public pure returns(uint) {
        return a + b;
    }

    function sub(uint a, uint b) public pure returns(uint) {
        if (b > a) return 0;
        return a - b;
    }

    function div(uint a, uint b) public pure returns(uint) {
        if (a == 0 || b == 0) return 0;
        return a / b;
    }

    function mul(uint a, uint b) public pure returns(uint) {
        if (a == 0 || b == 0) return 0;
        return a * b;
    }

    function mod(uint a, uint b) public pure returns(uint) {
        if (a == 0 || b == 0) return 0;
        return a % b;
    }

    function percent(uint num, uint percentage) public pure returns(uint) {
        if (num == 0 || percentage == 0) return 0;
        return (num / 100) * percentage;
    }
}