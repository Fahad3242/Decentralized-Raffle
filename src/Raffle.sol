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
    uint256 private immutable i_interval;
    uint256 private immutable s_LastTimeStamp;
    address payable [] private s_players;

    //events
    event RaffleEntered(address indexed player, uint256 entranceFee);

    //constructor
    constructor(uint256 entranceFee, uint256 interval) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_LastTimeStamp = block.timestamp;
    }

    //functions
    function enterRaffle() external payable {
        if(msg.value < i_entranceFee) {
            revert Raffle__SendMoreToEnterRaffle();
        }
        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender, i_entranceFee);
    }

    function pickWinner() external {
        if( (block.timestamp - s_LastTimeStamp) < i_interval ){
            revert();
        }

    }

    //getters
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
