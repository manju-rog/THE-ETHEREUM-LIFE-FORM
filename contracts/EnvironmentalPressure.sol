// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title EnvironmentalPressure
 * @notice Tracks blockchain conditions and creates evolutionary pressures
 * @dev Block time, gas prices, network congestion as environmental factors
 */
contract EnvironmentalPressure {
    /// @notice Environmental event types
    enum EventType {
        CALM,               // Normal conditions
        STORM,              // High gas prices
        DROUGHT,            // Low block production
        FLOOD,              // Flash loan attack
        EARTHQUAKE,         // Network fork
        MIGRATION,          // L2 bridge event
        PREDATION,          // MEV bot activity
        EXTINCTION,         // Rug pull event
        SPECIATION,         // Fork speciation
        COLONIZATION        // New L2 discovered
    }

    /// @notice Climate condition
    enum Climate {
        TEMPERATE,          // Normal gas prices
        HOT,                // High gas prices
        COLD,               // Low activity
        VOLATILE,           // Rapid changes
        STABLE              // Consistent conditions
    }

    /// @notice Environmental state
    struct Environment {
        Climate climate;
        EventType currentEvent;
        uint256 gasClimate;         // Average gas price
        uint256 blockTimeVariance;  // Block time consistency
        uint256 congestionLevel;    // 0-100
        uint256 mevPressure;        // MEV bot activity
        uint256 lastUpdate;
        uint256 eventDuration;
    }

    /// @notice Seasonal cycle
    struct Season {
        string name;
        uint256 startBlock;
        uint256 duration;
        uint256 survivalDifficulty; // 0-100
        uint256 resourceMultiplier; // Percentage
    }

    /// @notice Organism adaptation stats
    struct AdaptationStats {
        uint256 gasEfficiency;
        uint256 stormSurvival;
        uint256 floodResistance;
        uint256 mevEvasion;
        uint256 migrationSuccess;
        bool hasAdapted;
    }

    /// @notice Current environment
    Environment public environment;

    /// @notice Current season
    Season public currentSeason;

    /// @notice Historical gas prices
    uint256[] public gasHistory;

    /// @notice Historical block times
    uint256[] public blockTimeHistory;

    /// @notice Organism adaptations
    mapping(address => AdaptationStats) public adaptations;

    /// @notice Mass extinction events
    mapping(uint256 => bool) public extinctionEvents;

    /// @notice L2 networks discovered
    mapping(bytes32 => bool) public l2Networks;

    /// @notice Migration paths
    mapping(address => bytes32) public migrationDestination;

    /// @notice Events
    event EnvironmentalChange(
        Climate newClimate,
        EventType eventType,
        uint256 severity
    );

    event MassExtinction(
        uint256 indexed blockNumber,
        uint256 casualties,
        string cause
    );

    event SeasonalShift(
        string seasonName,
        uint256 difficulty,
        uint256 resourceMultiplier
    );

    event OrganismAdapted(
        address indexed organism,
        string adaptationType,
        uint256 effectiveness
    );

    event MigrationEvent(
        address indexed organism,
        bytes32 indexed destination,
        uint256 timestamp
    );

    event MEVPredation(
        address indexed victim,
        uint256 resourcesLost,
        uint256 blockNumber
    );

    constructor() {
        environment = Environment({
            climate: Climate.TEMPERATE,
            currentEvent: EventType.CALM,
            gasClimate: 20 gwei,
            blockTimeVariance: 12,
            congestionLevel: 50,
            mevPressure: 10,
            lastUpdate: block.number,
            eventDuration: 0
        });

        currentSeason = Season({
            name: "Genesis",
            startBlock: block.number,
            duration: 10000,
            survivalDifficulty: 50,
            resourceMultiplier: 100
        });
    }

    /**
     * @notice Update environmental conditions based on blockchain state
     */
    function updateEnvironment() external {
        // Update gas climate
        uint256 avgGas = _calculateAverageGas();
        environment.gasClimate = avgGas;

        // Determine climate based on gas prices
        if (avgGas > 100 gwei) {
            environment.climate = Climate.HOT;
        } else if (avgGas < 10 gwei) {
            environment.climate = Climate.COLD;
        } else if (_isVolatile()) {
            environment.climate = Climate.VOLATILE;
        } else {
            environment.climate = Climate.TEMPERATE;
        }

        // Update congestion level
        environment.congestionLevel = _calculateCongestion();

        // Check for environmental events
        _checkEnvironmentalEvents();

        // Update season
        _updateSeason();

        environment.lastUpdate = block.number;

        emit EnvironmentalChange(
            environment.climate,
            environment.currentEvent,
            environment.congestionLevel
        );
    }

    /**
     * @notice Trigger a storm event (high gas prices)
     */
    function triggerStorm() external {
        environment.currentEvent = EventType.STORM;
        environment.eventDuration = 100; // 100 blocks

        // Storms increase MEV pressure
        environment.mevPressure += 20;

        emit EnvironmentalChange(Climate.HOT, EventType.STORM, environment.mevPressure);
    }

    /**
     * @notice Trigger flash loan flood
     */
    function triggerFlood() external {
        environment.currentEvent = EventType.FLOOD;
        environment.eventDuration = 50;

        emit EnvironmentalChange(environment.climate, EventType.FLOOD, 100);
    }

    /**
     * @notice Trigger mass extinction
     * @param cause Cause of extinction
     * @return casualties Estimated casualties
     */
    function triggerExtinction(string memory cause) external returns (uint256 casualties) {
        environment.currentEvent = EventType.EXTINCTION;
        extinctionEvents[block.number] = true;

        // Extinction affects 30-70% of population
        casualties = 50; // Simplified

        emit MassExtinction(block.number, casualties, cause);

        return casualties;
    }

    /**
     * @notice Organism adapts to environmental pressure
     * @param adaptationType Type of adaptation
     */
    function adaptToEnvironment(string memory adaptationType) external {
        AdaptationStats storage stats = adaptations[msg.sender];

        bytes32 typeHash = keccak256(bytes(adaptationType));

        if (typeHash == keccak256("GAS_EFFICIENCY")) {
            stats.gasEfficiency += 10;
        } else if (typeHash == keccak256("STORM_SURVIVAL")) {
            stats.stormSurvival += 15;
        } else if (typeHash == keccak256("FLOOD_RESISTANCE")) {
            stats.floodResistance += 12;
        } else if (typeHash == keccak256("MEV_EVASION")) {
            stats.mevEvasion += 20;
        } else if (typeHash == keccak256("MIGRATION")) {
            stats.migrationSuccess += 10;
        }

        stats.hasAdapted = true;

        emit OrganismAdapted(msg.sender, adaptationType, 100);
    }

    /**
     * @notice Initiate migration to L2
     * @param l2Network L2 network identifier
     */
    function migrateToL2(bytes32 l2Network) external {
        require(l2Networks[l2Network], "L2 not discovered");

        migrationDestination[msg.sender] = l2Network;

        emit MigrationEvent(msg.sender, l2Network, block.timestamp);
    }

    /**
     * @notice Discover new L2 network
     * @param l2Network L2 identifier
     */
    function discoverL2(bytes32 l2Network) external {
        l2Networks[l2Network] = true;

        environment.currentEvent = EventType.COLONIZATION;

        emit EnvironmentalChange(environment.climate, EventType.COLONIZATION, 0);
    }

    /**
     * @notice Simulate MEV bot predation
     * @param victim Victim organism
     * @param resourcesLost Resources extracted
     */
    function mevPredation(address victim, uint256 resourcesLost) external {
        environment.mevPressure += 1;

        emit MEVPredation(victim, resourcesLost, block.number);
    }

    /**
     * @notice Calculate survival chance in current conditions
     * @param organism Organism address
     * @return survivalChance Percentage (0-100)
     */
    function calculateSurvivalChance(address organism)
        external
        view
        returns (uint256 survivalChance)
    {
        AdaptationStats storage stats = adaptations[organism];

        survivalChance = 50; // Base 50%

        // Climate effects
        if (environment.climate == Climate.HOT) {
            survivalChance -= 20;
            survivalChance += stats.gasEfficiency / 5;
        } else if (environment.climate == Climate.VOLATILE) {
            survivalChance -= 15;
        }

        // Event effects
        if (environment.currentEvent == EventType.STORM) {
            survivalChance -= 25;
            survivalChance += stats.stormSurvival;
        } else if (environment.currentEvent == EventType.FLOOD) {
            survivalChance -= 30;
            survivalChance += stats.floodResistance;
        } else if (environment.currentEvent == EventType.PREDATION) {
            survivalChance -= environment.mevPressure;
            survivalChance += stats.mevEvasion;
        }

        // Season difficulty
        survivalChance -= currentSeason.survivalDifficulty / 2;

        // Cap at 0-100
        if (survivalChance > 100) survivalChance = 100;

        return survivalChance;
    }

    /**
     * @notice Check environmental events
     */
    function _checkEnvironmentalEvents() private {
        // Random event chance
        uint256 randomValue = uint256(
            keccak256(abi.encodePacked(block.timestamp, block.prevrandao))
        ) % 100;

        if (randomValue < 5) {
            // 5% chance of storm
            environment.currentEvent = EventType.STORM;
        } else if (randomValue < 8) {
            // 3% chance of flood
            environment.currentEvent = EventType.FLOOD;
        } else if (randomValue < 10) {
            // 2% chance of MEV predation spike
            environment.currentEvent = EventType.PREDATION;
            environment.mevPressure += 10;
        } else if (environment.eventDuration > 0) {
            environment.eventDuration--;
        } else {
            environment.currentEvent = EventType.CALM;
        }
    }

    /**
     * @notice Update season
     */
    function _updateSeason() private {
        uint256 blocksSinceStart = block.number - currentSeason.startBlock;

        if (blocksSinceStart >= currentSeason.duration) {
            // Change season
            uint256 seasonIndex = (block.number / currentSeason.duration) % 4;

            if (seasonIndex == 0) {
                currentSeason.name = "Spring";
                currentSeason.survivalDifficulty = 30;
                currentSeason.resourceMultiplier = 150;
            } else if (seasonIndex == 1) {
                currentSeason.name = "Summer";
                currentSeason.survivalDifficulty = 40;
                currentSeason.resourceMultiplier = 120;
            } else if (seasonIndex == 2) {
                currentSeason.name = "Autumn";
                currentSeason.survivalDifficulty = 60;
                currentSeason.resourceMultiplier = 80;
            } else {
                currentSeason.name = "Winter";
                currentSeason.survivalDifficulty = 80;
                currentSeason.resourceMultiplier = 50;
            }

            currentSeason.startBlock = block.number;

            emit SeasonalShift(
                currentSeason.name,
                currentSeason.survivalDifficulty,
                currentSeason.resourceMultiplier
            );
        }
    }

    /**
     * @notice Calculate average gas price
     */
    function _calculateAverageGas() private returns (uint256) {
        // Add current gas price to history
        gasHistory.push(tx.gasprice);

        // Keep last 100 blocks
        if (gasHistory.length > 100) {
            // Remove oldest
            for (uint256 i = 0; i < gasHistory.length - 1; i++) {
                gasHistory[i] = gasHistory[i + 1];
            }
            gasHistory.pop();
        }

        // Calculate average
        uint256 sum = 0;
        for (uint256 i = 0; i < gasHistory.length; i++) {
            sum += gasHistory[i];
        }

        return gasHistory.length > 0 ? sum / gasHistory.length : tx.gasprice;
    }

    /**
     * @notice Check if gas prices are volatile
     */
    function _isVolatile() private view returns (bool) {
        if (gasHistory.length < 10) return false;

        uint256 maxGas = 0;
        uint256 minGas = type(uint256).max;

        for (uint256 i = 0; i < gasHistory.length; i++) {
            if (gasHistory[i] > maxGas) maxGas = gasHistory[i];
            if (gasHistory[i] < minGas) minGas = gasHistory[i];
        }

        // Volatile if 3x difference
        return maxGas >= minGas * 3;
    }

    /**
     * @notice Calculate network congestion
     */
    function _calculateCongestion() private pure returns (uint256) {
        // Simplified - in production would check actual network metrics
        return 50; // Medium congestion
    }

    /**
     * @notice Get current environmental stats
     */
    function getEnvironmentalStats()
        external
        view
        returns (
            Climate climate,
            EventType currentEvent,
            uint256 gasClimate,
            uint256 congestion,
            uint256 mevPressure,
            string memory season
        )
    {
        return (
            environment.climate,
            environment.currentEvent,
            environment.gasClimate,
            environment.congestionLevel,
            environment.mevPressure,
            currentSeason.name
        );
    }

    /**
     * @notice Get organism adaptation stats
     */
    function getAdaptations(address organism)
        external
        view
        returns (
            uint256 gasEfficiency,
            uint256 stormSurvival,
            uint256 floodResistance,
            uint256 mevEvasion,
            bool hasAdapted
        )
    {
        AdaptationStats storage stats = adaptations[organism];
        return (
            stats.gasEfficiency,
            stats.stormSurvival,
            stats.floodResistance,
            stats.mevEvasion,
            stats.hasAdapted
        );
    }
}
