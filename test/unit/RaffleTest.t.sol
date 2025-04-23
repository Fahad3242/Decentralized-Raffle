// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {DeployRaffle} from "script/DeployRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";
import {VRFCoordinatorV2_5Mock} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract RaffleTest is Test {
    Raffle public raffle;
    HelperConfig public helperConfig;

    uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gaslane;
        uint256 subscriptionId;
        uint32 callbackGasLimit;

    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_PLAYER_BALANCE = 10 ether;

    event RaffleEntered(address indexed player, uint256 entranceFee);
    event WinnerPicked(address indexed winner);

    

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.deployContract();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        entranceFee = config.entranceFee;
        interval = config.interval;
        vrfCoordinator = config.vrfCoordinator;
        gaslane = config.gaslane;
        subscriptionId = config.subscriptionId;
        callbackGasLimit = config.callbackGasLimit;
        vm.deal(PLAYER, STARTING_PLAYER_BALANCE);
    }

    function testRaffleInitializesInOpenState() public view {
        assertEq(raffle.getRaffleState() == Raffle.RaffleState.OPEN, true);
    }

    function testRaffleRevertsWhenYouDontPayEnough() public {
        // Arrange
        vm.prank(PLAYER);
        // Act / Assert
        vm.expectRevert(Raffle.Raffle__SendMoreToEnterRaffle.selector);
        raffle.enterRaffle();
    }
    
    function testRaffleRecordsPlayersWhenTheyEnter() public {
        // Arrange
        vm.prank(PLAYER);
        // Act 
        raffle.enterRaffle{value: entranceFee}();
        // Assert
        address playerRecorded = raffle.getPlayer(0);
        assert(playerRecorded == PLAYER);
    }

    function testEnteringRaffleEmitsEvent() public {
        // Arrange
        vm.prank(PLAYER);
        // Act
        vm.expectEmit(true, false, false, false, address(raffle));
        emit RaffleEntered(PLAYER, entranceFee);
        // Assert
        raffle.enterRaffle{value: entranceFee}();
    }

    function testDontAllowPlayersToEnterWhileRaffleIsCalculating() public {
        // Arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.performUpKeep("");
        
        // Act / Assert
        vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector);
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();

    }

    function testCheckUpKeepReturnsFalseIfItHasNoBalance() public {
        // Arrange
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        // Act
        (bool upKeepNeeded, ) = raffle.checkUpKeep("");
        // Assert
        assert(!upKeepNeeded);
    }

    function testCheckUpKeepReturnsFalseIfRaffleIsNotOpen() public {
        // Arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.performUpKeep("");
        // Act
        (bool upKeepNeeded, ) = raffle.checkUpKeep("");
        // Assert
        assert(!upKeepNeeded);
    }

    function testPerformUpKeepWorksWhenConditionsAreMet() public {
    // Arrange
    vm.prank(PLAYER);
    raffle.enterRaffle{value: entranceFee}(); // Player enters the raffle

    // Fast forward time to pass the interval check
    vm.warp(block.timestamp + interval + 1);
    vm.roll(block.number + 1);

    // Act
    raffle.performUpKeep("");

    // Assert
    assertEq(uint256(raffle.getRaffleState()), uint256(Raffle.RaffleState.CALCULATING));
}

// function testPerformUpKeepRevertsIfTimeHasNotPassed() public {
//     // Arrange
//     vm.prank(PLAYER);
//     raffle.enterRaffle{value: entranceFee}(); 

//     // Act / Assert
//     vm.expectRevert(Raffle.Raffle__UpkeepNotNeeded.selector);
//     raffle.performUpKeep("");
// }

//testCheckUpKeepReturnFalseIfEnoughTimeHasPassed
//testCheckUpKeepReturnsTrueIfParametersAreGood

function testPerformUpKeepCanOnlyRunIFCheckupkeepIsTrue() public {
    // Arrange
    vm.prank(PLAYER);
    raffle.enterRaffle{value: entranceFee}(); // Player enters the raffle

    // Fast forward time to pass the interval check
    vm.warp(block.timestamp + interval + 1);
    vm.roll(block.number + 1);

    // Act / Assert
    raffle.performUpKeep("");

}

function testPerformupkeepRevertsIFCheckupkeepIsFalse()  public {
    // Arrange
    uint256 currentBalance = 0;
    uint256 numPlayers = 0;
    Raffle.RaffleState rState = raffle.getRaffleState();

    vm.prank(PLAYER);
    raffle.enterRaffle{value: entranceFee}();
    currentBalance = currentBalance + entranceFee;
    numPlayers = 1; 

    // Act / Assert
    vm.expectRevert(
        abi.encodeWithSelector(Raffle.Raffle__UpkeepNotNeeded.selector, currentBalance, numPlayers, rState)
    );
    raffle.performUpKeep("");
    
}

modifier RaffleEnteredModifier() {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        _;
    }

function testPerformUpKeepUdatesRaffleStateAndEmitsRequestId() public  RaffleEnteredModifier {
    // Act
    vm.recordLogs();
    raffle.performUpKeep("");
    Vm.Log[] memory entries = vm.getRecordedLogs();
    bytes32 requestId = entries[1].topics[1];

    // Assert
    Raffle.RaffleState raffleState = raffle.getRaffleState();
    assert(uint256(requestId) > 0);
    assert(uint256(raffleState) == 1);
 

    }

    function testFulfillRandomWordsCanOnlyBeCalledAfterPerformUpKeep(uint256 randomRequestId) public RaffleEnteredModifier {
     // Arrange / Act / Assert
    vm.expectRevert(VRFCoordinatorV2_5Mock.InvalidRequest.selector);    
    VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(randomRequestId, address(raffle));
    }

    function testFulfillrandomWordsPicksAwinnerResetANDSendMoney() public RaffleEnteredModifier {
    // Arrange
    
    }
}