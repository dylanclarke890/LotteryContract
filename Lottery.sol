// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

contract Lottery {
    address payable internal owner;
    mapping(uint => address) public currentEntries;
    uint16 public entriesCount; 
    uint16 internal maxEntries;
    uint internal startTime;
    uint public drawTime;
    uint64 public entryCost;
    uint16 public payoutInterval;

    modifier lotteryInProgress() {
        require(block.timestamp >= startTime && block.timestamp <= drawTime, "Lottery is not in progress.");
        _;
    }

    modifier lotteryHasEnded() {
        require(block.timestamp >= drawTime, "Lottery in progress.");
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner,  "Only the owner can do this.");
        _;
    }

    modifier hasEnoughEntries {
        require(entriesCount > 1, "Not enough entries yet.");
        _;
    }

    modifier entriesLeft {
        require(entriesCount < maxEntries, "No entries left.");
        _;
    }

    constructor() {
        owner = payable(msg.sender);
        entriesCount = 0;
        maxEntries = 1000;
        entryCost = 0.05 ether;
        payoutInterval = 60 seconds;
        startTime = block.timestamp;
        drawTime = block.timestamp + payoutInterval;
    }

    function buyEntryTicket()
        external
        payable
        entriesLeft
        lotteryInProgress
        returns(uint16) {
        require(msg.value >= entryCost, "Not enough ether for an entry.");
        entriesCount++;
        currentEntries[entriesCount] = address(msg.sender);
        return entriesCount;
    }

    function getTotalPot()
        public
        view
        hasEnoughEntries
        lotteryInProgress
        returns (uint) {
        uint cBalance = address(this).balance;
        return msg.sender == owner ? totalPlayerWinnings(cBalance, 30) : totalPlayerWinnings(cBalance, 70);
    }

    function drawWinner()
        public
        onlyOwner
        hasEnoughEntries
        lotteryHasEnded
        returns (address) {
        // Get a random number up to the count
        uint random = randomNumber(entriesCount - 1);
        require(random <= entriesCount - 1);

        // Calculate winnings and profit
        uint cBalance = address(this).balance;
        uint winnerTakings = totalPlayerWinnings(cBalance, 70);
        uint ownerTakings = cBalance - winnerTakings;
        require(winnerTakings > ownerTakings && ownerTakings > 0, "Error with winnings calculations.");

        // Transfer pot to owner and winner
        address winner = currentEntries[random];
        (bool oSuccess,) = payable(owner).call{value: ownerTakings}("");
        require(oSuccess, "Payment to owner was not successful.");
        (bool wSuccess,) = payable(winner).call{value: winnerTakings}("");
        require(wSuccess, "Payment to winning player was not successful.");

        // Reset entries and set new start/draw time.
        for (uint i = 0; i < entriesCount; i++) {
           delete currentEntries[i+1];
        }
        entriesCount = 0;
        startTime = block.timestamp;
        drawTime = startTime + payoutInterval;

        return winner;
    }

    function totalPlayerWinnings(uint contractBalance, uint takeHomePercentage)
        internal
        pure
        returns(uint) {
        return (contractBalance / 100) * takeHomePercentage;
    }

    function randomNumber(uint upTo)
        internal
        view
        returns(uint) {
        uint seed = uint(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
            block.gaslimit + 
            ((uint(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
            block.number
        )));
        return (seed - ((seed / 1000) * 1000)) % upTo;
    }
}