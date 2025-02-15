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
    error Raffle__TransferFailed();
    error Raffle__RaffleNotOpen();
    error Raffle__UpkeepNotNeeded(uint256 balance, uint256 playersLength, uint256 rafflestate);

    //type declarations
    enum RaffleState {
        OPEN,
        CALCULATING
    }

    //state variables
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    address private s_recentWinner;
    uint256 private s_LastTimeStamp;
    address payable[] private s_players;
    RaffleState private s_raffleState;

    //events
    event RaffleEntered(address indexed player, uint256 entranceFee);
    event WinnerPicked(address indexed winner);

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
        i_keyHash = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;

        s_LastTimeStamp = block.timestamp;
        s_raffleState = RaffleState.OPEN;
    }

    //functions
    function enterRaffle() external payable {
        if (msg.value < i_entranceFee) {
            revert Raffle__SendMoreToEnterRaffle();
        }
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__RaffleNotOpen();
        }

        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender, i_entranceFee);
    }

    /**
     * @dev This function is called by Chainlink Automation (Keepers) to check
     * if the raffle should run. It returns `true` when all conditions are met:
     * 1. Enough time has passed since the last raffle.
     * 2. The raffle is still open.
     * 3. The contract has ETH.
     * 4. The subscription has enough LINK.
     * @param - Not used
     * @return upKeepNeeded - True if the raffle should start again
     * @return - Not used
     */
    function checkUpKeep(bytes memory) public view returns (bool upKeepNeeded, bytes memory) {
        bool timeHasPassed = ((block.timestamp - s_LastTimeStamp) >= i_interval);
        bool isOpen = s_raffleState == RaffleState.OPEN;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_players.length > 0;
        upKeepNeeded = timeHasPassed && isOpen && hasBalance && hasPlayers;
        return (upKeepNeeded, " ");
    }

    function performUpKeep(bytes calldata) external {
        (bool upKeepNeeded,) = checkUpKeep("");
        if (!upKeepNeeded) {
            revert Raffle__UpkeepNotNeeded(address(this).balance, s_players.length, uint256(s_raffleState));
        }

        s_raffleState = RaffleState.CALCULATING;
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
     *inherited from VRFConsumerBaseV2Plus contract
     *
     */
    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        //checks
        //effects (internal cotnract state)

        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;

        s_raffleState = RaffleState.OPEN;
        s_players = new address payable[](0);
        s_LastTimeStamp = block.timestamp;
        emit WinnerPicked(s_recentWinner);

        //interactions (external contract interactions)
        (bool success,) = recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransferFailed();
        }
    }

    //getters
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
