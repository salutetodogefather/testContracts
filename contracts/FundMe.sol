// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interfsolidiace.sol";

// Copied from the @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interfsolidiace.sol
interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

contract FundMe {
    mapping(address => uint256) public addressToAmountFunded;
    AggregatorV3Interface internal BNBUSDPriceFeed;

    uint256 balance;

    //Funders address array
    address[] funders;

    // BSC Testnet BNB/USD Contract Address
    // https://docs.chain.link/docs/binance-smart-chain-addresses/
    address BNBUSDPriceFeedAddress = 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526;

    int256 constant PRICEMULTIPLIER = 100000000;
    uint256 constant PRICECONVERTERDIVISOR = 100000000;

    //Address contractOwner
    address contractOwner;

    constructor() {
        // Defining the BNBUSDPriceFeedAddress
        BNBUSDPriceFeed = AggregatorV3Interface(BNBUSDPriceFeedAddress);
        contractOwner = msg.sender;
    }

    // Payable makes the function accept payment
    function fund() public payable {
        // Setting Minimun USD value to $50;
        uint256 minimumUSD = 50 * 10**8;

        require(
            getConversionRate(msg.value) >= minimumUSD,
            "BNB Funded less than 50 USD"
        );
        // msg is a object keyword
        addressToAmountFunded[msg.sender] += msg.value;
        balance += msg.value;
        funders.push(msg.sender);
    }

    function withdrawalForOwner() public payable {
        require(msg.sender == contractOwner);
        payable(msg.sender).transfer(address(this).balance);
    }

    // use Chainlink Oracle to check the conversion of BNB/USD
    function getPrice() public view returns (uint256) {
        // These parameters are from the latestRoundData function definition in the AggregatorV3Interface.sol; (TUPLE is cleaned with unused variables)
        (, int256 answer, , , ) = BNBUSDPriceFeed.latestRoundData();
        return uint256(answer * PRICEMULTIPLIER);
    }

    function getConversionRate(uint256 BNBAmount)
        public
        view
        returns (uint256)
    {
        uint256 BNBPrice = getPrice();
        return uint256(BNBPrice * BNBAmount) / PRICECONVERTERDIVISOR;
    }
}
