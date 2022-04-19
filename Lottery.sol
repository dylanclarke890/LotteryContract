// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './contexts/Context.sol';
import './contexts/LotteryContext.sol';
import './validation/Interval.sol';
import './validation/Owned.sol';
import './libraries/Random.sol';
import './libraries/Maths.sol';

/**
 * @title A lottery contract using RNG.
 * @author Dylan Clarke
 * @notice A basic implementation only.
 * @dev At present, owner is fixed to whoever initially deploys the contract.
 */
contract Lottery is Context, LotteryContext, Interval, Owned {
    using Maths for uint;

    /**
    * @notice Purchases an entry to the lottery, as long as the lottery has started and there are still spaces available.
    * @dev If valid, maps the current entry count to the payer's address for future ref.
    * @return The current entry count.
    */
    function buyEntryTicket() external payable canBuyEntries(1) inProgress returns(uint16) {
        require(_msgValue() >= entryCost, "Not enough ether for an entry.");
        _incrementCount();
        currentEntries[entriesCount] = address(_msgSender());
        return entriesCount;
    }

    /**
    * @notice Get the current prize money total.
    * @dev If called by the owner, returns their potential share of the pot instead of the winner's.
    * @return The current potential earnings.
    */
    function getTotalPot() public view hasEnoughEntries notInProgress returns (uint) {
        uint cBalance = address(this).balance;
        return _msgSender() == owner ? cBalance.percent(30) : cBalance.percent(70);
    }

    /**
    * @notice Draws a random winner from the list of current entries. Both owner and winner are sent 
    * their respective earnings and the game is restarted if `startNewRound` is `true`.
    * @param startNewRound If `true`, will automatically start a new round.
    * @return The address of the winning entry.
    */
    function drawWinner(bool startNewRound) public onlyOwner hasEnoughEntries notInProgress returns (address) {
        // Calculate winnings and profit
        uint cBalance = address(this).balance;
        uint winnerTakings = cBalance.percent(70);
        uint ownerTakings = cBalance.sub(winnerTakings);
        require(winnerTakings > ownerTakings && ownerTakings > 0, "Error with calculating winnings.");

        // Get a random number up to the count
        uint count = entriesCount--;
        uint random = Random.ranUint(count, _msgSender());
        require(random < entriesCount, "Selected number out of range.");

        // Transfer pot to owner and winner
        address winner = currentEntries[random];
        require(_transfer(owner, ownerTakings), "Payment to owner was not successful.");
        require(_transfer(winner, winnerTakings), "Payment to winning player was not successful.");

        _clearEntries();
        if (startNewRound) _newTimer();
        return winner;
    }

    /**
    * @notice Refunds everyone who bought an entry the cost of an entry. Only to be used when there's not
    * enough entries for a round and the buying part of the round has finished. Restarts the game if
    * `startNewRound` is `true`.
    * @param startNewRound If `true`, will automatically start a new round.
    */
    function refundParticipants(bool startNewRound) public onlyOwner notEnoughEntries notInProgress {
        for (uint i = 0; i < entriesCount; i++) {
            require(_transfer(currentEntries[i+1], entryCost), "Error during refund.");
        }
        _clearEntries();
        if (startNewRound) _newTimer();
    }

    /**
    * @notice Transfers an amount to an address. For internal use only.
    * @dev The amount is sent from the contract balance. Value needs to be greater than zero.
    * @param recipient The address of the payee.
    * @param value The amount to send.
    * @return A bool indicating if the transfer was successful.
    */ 
    function _transfer(address recipient, uint value) internal returns(bool) {
        require(value > 0, "Invalid transfer value.");
        require(address(this).balance > 0, "Insufficient funds.");
        (bool success,) = payable(recipient).call{value: value}("");
        return success;
    }
}