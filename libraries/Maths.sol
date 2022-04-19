// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

/**
 * @title Core Maths Functions.
 * @author Dylan Clarke
 * @dev Includes basic functions for adding, subtracting, dividing, multiplying, modulo and percentage.
 * @notice Includes basic functions for adding, subtracting, dividing, multiplying, modulo and percentage.
 */ 
library Maths {

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, returning `0` on 
     * overflow (when `b` is greater than `a`.
     *
     * Safe counterpart to Solidity's `-` operator for unsigned integers.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b > a) return 0;
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Safe counterpart to Solidity's `/` operator for unsigned integers.
     */
    function div(uint a, uint b) internal pure returns(uint) {
        if (a == 0 || b == 0) return 0;
        return a / b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint a, uint b) internal pure returns(uint) {
        if (a == 0 || b == 0) return 0;
        return a * b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * returning zero if either param is zero.
     *
     * Safe counterpart to Solidity's `%` operator.
     */
    function mod(uint a, uint b) internal pure returns(uint) {
        if (a == 0 || b == 0) return 0;
        return a % b;
    }

    /**
     * @dev Returns the percentage of an unsigned integer, returning zero if either param is zero.
     */
    function percent(uint num, uint percentage) internal pure returns(uint) {
        if (num == 0 || percentage == 0) return 0;
        return (num / 100) * percentage;
    }
}