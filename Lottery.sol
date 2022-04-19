// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import './Context.sol';
import './LotteryContext.sol';
import './LotteryTimeLimit.sol';
import './Owned.sol';
import './Random.sol';
import './Maths.sol';

contract Lottery is Context, LotteryContext, LotteryTimeLimit, Owned {
    using Maths for uint;

    function buyEntryTicket() external payable canBuyEntries(1) lotteryInProgress returns(uint16) {
        require(_msgValue() >= entryCost, "Not enough ether for an entry.");
        _incrementCount();
        currentEntries[entriesCount] = address(_msgSender());
        return entriesCount;
    }

    function getTotalPot() public view lotteryInProgress hasEnoughEntries returns (uint) {
        uint cBalance = address(this).balance;
        return _msgSender() == owner ? cBalance.percent(30) : cBalance.percent(70);
    }

    function drawWinner(bool startNewRound) public onlyOwner lotteryHasEnded hasEnoughEntries returns (address) {
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
        if (startNewRound) _newDrawTime();
        return winner;
    }

    function refundParticipants(bool startNewRound) public onlyOwner lotteryHasEnded notEnoughEntries {
        for (uint i = 0; i < entriesCount; i++) {
            require(_transfer(currentEntries[i+1], entryCost), "Error during refund.");
        }
        _clearEntries();
        if (startNewRound) _newDrawTime();
    }

    function _transfer(address recipient, uint value) internal returns(bool) {
        require(value > 0, "Invalid transfer value.");
        (bool success,) = payable(recipient).call{value: value}("");
        return success;
    }
}