// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./PopulationRegistry.sol";

/**
 * @title EvolutionEngine
 * @notice Manages evolution triggers and environmental pressures
 * @dev Handles time-based evolution, cosmic events, and selective pressures
 */
contract EvolutionEngine {
    PopulationRegistry public registry;

    /// @notice Evolution trigger configuration
    struct EvolutionConfig {
        uint256 blockInterval;          // Blocks between evolution cycles
        uint256 lastEvolutionBlock;     // Last evolution event
        uint256 resourceThreshold;      // Resources needed for evolution
        uint256 populationThreshold;    // Population density for evolution
        bool timeBasedEnabled;          // Time-based evolution
        bool resourceBasedEnabled;      // Resource-based evolution
        bool competitionBasedEnabled;   // Competition-based evolution
        bool randomEnabled;             // Random cosmic rays
    }

    EvolutionConfig public config;

    /// @notice Environmental pressures
    struct EnvironmentalPressure {
        uint256 temperature;    // Affects mutation rate
        uint256 radiation;      // Causes random mutations
        uint256 resources;      // Affects survival
        uint256 predation;      // Selection pressure
        uint256 cooperation;    // Group selection benefit
    }

    EnvironmentalPressure public environment;

    /// @notice Owner
    address public owner;

    /// @notice Events
    event EvolutionTriggered(
        string triggerType,
        uint256 affectedOrganisms,
        uint256 timestamp
    );

    event EnvironmentalChange(
        string pressureType,
        uint256 oldValue,
        uint256 newValue,
        uint256 timestamp
    );

    event CosmicRayEvent(
        uint256 organismsAffected,
        uint256 mutationsInduced,
        uint256 timestamp
    );

    event MassExtinction(
        uint256 casualties,
        uint256 survivors,
        string cause,
        uint256 timestamp
    );

    event AdaptiveResponse(
        address indexed organism,
        uint256 fitnessChange,
        string adaptation
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    constructor(address _registry) {
        registry = PopulationRegistry(_registry);
        owner = msg.sender;

        // Initialize default configuration
        config = EvolutionConfig({
            blockInterval: 1000,        // Evolution every ~3.5 hours
            lastEvolutionBlock: block.number,
            resourceThreshold: 10000 ether,
            populationThreshold: 100,
            timeBasedEnabled: true,
            resourceBasedEnabled: true,
            competitionBasedEnabled: true,
            randomEnabled: true
        });

        // Initialize environmental pressures
        environment = EnvironmentalPressure({
            temperature: 50,    // Neutral
            radiation: 20,      // Low
            resources: 100,     // Abundant
            predation: 30,      // Moderate
            cooperation: 50     // Neutral
        });
    }

    /**
     * @notice Check if evolution should trigger
     * @return shouldTrigger Whether evolution event should occur
     * @return triggerType Type of trigger that fired
     */
    function checkEvolutionTrigger()
        public
        view
        returns (bool shouldTrigger, string memory triggerType)
    {
        // Time-based trigger
        if (config.timeBasedEnabled) {
            if (block.number >= config.lastEvolutionBlock + config.blockInterval) {
                return (true, "TIME_BASED");
            }
        }

        // Population density trigger
        if (config.resourceBasedEnabled) {
            (, uint256 living,,) = registry.getPopulationStats();
            if (living >= config.populationThreshold) {
                return (true, "POPULATION_DENSITY");
            }
        }

        // Resource threshold trigger
        if (config.resourceBasedEnabled) {
            (uint256 resourcePool,,,,,) = registry.environment();
            if (resourcePool >= config.resourceThreshold) {
                return (true, "RESOURCE_THRESHOLD");
            }
        }

        // Random cosmic ray
        if (config.randomEnabled) {
            uint256 randomSeed = uint256(
                keccak256(abi.encodePacked(block.timestamp, block.prevrandao))
            );
            if (registry.checkCosmicRay(randomSeed)) {
                return (true, "COSMIC_RAY");
            }
        }

        return (false, "NONE");
    }

    /**
     * @notice Trigger evolution event
     * @param triggerType Type of evolution trigger
     * @return affectedCount Number of organisms affected
     */
    function triggerEvolution(string memory triggerType)
        external
        returns (uint256 affectedCount)
    {
        (bool shouldTrigger,) = checkEvolutionTrigger();
        require(shouldTrigger, "No trigger condition met");

        config.lastEvolutionBlock = block.number;

        // Get living organisms
        address[] memory organisms = registry.getLivingOrganisms(0, 100);
        affectedCount = 0;

        bytes32 triggerHash = keccak256(bytes(triggerType));

        if (triggerHash == keccak256("TIME_BASED")) {
            affectedCount = _timeBasedEvolution(organisms);
        } else if (triggerHash == keccak256("COSMIC_RAY")) {
            affectedCount = _cosmicRayEvent(organisms);
        } else if (triggerHash == keccak256("POPULATION_DENSITY")) {
            affectedCount = _populationPressure(organisms);
        } else if (triggerHash == keccak256("RESOURCE_THRESHOLD")) {
            affectedCount = _resourceCompetition(organisms);
        }

        emit EvolutionTriggered(triggerType, affectedCount, block.timestamp);

        return affectedCount;
    }

    /**
     * @notice Time-based evolution - gradual changes
     * @param organisms Array of organism addresses
     * @return affected Number of organisms affected
     */
    function _timeBasedEvolution(address[] memory organisms)
        private
        returns (uint256 affected)
    {
        affected = 0;

        for (uint256 i = 0; i < organisms.length; i++) {
            if (organisms[i] == address(0)) break;

            // Would call updateState on each organism
            // For now just count them
            if (organisms[i] != address(0)) {
                affected++;
            }
        }

        return affected;
    }

    /**
     * @notice Cosmic ray event - random mutations
     * @param organisms Array of organism addresses
     * @return affected Number of organisms affected
     */
    function _cosmicRayEvent(address[] memory organisms)
        private
        returns (uint256 affected)
    {
        affected = 0;
        uint256 mutations = 0;

        uint256 seed = uint256(
            keccak256(abi.encodePacked(block.timestamp, block.prevrandao))
        );

        for (uint256 i = 0; i < organisms.length; i++) {
            if (organisms[i] == address(0)) break;

            // 20% chance each organism is affected by cosmic ray
            if ((uint256(keccak256(abi.encodePacked(seed, i))) % 100) < 20) {
                affected++;
                mutations++;
                // Cosmic rays would trigger mutations in the organism
                // This would be handled by the organism's internal mutation logic
            }
        }

        emit CosmicRayEvent(affected, mutations, block.timestamp);

        return affected;
    }

    /**
     * @notice Population pressure - competition increases
     * @param organisms Array of organism addresses
     * @return affected Number of organisms affected
     */
    function _populationPressure(address[] memory organisms)
        private
        returns (uint256 affected)
    {
        affected = 0;

        // Increase selection pressure
        (,,uint256 oldPressure,,,) = registry.environment();
        uint256 newPressure = oldPressure + 10;
        if (newPressure > 100) newPressure = 100;

        // Would update registry environment here

        emit EnvironmentalChange(
            "SELECTION_PRESSURE",
            oldPressure,
            newPressure,
            block.timestamp
        );

        affected = organisms.length;
        return affected;
    }

    /**
     * @notice Resource competition - survival of the fittest
     * @param organisms Array of organism addresses
     * @return affected Number of organisms affected
     */
    function _resourceCompetition(address[] memory organisms)
        private
        returns (uint256 affected)
    {
        affected = 0;

        // Trigger resource distribution
        try registry.distributeResources() returns (uint256 recipients) {
            affected = recipients;
        } catch {
            // Distribution failed
        }

        return affected;
    }

    /**
     * @notice Trigger extinction event
     * @param cause Cause of extinction
     * @param severity Severity (0-100, higher = more deadly)
     */
    function triggerExtinction(string memory cause, uint256 severity)
        external
        onlyOwner
    {
        require(severity <= 100, "Severity must be 0-100");

        // Calculate survival rate (inverse of severity)
        uint256 survivalRate = 100 - severity;

        (, uint256 livingBefore,,) = registry.getPopulationStats();

        // Trigger extinction in registry
        registry.triggerExtinction(survivalRate);

        (, uint256 livingAfter,,) = registry.getPopulationStats();

        uint256 casualties = livingBefore - livingAfter;

        emit MassExtinction(casualties, livingAfter, cause, block.timestamp);
    }

    /**
     * @notice Update environmental pressure
     * @param pressureType Type of pressure to update
     * @param newValue New value (0-100)
     */
    function updateEnvironmentalPressure(
        string memory pressureType,
        uint256 newValue
    ) external onlyOwner {
        require(newValue <= 100, "Value must be 0-100");

        bytes32 typeHash = keccak256(bytes(pressureType));
        uint256 oldValue;

        if (typeHash == keccak256("TEMPERATURE")) {
            oldValue = environment.temperature;
            environment.temperature = newValue;
        } else if (typeHash == keccak256("RADIATION")) {
            oldValue = environment.radiation;
            environment.radiation = newValue;
        } else if (typeHash == keccak256("RESOURCES")) {
            oldValue = environment.resources;
            environment.resources = newValue;
        } else if (typeHash == keccak256("PREDATION")) {
            oldValue = environment.predation;
            environment.predation = newValue;
        } else if (typeHash == keccak256("COOPERATION")) {
            oldValue = environment.cooperation;
            environment.cooperation = newValue;
        } else {
            revert("Unknown pressure type");
        }

        emit EnvironmentalChange(pressureType, oldValue, newValue, block.timestamp);
    }

    /**
     * @notice Update evolution configuration
     * @param blockInterval New block interval for time-based evolution
     * @param resourceThreshold New resource threshold
     * @param populationThreshold New population threshold
     */
    function updateEvolutionConfig(
        uint256 blockInterval,
        uint256 resourceThreshold,
        uint256 populationThreshold
    ) external onlyOwner {
        config.blockInterval = blockInterval;
        config.resourceThreshold = resourceThreshold;
        config.populationThreshold = populationThreshold;
    }

    /**
     * @notice Enable/disable evolution triggers
     * @param timeBased Enable time-based evolution
     * @param resourceBased Enable resource-based evolution
     * @param competitionBased Enable competition-based evolution
     * @param random Enable random cosmic rays
     */
    function setEvolutionTriggers(
        bool timeBased,
        bool resourceBased,
        bool competitionBased,
        bool random
    ) external onlyOwner {
        config.timeBasedEnabled = timeBased;
        config.resourceBasedEnabled = resourceBased;
        config.competitionBasedEnabled = competitionBased;
        config.randomEnabled = random;
    }

    /**
     * @notice Get current environmental state
     * @return temp Temperature
     * @return rad Radiation
     * @return res Resources
     * @return pred Predation
     * @return coop Cooperation
     */
    function getEnvironment()
        external
        view
        returns (
            uint256 temp,
            uint256 rad,
            uint256 res,
            uint256 pred,
            uint256 coop
        )
    {
        return (
            environment.temperature,
            environment.radiation,
            environment.resources,
            environment.predation,
            environment.cooperation
        );
    }

    /**
     * @notice Calculate adaptive landscape
     * @param fitnessScores Array of fitness scores
     * @return peak Highest fitness
     * @return valley Lowest fitness
     * @return average Average fitness
     */
    function calculateAdaptiveLandscape(uint256[] memory fitnessScores)
        external
        pure
        returns (
            uint256 peak,
            uint256 valley,
            uint256 average
        )
    {
        if (fitnessScores.length == 0) {
            return (0, 0, 0);
        }

        peak = 0;
        valley = 100;
        uint256 sum = 0;

        for (uint256 i = 0; i < fitnessScores.length; i++) {
            if (fitnessScores[i] > peak) peak = fitnessScores[i];
            if (fitnessScores[i] < valley) valley = fitnessScores[i];
            sum += fitnessScores[i];
        }

        average = sum / fitnessScores.length;

        return (peak, valley, average);
    }
}
