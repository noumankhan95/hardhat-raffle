//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/automation/interfaces/AutomationCompatibleInterface.sol";
import "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";

error Raffle_NotEnoughFee();
error Raffle_FailedToTransferToWinner();
error Raffle_ContractNotOpen();
error Raffle_UpkeepNotNeeded(
    uint256 balance,
    uint256 players,
    uint256 raffleState
);
contract Raffle is VRFConsumerBaseV2, AutomationCompatibleInterface {
    enum RaffleState {
        OPEN,
        CALCULATING
    }

    uint256 private immutable i_entrancefee;
    address payable[] private s_players;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subId;
    uint16 private constant reqConfirmations = 3;
    uint32 private constant numWords = 1;
    uint32 private immutable i_cbgaslimit;
    uint256 private s_lastTimestamp;
    uint256 private s_interval;

    address private s_recentWinner;
    RaffleState private s_raffleState;
    event raffleEntered(address indexed player);
    event RequestedRaffleWinner(uint256 indexed requestId);
    event WinnerPicked(address indexed winner);
    constructor(
        address vrfCordinatorV2,
        uint256 _fee,
        bytes32 gaslane,
        uint64 subId,
        uint32 cbgaslimit,
        uint256 interval
    ) VRFConsumerBaseV2(vrfCordinatorV2) {
        i_entrancefee = _fee;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCordinatorV2);
        i_gasLane = gaslane;
        i_subId = subId;
        i_cbgaslimit = cbgaslimit;
        s_raffleState = RaffleState.OPEN;
        s_lastTimestamp = block.timestamp;
        s_interval = interval;
    }
    function enterRaffle() internal {
        if (msg.value < i_entrancefee) {
            revert Raffle_NotEnoughFee();
        }
        if (RaffleState.OPEN != s_raffleState) {
            revert Raffle_ContractNotOpen();
        }
        s_players.push(payable(msg.sender));
        emit raffleEntered(msg.sender);
    }
    function checkUpkeep(
        bytes memory checkData
    ) public view returns (bool upkeepNeeded, bytes memory performData) {
        bool isOpen = RaffleState.OPEN == s_raffleState;
        bool timepassed = ((block.timestamp - s_lastTimestamp > s_interval));
        bool hasPlayers = s_players.length > 0;
        bool hasBalance = address(this).balance > 0;

        upkeepNeeded = isOpen && timepassed && hasBalance && hasPlayers;
    }

    function performUpkeep(bytes calldata performData) external {
        (bool upkeepNeeded, ) = checkUpkeep("");
        if (!upkeepNeeded)
            revert Raffle_UpkeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_raffleState)
            );
        s_raffleState = RaffleState.CALCULATING;
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subId,
            reqConfirmations,
            i_cbgaslimit,
            numWords
        );
        emit RequestedRaffleWinner(requestId);
    }

    function fulfillRandomWords(
        uint256,
        uint256[] memory randomWords
    ) internal override {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        s_players = new address payable[](0);
        s_lastTimestamp = block.timestamp;
        (bool success, ) = s_recentWinner.call{value: address(this).balance}(
            ""
        );
        s_raffleState = RaffleState.OPEN;
        if (!success) {
            revert Raffle_FailedToTransferToWinner();
        }
        emit WinnerPicked(s_recentWinner);
    }

    function getEntranceFee() public view returns (uint256) {
        return i_entrancefee;
    }
    function getPlayer(uint256 _player) public view returns (address) {
        return s_players[_player];
    }
    function getRecentWinner() public view returns (address) {
        return s_recentWinner;
    }
    function getRaffleState() public view returns (RaffleState) {
        return s_raffleState;
    }
}
