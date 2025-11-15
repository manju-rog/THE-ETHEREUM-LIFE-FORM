// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./DigitalOrganism.sol";
import "./OrganismFactory.sol";

/**
 * @title Ecosystem
 * @notice Manages competitions, tournaments, and ecosystem dynamics
 * @dev Implements natural selection through competitive interactions
 */
contract Ecosystem is Ownable, ReentrancyGuard {
    OrganismFactory public factory;

    // Tournament structure
    struct Tournament {
        uint256 id;
        address[] participants;
        address winner;
        uint256 prizePool;
        uint256 startBlock;
        uint256 endBlock;
        bool completed;
        mapping(address => uint256) scores;
    }

    // State variables
    uint256 public tournamentCount;
    mapping(uint256 => Tournament) public tournaments;
    mapping(address => uint256) public wins;
    mapping(address => uint256) public losses;

    // Competition settings
    uint256 public constant MIN_TOURNAMENT_PARTICIPANTS = 2;
    uint256 public constant TOURNAMENT_DURATION = 100; // blocks
    uint256 public competitionFee = 0.01 ether;

    // Events
    event TournamentCreated(
        uint256 indexed tournamentId,
        uint256 prizePool,
        uint256 startBlock
    );
    event TournamentCompleted(
        uint256 indexed tournamentId,
        address indexed winner,
        uint256 prize
    );
    event CompetitionResult(
        address indexed organism1,
        address indexed organism2,
        address winner,
        uint256 tournamentId
    );
    event OrganismRegistered(
        uint256 indexed tournamentId,
        address indexed organism
    );

    constructor(address _factory, address _initialOwner) Ownable(_initialOwner) {
        factory = OrganismFactory(_factory);
    }

    /**
     * @notice Create a new tournament
     * @return tournamentId ID of created tournament
     */
    function createTournament()
        external
        payable
        nonReentrant
        returns (uint256 tournamentId)
    {
        require(msg.value > 0, "Ecosystem: Prize pool must be > 0");

        tournamentId = tournamentCount++;
        Tournament storage tournament = tournaments[tournamentId];

        tournament.id = tournamentId;
        tournament.prizePool = msg.value;
        tournament.startBlock = block.number;
        tournament.endBlock = block.number + TOURNAMENT_DURATION;
        tournament.completed = false;

        emit TournamentCreated(tournamentId, msg.value, block.number);

        return tournamentId;
    }

    /**
     * @notice Register organism for tournament
     * @param tournamentId Tournament ID
     * @param organism Organism address
     */
    function registerForTournament(
        uint256 tournamentId,
        address organism
    ) external payable nonReentrant {
        require(
            tournamentId < tournamentCount,
            "Ecosystem: Invalid tournament"
        );
        require(
            msg.value >= competitionFee,
            "Ecosystem: Insufficient competition fee"
        );

        Tournament storage tournament = tournaments[tournamentId];

        require(!tournament.completed, "Ecosystem: Tournament completed");
        require(
            block.number < tournament.endBlock,
            "Ecosystem: Tournament ended"
        );
        require(
            factory.isOrganism(organism),
            "Ecosystem: Invalid organism"
        );

        DigitalOrganism org = DigitalOrganism(payable(organism));
        require(org.isAlive(), "Ecosystem: Organism is dead");
        require(
            org.owner() == msg.sender,
            "Ecosystem: Not organism owner"
        );

        // Add to participants
        tournament.participants.push(organism);
        tournament.prizePool += msg.value;

        emit OrganismRegistered(tournamentId, organism);
    }

    /**
     * @notice Run a competition round between two organisms
     * @param tournamentId Tournament ID
     * @param organism1 First organism
     * @param organism2 Second organism
     */
    function compete(
        uint256 tournamentId,
        address organism1,
        address organism2
    ) external nonReentrant {
        require(
            tournamentId < tournamentCount,
            "Ecosystem: Invalid tournament"
        );

        Tournament storage tournament = tournaments[tournamentId];

        require(!tournament.completed, "Ecosystem: Tournament completed");
        require(
            _isParticipant(tournament, organism1),
            "Ecosystem: Organism 1 not in tournament"
        );
        require(
            _isParticipant(tournament, organism2),
            "Ecosystem: Organism 2 not in tournament"
        );

        // Run competition
        DigitalOrganism org1 = DigitalOrganism(payable(organism1));
        bool org1Won = org1.compete(organism2);

        address winner = org1Won ? organism1 : organism2;
        address loser = org1Won ? organism2 : organism1;

        // Update scores
        tournament.scores[winner]++;
        wins[winner]++;
        losses[loser]++;

        emit CompetitionResult(organism1, organism2, winner, tournamentId);
    }

    /**
     * @notice Complete tournament and distribute prizes
     * @param tournamentId Tournament ID
     */
    function completeTournament(
        uint256 tournamentId
    ) external nonReentrant {
        require(
            tournamentId < tournamentCount,
            "Ecosystem: Invalid tournament"
        );

        Tournament storage tournament = tournaments[tournamentId];

        require(!tournament.completed, "Ecosystem: Already completed");
        require(
            block.number >= tournament.endBlock,
            "Ecosystem: Tournament not ended"
        );
        require(
            tournament.participants.length >= MIN_TOURNAMENT_PARTICIPANTS,
            "Ecosystem: Not enough participants"
        );

        // Find winner (highest score)
        address winner = tournament.participants[0];
        uint256 highestScore = tournament.scores[winner];

        for (uint256 i = 1; i < tournament.participants.length; i++) {
            address participant = tournament.participants[i];
            uint256 score = tournament.scores[participant];

            if (score > highestScore) {
                highestScore = score;
                winner = participant;
            }
        }

        tournament.winner = winner;
        tournament.completed = true;

        // Transfer prize to winner's organism (which feeds it)
        uint256 prize = tournament.prizePool;
        DigitalOrganism winnerOrg = DigitalOrganism(payable(winner));
        winnerOrg.feed{value: prize}();

        emit TournamentCompleted(tournamentId, winner, prize);
    }

    /**
     * @notice Batch compete all participants in a tournament
     * @param tournamentId Tournament ID
     */
    function batchCompete(uint256 tournamentId) external nonReentrant {
        require(
            tournamentId < tournamentCount,
            "Ecosystem: Invalid tournament"
        );

        Tournament storage tournament = tournaments[tournamentId];

        require(!tournament.completed, "Ecosystem: Tournament completed");
        require(
            tournament.participants.length >= MIN_TOURNAMENT_PARTICIPANTS,
            "Ecosystem: Not enough participants"
        );

        // Run round-robin competition
        for (uint256 i = 0; i < tournament.participants.length; i++) {
            for (
                uint256 j = i + 1;
                j < tournament.participants.length;
                j++
            ) {
                address org1 = tournament.participants[i];
                address org2 = tournament.participants[j];

                // Check if both are still alive
                DigitalOrganism organism1 = DigitalOrganism(payable(org1));
                DigitalOrganism organism2 = DigitalOrganism(payable(org2));

                if (organism1.isAlive() && organism2.isAlive()) {
                    bool org1Won = organism1.compete(org2);
                    address winner = org1Won ? org1 : org2;
                    address loser = org1Won ? org2 : org1;

                    tournament.scores[winner]++;
                    wins[winner]++;
                    losses[loser]++;

                    emit CompetitionResult(org1, org2, winner, tournamentId);
                }
            }
        }
    }

    /**
     * @notice Set competition fee
     * @param _fee New fee amount
     */
    function setCompetitionFee(uint256 _fee) external onlyOwner {
        competitionFee = _fee;
    }

    /**
     * @notice Get tournament participants
     * @param tournamentId Tournament ID
     * @return Array of participant addresses
     */
    function getTournamentParticipants(
        uint256 tournamentId
    ) external view returns (address[] memory) {
        return tournaments[tournamentId].participants;
    }

    /**
     * @notice Get tournament score for organism
     * @param tournamentId Tournament ID
     * @param organism Organism address
     * @return Score in tournament
     */
    function getTournamentScore(
        uint256 tournamentId,
        address organism
    ) external view returns (uint256) {
        return tournaments[tournamentId].scores[organism];
    }

    /**
     * @notice Get organism win/loss record
     * @param organism Organism address
     * @return winCount Number of wins
     * @return lossCount Number of losses
     */
    function getRecord(
        address organism
    ) external view returns (uint256 winCount, uint256 lossCount) {
        return (wins[organism], losses[organism]);
    }

    /**
     * @notice Get leaderboard (top N organisms by wins)
     * @param count Number of top organisms to return
     * @return organisms Array of top organism addresses
     * @return winCounts Array of corresponding win counts
     */
    function getLeaderboard(
        uint256 count
    )
        external
        view
        returns (address[] memory organisms, uint256[] memory winCounts)
    {
        address[] memory allOrgs = factory.getAllOrganisms();
        uint256 length = count > allOrgs.length ? allOrgs.length : count;

        organisms = new address[](length);
        winCounts = new uint256[](length);

        // Simple selection sort for top N
        for (uint256 i = 0; i < length; i++) {
            uint256 maxWins = 0;
            uint256 maxIndex = 0;

            for (uint256 j = 0; j < allOrgs.length; j++) {
                if (wins[allOrgs[j]] > maxWins) {
                    // Check if not already in leaderboard
                    bool found = false;
                    for (uint256 k = 0; k < i; k++) {
                        if (organisms[k] == allOrgs[j]) {
                            found = true;
                            break;
                        }
                    }

                    if (!found) {
                        maxWins = wins[allOrgs[j]];
                        maxIndex = j;
                    }
                }
            }

            organisms[i] = allOrgs[maxIndex];
            winCounts[i] = maxWins;
        }

        return (organisms, winCounts);
    }

    /**
     * @notice Check if organism is in tournament
     * @param tournament Tournament reference
     * @param organism Organism address
     * @return True if organism is participant
     */
    function _isParticipant(
        Tournament storage tournament,
        address organism
    ) internal view returns (bool) {
        for (uint256 i = 0; i < tournament.participants.length; i++) {
            if (tournament.participants[i] == organism) {
                return true;
            }
        }
        return false;
    }
}
