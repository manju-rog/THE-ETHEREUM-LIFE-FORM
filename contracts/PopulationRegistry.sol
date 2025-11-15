// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title PopulationRegistry
 * @notice Central registry for all organisms in the ecosystem
 * @dev Tracks population, handles resource distribution, and manages evolutionary pressures
 */
contract PopulationRegistry {
    /// @notice Organism metadata
    struct OrganismInfo {
        address organismAddress;
        uint256 birthBlock;
        uint256 generation;
        address parent1;
        address parent2;        // address(0) for asexual reproduction
        bool isAlive;
        uint256 deathBlock;
        uint256 fitnessScore;
        uint256 offspringCount;
    }

    /// @notice Environmental parameters
    struct Environment {
        uint256 resourcePool;           // Total resources available
        uint256 populationCap;          // Maximum population
        uint256 selectionPressure;      // 0-100, higher = more competitive
        uint256 mutationPressure;       // 0-100, higher = more mutations
        uint256 lastExtinctionEvent;    // Block of last mass extinction
        uint256 cosmicRayFrequency;     // Random mutation frequency
    }

    /// @notice Mapping of organism address to info
    mapping(address => OrganismInfo) public organisms;

    /// @notice Array of all organism addresses
    address[] public population;

    /// @notice Current environmental parameters
    Environment public environment;

    /// @notice Total organisms ever created
    uint256 public totalOrganismsCreated;

    /// @notice Current living population count
    uint256 public livingPopulation;

    /// @notice Registry owner/admin
    address public admin;

    /// @notice Events
    event OrganismRegistered(
        address indexed organism,
        uint256 generation,
        address parent1,
        address parent2,
        uint256 timestamp
    );

    event OrganismDied(
        address indexed organism,
        uint256 age,
        uint256 fitnessScore,
        string deathCause
    );

    event ExtinctionEvent(uint256 survivors, uint256 casualties, uint256 timestamp);
    event EnvironmentChanged(string parameter, uint256 oldValue, uint256 newValue);
    event ResourceDistribution(uint256 amount, uint256 recipients);

    /// @notice Modifiers
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }

    modifier onlyOrganism() {
        require(organisms[msg.sender].isAlive, "Not a living organism");
        _;
    }

    constructor() {
        admin = msg.sender;

        // Initialize environment
        environment = Environment({
            resourcePool: 1000000 ether,
            populationCap: 10000,
            selectionPressure: 50,
            mutationPressure: 30,
            lastExtinctionEvent: block.number,
            cosmicRayFrequency: 1000 // Every 1000 blocks on average
        });
    }

    /**
     * @notice Register a new organism in the population
     * @param organism Address of the organism contract
     * @param generation Generation number
     * @param parent1 First parent (or only parent for asexual)
     * @param parent2 Second parent (address(0) for asexual)
     */
    function registerOrganism(
        address organism,
        uint256 generation,
        address parent1,
        address parent2
    ) external {
        require(!organisms[organism].isAlive, "Organism already registered");
        require(livingPopulation < environment.populationCap, "Population cap reached");

        organisms[organism] = OrganismInfo({
            organismAddress: organism,
            birthBlock: block.number,
            generation: generation,
            parent1: parent1,
            parent2: parent2,
            isAlive: true,
            deathBlock: 0,
            fitnessScore: 50, // Start with median fitness
            offspringCount: 0
        });

        population.push(organism);
        totalOrganismsCreated++;
        livingPopulation++;

        // Update parent offspring counts
        if (parent1 != address(0) && organisms[parent1].isAlive) {
            organisms[parent1].offspringCount++;
        }
        if (parent2 != address(0) && organisms[parent2].isAlive) {
            organisms[parent2].offspringCount++;
        }

        emit OrganismRegistered(organism, generation, parent1, parent2, block.timestamp);
    }

    /**
     * @notice Mark an organism as dead
     * @param organism Address of the organism
     * @param deathCause Reason for death
     */
    function recordDeath(address organism, string calldata deathCause) external {
        require(organisms[organism].isAlive, "Organism already dead");

        OrganismInfo storage info = organisms[organism];
        info.isAlive = false;
        info.deathBlock = block.number;
        livingPopulation--;

        uint256 age = block.number - info.birthBlock;

        emit OrganismDied(organism, age, info.fitnessScore, deathCause);
    }

    /**
     * @notice Update fitness score for an organism
     * @param organism Address of the organism
     * @param score New fitness score
     */
    function updateFitness(address organism, uint256 score) external {
        require(organisms[organism].isAlive, "Organism not alive");
        require(score <= 100, "Score must be 0-100");

        organisms[organism].fitnessScore = score;
    }

    /**
     * @notice Get population statistics
     * @return total Total organisms ever created
     * @return living Currently living organisms
     * @return averageGeneration Average generation of living population
     * @return averageFitness Average fitness score
     */
    function getPopulationStats()
        external
        view
        returns (
            uint256 total,
            uint256 living,
            uint256 averageGeneration,
            uint256 averageFitness
        )
    {
        total = totalOrganismsCreated;
        living = livingPopulation;

        if (livingPopulation == 0) {
            return (total, living, 0, 0);
        }

        uint256 totalGeneration = 0;
        uint256 totalFitness = 0;
        uint256 count = 0;

        for (uint256 i = 0; i < population.length; i++) {
            if (organisms[population[i]].isAlive) {
                totalGeneration += organisms[population[i]].generation;
                totalFitness += organisms[population[i]].fitnessScore;
                count++;
            }
        }

        averageGeneration = totalGeneration / count;
        averageFitness = totalFitness / count;
    }

    /**
     * @notice Trigger an extinction event (removes bottom performers)
     * @param survivalRate Percentage of population to survive (0-100)
     */
    function triggerExtinction(uint256 survivalRate) external onlyAdmin {
        require(survivalRate <= 100, "Invalid survival rate");

        uint256 targetSurvivors = (livingPopulation * survivalRate) / 100;
        uint256 casualties = 0;

        // Sort organisms by fitness (simplified - in production use better sorting)
        // Kill organisms with lowest fitness scores
        for (uint256 i = 0; i < population.length && livingPopulation > targetSurvivors; i++) {
            address org = population[i];
            if (organisms[org].isAlive && organisms[org].fitnessScore < 40) {
                organisms[org].isAlive = false;
                organisms[org].deathBlock = block.number;
                livingPopulation--;
                casualties++;
            }
        }

        environment.lastExtinctionEvent = block.number;

        emit ExtinctionEvent(livingPopulation, casualties, block.timestamp);
    }

    /**
     * @notice Distribute resources to living organisms based on fitness
     * @return recipients Number of organisms that received resources
     */
    function distributeResources() external returns (uint256 recipients) {
        require(environment.resourcePool > 0, "No resources available");

        if (livingPopulation == 0) return 0;

        uint256 resourcesPerOrganism = environment.resourcePool / livingPopulation;
        recipients = 0;

        for (uint256 i = 0; i < population.length; i++) {
            if (organisms[population[i]].isAlive) {
                // In a real implementation, would transfer resources to organism contract
                recipients++;
            }
        }

        emit ResourceDistribution(environment.resourcePool, recipients);

        // Replenish resources
        environment.resourcePool = environment.resourcePool / 2; // Decay and regenerate
    }

    /**
     * @notice Check if cosmic ray event should trigger
     * @param randomSeed Random seed for determination
     * @return shouldTrigger Whether a cosmic ray event occurred
     */
    function checkCosmicRay(uint256 randomSeed) external view returns (bool shouldTrigger) {
        uint256 threshold = (randomSeed % 10000);
        uint256 frequency = (10000 / environment.cosmicRayFrequency);

        return threshold < frequency;
    }

    /**
     * @notice Update environmental parameters
     * @param parameter Name of parameter to update
     * @param newValue New value for the parameter
     */
    function updateEnvironment(string calldata parameter, uint256 newValue) external onlyAdmin {
        bytes32 paramHash = keccak256(bytes(parameter));
        uint256 oldValue;

        if (paramHash == keccak256("resourcePool")) {
            oldValue = environment.resourcePool;
            environment.resourcePool = newValue;
        } else if (paramHash == keccak256("populationCap")) {
            oldValue = environment.populationCap;
            environment.populationCap = newValue;
        } else if (paramHash == keccak256("selectionPressure")) {
            require(newValue <= 100, "Must be 0-100");
            oldValue = environment.selectionPressure;
            environment.selectionPressure = newValue;
        } else if (paramHash == keccak256("mutationPressure")) {
            require(newValue <= 100, "Must be 0-100");
            oldValue = environment.mutationPressure;
            environment.mutationPressure = newValue;
        } else if (paramHash == keccak256("cosmicRayFrequency")) {
            oldValue = environment.cosmicRayFrequency;
            environment.cosmicRayFrequency = newValue;
        } else {
            revert("Unknown parameter");
        }

        emit EnvironmentChanged(parameter, oldValue, newValue);
    }

    /**
     * @notice Get list of living organisms
     * @param start Start index
     * @param count Number of organisms to return
     * @return addresses Array of organism addresses
     */
    function getLivingOrganisms(uint256 start, uint256 count)
        external
        view
        returns (address[] memory addresses)
    {
        uint256 livingCount = 0;
        addresses = new address[](count);

        uint256 index = 0;
        for (uint256 i = start; i < population.length && livingCount < count; i++) {
            if (organisms[population[i]].isAlive) {
                addresses[index] = population[i];
                index++;
                livingCount++;
            }
        }

        // Resize array to actual count
        assembly {
            mstore(addresses, index)
        }
    }

    /**
     * @notice Check if organism can reproduce based on population pressure
     * @return canReproduce Whether reproduction is allowed
     * @return resourceCost Cost in resources to reproduce
     */
    function checkReproductionEligibility()
        external
        view
        returns (bool canReproduce, uint256 resourceCost)
    {
        // Higher population pressure increases reproduction cost
        uint256 populationRatio = (livingPopulation * 100) / environment.populationCap;

        canReproduce = livingPopulation < environment.populationCap;

        // Cost scales with population density
        resourceCost = 100 ether + ((populationRatio * 50 ether) / 100);
    }
}
