// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title  Raffle conract
 * @author Muhammad Fahad
 * @notice This contract is for creating a sample raffle
 * @dev Implements Chainlink VRFv2.5 for random number generation
 */

contract Raffle {
    
    //errors
    error Raffle__SendMoreToEnterRaffle();

    //state variables
    uint256 private immutable i_entranceFee;
    address payable [] private s_players;

    //events
    event RaffleEntered(address indexed player, uint256 entranceFee);

    //constructor
    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    //functions
    function enterRaffle() public payable {
        if(msg.value < i_entranceFee) {
            revert Raffle__SendMoreToEnterRaffle();
        }
        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender, i_entranceFee);
    }

    function pickWinner() public {}

    //getters
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
