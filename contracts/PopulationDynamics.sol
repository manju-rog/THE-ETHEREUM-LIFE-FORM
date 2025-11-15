// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./PopulationRegistry.sol";

/**
 * @title PopulationDynamics
 * @notice Advanced population management with migrations and genetic diversity
 * @dev Handles carrying capacity, population booms/busts, migrations
 */
contract PopulationDynamics {
    PopulationRegistry public registry;

    /// @notice Migration types
    enum MigrationType {
        SEASONAL,       // Regular seasonal movement
        RESOURCE,       // Following resource availability
        PRESSURE,       // Escaping competition/predation
        EXPLORATION,    // Discovery of new areas
        COLONIZATION,   // Permanent settlement
        EXODUS          // Mass migration event
    }

    /// @notice Population phase
    enum PopulationPhase {
        GROWTH,         // Rapid expansion
        STABLE,         // Equilibrium
        DECLINE,        // Population crash
        RECOVERY,       // Rebuilding
        BOOM,           // Exponential growth
        BUST            // Catastrophic collapse
    }

    /// @notice Migration event
    struct Migration {
        address[] migrants;
        bytes32 origin;
        bytes32 destination;
        MigrationType migrationType;
        uint256 startBlock;
        uint256 arrivalBlock;
        bool isActive;
    }

    /// @notice Population zone
    struct Zone {
        bytes32 zoneId;
        uint256 carryingCapacity;
        uint256 currentPopulation;
        uint256 resourceLevel;
        uint256[] geneticDiversity;  // Diversity metrics
        bool isHabitable;
    }

    /// @notice Genetic diversity metrics
    struct DiversityMetrics {
        uint256 alleleCount;         // Total genetic variants
        uint256 heterozygosity;      // Genetic variation
        uint256 inbreedingCoeff;     // Inbreeding level
        uint256 effectivePopSize;    // Breeding population
        uint256 geneticDrift;        // Random changes
        bool hasFounderEffect;       // Limited initial diversity
    }

    /// @notice Population history
    struct PopulationSnapshot {
        uint256 blockNumber;
        uint256 population;
        uint256 births;
        uint256 deaths;
        PopulationPhase phase;
    }

    /// @notice All zones
    mapping(bytes32 => Zone) public zones;
    bytes32[] public zoneIds;

    /// @notice Active migrations
    mapping(bytes32 => Migration) public migrations;
    bytes32[] public migrationIds;

    /// @notice Organism current zone
    mapping(address => bytes32) public organismZone;

    /// @notice Genetic diversity tracking
    mapping(bytes32 => DiversityMetrics) public zoneDiversity;

    /// @notice Population history
    PopulationSnapshot[] public populationHistory;

    /// @notice Current population phase
    PopulationPhase public currentPhase;

    /// @notice Extinction debt (delayed extinctions)
    uint256 public extinctionDebt;

    /// @notice Events
    event ZoneCreated(bytes32 indexed zoneId, uint256 carryingCapacity);

    event MigrationStarted(
        bytes32 indexed migrationId,
        bytes32 indexed origin,
        bytes32 indexed destination,
        uint256 migrantCount
    );

    event MigrationCompleted(bytes32 indexed migrationId, uint256 survivors);

    event PopulationBoom(uint256 newPopulation, uint256 growthRate);
    event PopulationBust(uint256 newPopulation, uint256 declineRate);

    event GeneticBottleneck(
        bytes32 indexed zoneId,
        uint256 populationBefore,
        uint256 populationAfter
    );

    event FounderEffect(
        bytes32 indexed zoneId,
        uint256 founderCount,
        uint256 diversityLoss
    );

    event InbreedingDetected(bytes32 indexed zoneId, uint256 coefficient);

    event CarryingCapacityReached(bytes32 indexed zoneId, uint256 population);

    constructor(address _registry) {
        registry = PopulationRegistry(_registry);
        currentPhase = PopulationPhase.GROWTH;

        // Create default zone
        bytes32 genesisZone = keccak256("GENESIS");
        zones[genesisZone] = Zone({
            zoneId: genesisZone,
            carryingCapacity: 10000,
            currentPopulation: 0,
            resourceLevel: 1000000,
            geneticDiversity: new uint256[](0),
            isHabitable: true
        });
        zoneIds.push(genesisZone);

        emit ZoneCreated(genesisZone, 10000);
    }

    /**
     * @notice Create a new population zone
     * @param zoneName Zone identifier
     * @param carryingCapacity Maximum population
     * @param resourceLevel Initial resources
     * @return zoneId Zone ID
     */
    function createZone(
        string memory zoneName,
        uint256 carryingCapacity,
        uint256 resourceLevel
    ) external returns (bytes32 zoneId) {
        zoneId = keccak256(abi.encodePacked(zoneName, block.timestamp));

        zones[zoneId] = Zone({
            zoneId: zoneId,
            carryingCapacity: carryingCapacity,
            currentPopulation: 0,
            resourceLevel: resourceLevel,
            geneticDiversity: new uint256[](0),
            isHabitable: true
        });

        zoneIds.push(zoneId);

        emit ZoneCreated(zoneId, carryingCapacity);

        return zoneId;
    }

    /**
     * @notice Initiate migration
     * @param migrants Array of migrating organisms
     * @param origin Origin zone
     * @param destination Destination zone
     * @param migrationType Type of migration
     * @return migrationId Migration ID
     */
    function initiateMigration(
        address[] memory migrants,
        bytes32 origin,
        bytes32 destination,
        MigrationType migrationType
    ) external returns (bytes32 migrationId) {
        require(zones[origin].isHabitable, "Origin not habitable");
        require(zones[destination].isHabitable, "Destination not habitable");
        require(migrants.length > 0, "No migrants");

        migrationId = keccak256(
            abi.encodePacked(origin, destination, block.timestamp)
        );

        // Calculate arrival time (10 blocks per migration unit)
        uint256 migrationDistance = uint256(keccak256(abi.encodePacked(origin, destination))) % 100;
        uint256 arrivalBlock = block.number + (migrationDistance * 10);

        migrations[migrationId] = Migration({
            migrants: migrants,
            origin: origin,
            destination: destination,
            migrationType: migrationType,
            startBlock: block.number,
            arrivalBlock: arrivalBlock,
            isActive: true
        });

        migrationIds.push(migrationId);

        // Update zone populations
        zones[origin].currentPopulation -= migrants.length;

        emit MigrationStarted(migrationId, origin, destination, migrants.length);

        return migrationId;
    }

    /**
     * @notice Complete migration
     * @param migrationId Migration to complete
     */
    function completeMigration(bytes32 migrationId) external {
        Migration storage migration = migrations[migrationId];
        require(migration.isActive, "Migration not active");
        require(block.number >= migration.arrivalBlock, "Migration in progress");

        // Check capacity
        Zone storage destZone = zones[migration.destination];
        uint256 survivors = migration.migrants.length;

        if (destZone.currentPopulation + survivors > destZone.carryingCapacity) {
            // Some don't survive
            survivors = destZone.carryingCapacity - destZone.currentPopulation;
        }

        // Update destination
        destZone.currentPopulation += survivors;

        // Update organism zones
        for (uint256 i = 0; i < survivors; i++) {
            organismZone[migration.migrants[i]] = migration.destination;
        }

        // Check for founder effect
        if (destZone.currentPopulation == survivors && survivors < 10) {
            _applyFounderEffect(migration.destination, survivors);
        }

        migration.isActive = false;

        emit MigrationCompleted(migrationId, survivors);
    }

    /**
     * @notice Update population phase based on growth rate
     */
    function updatePopulationPhase() external {
        (, uint256 currentPop,,) = registry.getPopulationStats();

        if (populationHistory.length == 0) {
            // First snapshot
            _recordSnapshot(currentPop, 0, 0);
            return;
        }

        PopulationSnapshot storage lastSnapshot = populationHistory[populationHistory.length - 1];
        uint256 previousPop = lastSnapshot.population;

        // Calculate growth rate
        int256 growth = int256(currentPop) - int256(previousPop);
        uint256 growthRate = growth > 0 ? uint256(growth) : 0;
        uint256 declineRate = growth < 0 ? uint256(-growth) : 0;

        // Determine phase
        if (growthRate > previousPop / 4) {
            // >25% growth = BOOM
            currentPhase = PopulationPhase.BOOM;
            emit PopulationBoom(currentPop, growthRate);
        } else if (declineRate > previousPop / 4) {
            // >25% decline = BUST
            currentPhase = PopulationPhase.BUST;
            emit PopulationBust(currentPop, declineRate);
        } else if (growthRate > 0) {
            currentPhase = PopulationPhase.GROWTH;
        } else if (declineRate > 0) {
            currentPhase = PopulationPhase.DECLINE;
        } else {
            currentPhase = PopulationPhase.STABLE;
        }

        _recordSnapshot(currentPop, growthRate, declineRate);
    }

    /**
     * @notice Calculate genetic diversity for zone
     * @param zoneId Zone to analyze
     */
    function calculateGeneticDiversity(bytes32 zoneId) external {
        Zone storage zone = zones[zoneId];
        DiversityMetrics storage metrics = zoneDiversity[zoneId];

        // Simplified diversity calculation
        metrics.alleleCount = zone.currentPopulation * 2; // Diploid
        metrics.heterozygosity = zone.currentPopulation > 10 ? 75 : 30;

        // Calculate inbreeding coefficient
        if (zone.currentPopulation < 50) {
            metrics.inbreedingCoeff = 100 - (zone.currentPopulation * 2);

            if (metrics.inbreedingCoeff > 50) {
                emit InbreedingDetected(zoneId, metrics.inbreedingCoeff);
            }
        }

        // Effective population size
        metrics.effectivePopSize = (zone.currentPopulation * 4) / 5;

        // Check for genetic bottleneck
        if (zone.currentPopulation < 10 && zone.currentPopulation > 0) {
            emit GeneticBottleneck(zoneId, zone.carryingCapacity, zone.currentPopulation);
        }
    }

    /**
     * @notice Apply founder effect to new colony
     * @param zoneId Zone ID
     * @param founderCount Number of founders
     */
    function _applyFounderEffect(bytes32 zoneId, uint256 founderCount) private {
        DiversityMetrics storage metrics = zoneDiversity[zoneId];
        metrics.hasFounderEffect = true;

        // Reduced diversity
        uint256 diversityLoss = 100 - (founderCount * 10);
        metrics.alleleCount = founderCount * 2;
        metrics.heterozygosity = founderCount * 5; // Reduced

        emit FounderEffect(zoneId, founderCount, diversityLoss);
    }

    /**
     * @notice Record population snapshot
     */
    function _recordSnapshot(
        uint256 population,
        uint256 births,
        uint256 deaths
    ) private {
        populationHistory.push(
            PopulationSnapshot({
                blockNumber: block.number,
                population: population,
                births: births,
                deaths: deaths,
                phase: currentPhase
            })
        );

        // Keep last 1000 snapshots
        if (populationHistory.length > 1000) {
            // Remove oldest - in production use circular buffer
            for (uint256 i = 0; i < populationHistory.length - 1; i++) {
                populationHistory[i] = populationHistory[i + 1];
            }
            populationHistory.pop();
        }
    }

    /**
     * @notice Check carrying capacity for zone
     * @param zoneId Zone to check
     * @return atCapacity Whether at carrying capacity
     * @return availableSlots Available population slots
     */
    function checkCarryingCapacity(bytes32 zoneId)
        external
        returns (bool atCapacity, uint256 availableSlots)
    {
        Zone storage zone = zones[zoneId];

        atCapacity = zone.currentPopulation >= zone.carryingCapacity;

        if (atCapacity) {
            emit CarryingCapacityReached(zoneId, zone.currentPopulation);
            availableSlots = 0;
        } else {
            availableSlots = zone.carryingCapacity - zone.currentPopulation;
        }

        return (atCapacity, availableSlots);
    }

    /**
     * @notice Get zone information
     */
    function getZoneInfo(bytes32 zoneId)
        external
        view
        returns (
            uint256 carryingCapacity,
            uint256 currentPopulation,
            uint256 resourceLevel,
            bool isHabitable
        )
    {
        Zone storage zone = zones[zoneId];
        return (
            zone.carryingCapacity,
            zone.currentPopulation,
            zone.resourceLevel,
            zone.isHabitable
        );
    }

    /**
     * @notice Get genetic diversity metrics
     */
    function getGeneticDiversity(bytes32 zoneId)
        external
        view
        returns (
            uint256 alleleCount,
            uint256 heterozygosity,
            uint256 inbreedingCoeff,
            bool hasFounderEffect
        )
    {
        DiversityMetrics storage metrics = zoneDiversity[zoneId];
        return (
            metrics.alleleCount,
            metrics.heterozygosity,
            metrics.inbreedingCoeff,
            metrics.hasFounderEffect
        );
    }

    /**
     * @notice Get population phase
     */
    function getCurrentPhase() external view returns (PopulationPhase) {
        return currentPhase;
    }

    /**
     * @notice Get migration count
     */
    function getMigrationCount() external view returns (uint256) {
        return migrationIds.length;
    }

    /**
     * @notice Get zone count
     */
    function getZoneCount() external view returns (uint256) {
        return zoneIds.length;
    }
}
