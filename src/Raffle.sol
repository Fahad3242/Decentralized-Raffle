// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * @title  Raffle conract
 * @author Muhammad Fahad
 * @notice This contract is for creating a sample raffle
 * @dev Implements Chainlink VRFv2.5 for random number generation
 */
contract Raffle is VRFConsumerBaseV2Plus {
    //errors
    error Raffle__SendMoreToEnterRaffle();

    //state variables
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    uint256 private s_LastTimeStamp;
    address payable[] private s_players;

    //events
    event RaffleEntered(address indexed player, uint256 entranceFee);

    //constructor
    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint256 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_LastTimeStamp = block.timestamp;
        i_keyHash = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
    }

    //functions
    function enterRaffle() external payable {
        if (msg.value < i_entranceFee) {
            revert Raffle__SendMoreToEnterRaffle();
        }
        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender, i_entranceFee);
    }

    function pickWinner() external {
        if ((block.timestamp - s_LastTimeStamp) < i_interval) {
            revert();
        }

        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient.RandomWordsRequest({
            keyHash: i_keyHash,
            subId: i_subscriptionId,
            requestConfirmations: REQUEST_CONFIRMATIONS,
            callbackGasLimit: i_callbackGasLimit,
            numWords: NUM_WORDS,
            extraArgs: VRFV2PlusClient._argsToBytes(
                // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
            )
        });
        uint256 requestId = s_vrfCoordinator.requestRandomWords(request);
    }

    /**
     * @dev this is a callback function that is called by the chainlink VRF coordinator
     * It is called when the random number is generated
     * It is overriden because it is a virtual function in the VRFConsumerBaseV2Plus contract
     * It is and always will be undefined in the parent contract and must be defined in the child contract 
     * which means the random word will be given to Raffle.sol and then we will decide what to do with that random number
     * override = Can modify functions from the parent contract
     *
     *  
     */
    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        //implement this function
    }

    //getters
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
