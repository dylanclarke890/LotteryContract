// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

contract Lottery {
    address payable internal owner;
    mapping(uint => address) public currentEntries;
    uint16 public entriesCount; 
    uint16 maxEntries;
    uint startTime;
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
        require(entriesCount > 5, "Not enough entries yet.");
        _;
    }

    constructor(address payable _owner) {
        owner = _owner;
        entriesCount = 0;
        maxEntries = 1000;
        entryCost = 0.05 ether;
        payoutInterval = 1 hours;
        startTime = block.timestamp;
        drawTime = block.timestamp + payoutInterval;
    }

    function buyEntryTicket()
    external payable lotteryInProgress returns(uint16) {
        require(entriesCount < maxEntries, "No entries left.");
        require(msg.value >= entryCost, "Not enough ether for an entry.");
        entriesCount++;
        currentEntries[entriesCount] = address(msg.sender);
        return entriesCount;
    }

    function getTotalPot() 
    public view hasEnoughEntries returns (uint) {
        uint cBalance = address(this).balance;
        return msg.sender == owner ? totalPlayerWinnings(cBalance, 30) : totalPlayerWinnings(cBalance, 70);
    }

    function drawWinner() 
    public hasEnoughEntries onlyOwner returns (address) {
        // Get a random number up to the count
        uint random = randomNumber(entriesCount - 1);
        require(random <= entriesCount - 1);
        // Calculate winnings and profit
        uint cBalance = address(this).balance;
        uint ownerTakings = totalPlayerWinnings(cBalance, 30);
        uint winnerTakings = totalPlayerWinnings(cBalance, 70);
        // Transfer pot to owner and winner
        address winner = currentEntries[random];
        (bool oSuccess,) = payable(owner).call{value: ownerTakings}("");
        require(oSuccess);
        (bool wSuccess,) = payable(winner).call{value: winnerTakings}("");
        require(wSuccess);
        return winner;
    }

    function totalPlayerWinnings(uint contractBalance, uint takeHomePercentage) 
    internal pure returns(uint) {
        return (contractBalance / 100) * takeHomePercentage;
    }

    function randomNumber(uint upTo)
    internal view returns(uint) {
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