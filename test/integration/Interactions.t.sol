// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {Raffle} from "src/Raffle.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";

contract RaffleTest is Test {
    // Declare variables for the contract and players
    Raffle public raffle;
    HelperConfig public helperConfig;
    address public player;
    address public otherPlayer;
    uint256 entranceFee;
    
    // Set up the environment (Arrange)
    function setUp() public {
        // Deploy the HelperConfig and get the configuration for Sepolia
        helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        entranceFee = config.entranceFee;

        // Deploy the Raffle contract
        raffle = new Raffle(
            config.entranceFee,
            config.interval,
            config.vrfCoordinator,
            config.gaslane,
            config.subscriptionId,
            config.callbackGasLimit
        );

        // Define player addresses
        player = address(0x123);
        otherPlayer = address(0x456);

        // Fund the players with enough ETH to enter the raffle
        vm.deal(player, 1 ether);  // Send 1 ether to player
        vm.deal(otherPlayer, 1 ether);  // Send 1 ether to other player
    }

    // Test case 1: Entering the raffle (Arrange, Act, Assert)
    function testEnterRaffle() public {
        // Arrange: Player is ready to enter the raffle with sufficient ETH
        vm.startPrank(player);
        
        // Act: Player enters the raffle
        raffle.enterRaffle{value: entranceFee}();

        // Assert: Verify the player is added to the raffle
        address playerInRaffle = raffle.getPlayer(0);
        assertEq(playerInRaffle, player, "Player should be in the raffle");

        vm.stopPrank();
    }

    // Test case 2: Performing Upkeep and Picking a Winner (Arrange, Act, Assert)
    function testPickWinner() public {
        // Arrange: Player enters the raffle
        vm.startPrank(player);
        raffle.enterRaffle{value: entranceFee}();
        vm.stopPrank();

        vm.startPrank(otherPlayer);
        raffle.enterRaffle{value: entranceFee}();
        vm.stopPrank();

        // Act: Simulate the passing of time for upkeep to be needed
        vm.warp(block.timestamp + 30 seconds);

        // Perform upkeep (simulating Chainlink Automation)
        raffle.performUpKeep("");

        // Assert: Verify the winner is selected
        address winner = raffle.getRecentWinner();
        assertTrue(winner != address(0), "Winner should be selected");

        // Assert: Verify the raffle state is now OPEN
        assertEq(uint256(raffle.getRaffleState()), uint256(Raffle.RaffleState.OPEN), "Raffle state should be OPEN after upkeep");
    }

    // Test case 3: Winner Payment (Arrange, Act, Assert)
    function testWinnerPayment() public {
        // Arrange: Both players enter the raffle
        vm.startPrank(player);
        raffle.enterRaffle{value: entranceFee}();
        vm.stopPrank();

        vm.startPrank(otherPlayer);
        raffle.enterRaffle{value: entranceFee}();
        vm.stopPrank();

        // Act: Simulate the passing of time for upkeep to be needed
        vm.warp(block.timestamp + 30 seconds);

        // Perform upkeep (simulating Chainlink Automation)
        raffle.performUpKeep("");

        // Get the winner before the payment
        address winner = raffle.getRecentWinner();
        uint256 winnerBalanceBefore = winner.balance;

        // Fulfill the random words callback (simulate Chainlink fulfilling the request)
        VRFCoordinatorV2_5Mock vrfCoordinatorMock = VRFCoordinatorV2_5Mock(address(raffle.getVRFCoordinator()));
        vrfCoordinatorMock.fulfillRandomWords(1, address(raffle)); 
        // Simulate Chainlink VRF fulfilling the request

        // Assert: Verify that the winner balance has increased (they should have received the entire balance of the contract)
        uint256 winnerBalanceAfter = winner.balance;
        assertGt(winnerBalanceAfter, winnerBalanceBefore, "Winner should have received the prize");

        // Assert: Verify that the contract balance is now zero
        assertEq(address(raffle).balance, 0, "Contract balance should be zero after payment");
    }
}
