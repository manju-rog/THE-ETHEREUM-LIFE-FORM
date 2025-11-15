// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./NutrientToken.sol";

/**
 * @title ResourceEconomy
 * @notice Manages resource distribution, scarcity, and trophic levels
 * @dev Integrates ETH (energy) and Nutrient tokens
 */
contract ResourceEconomy {
    /// @notice Trophic levels in the food chain
    enum TrophicLevel {
        PRODUCER,       // Photosynthesis (mine nutrients)
        PRIMARY,        // Herbivores (consume nutrients)
        SECONDARY,      // Carnivores (hunt primary)
        TERTIARY,       // Apex predators
        DECOMPOSER      // Recycle dead organisms
    }

    /// @notice Resource pool structure
    struct ResourcePool {
        uint256 energy;         // ETH stored
        uint256 nutrients;      // Nutrient tokens
        uint256 capacity;       // Maximum capacity
        uint256 regenerationRate; // Per block
        uint256 lastUpdate;     // Last regeneration
        bool isActive;
    }

    /// @notice Organism resource stats
    struct ResourceStats {
        uint256 energyReserve;
        uint256 nutrientReserve;
        TrophicLevel trophicLevel;
        uint256 consumptionRate;
        uint256 efficiencyBonus;
        uint256 lastFed;
    }

    NutrientToken public nutrientToken;

    /// @notice Resource pools mapping
    mapping(bytes32 => ResourcePool) public resourcePools;
    bytes32[] public poolIds;

    /// @notice Organism resource stats
    mapping(address => ResourceStats) public organismResources;

    /// @notice Trophic level populations
    mapping(TrophicLevel => uint256) public trophicPopulation;

    /// @notice Energy transfer efficiency (percentage)
    uint256 public constant TROPHIC_EFFICIENCY = 10; // 10% energy transfer

    /// @notice Scarcity multiplier (increases with competition)
    uint256 public scarcityMultiplier = 100; // 100 = normal

    /// @notice Events
    event ResourcePoolCreated(bytes32 indexed poolId, uint256 energy, uint256 nutrients);
    event ResourcesHarvested(address indexed organism, bytes32 poolId, uint256 energy, uint256 nutrients);
    event EnergyTransferred(address indexed from, address indexed to, uint256 amount);
    event TrophicLevelChanged(address indexed organism, TrophicLevel oldLevel, TrophicLevel newLevel);
    event ScarcityUpdate(uint256 newMultiplier, string condition);

    constructor(address _nutrientToken) {
        nutrientToken = NutrientToken(_nutrientToken);
    }

    /**
     * @notice Create a resource pool
     * @param location Location identifier
     * @param capacity Maximum capacity
     * @param regenerationRate Nutrients per block
     * @return poolId ID of created pool
     */
    function createResourcePool(
        string memory location,
        uint256 capacity,
        uint256 regenerationRate
    ) external payable returns (bytes32 poolId) {
        poolId = keccak256(abi.encodePacked(location, block.timestamp));

        resourcePools[poolId] = ResourcePool({
            energy: msg.value,
            nutrients: 0,
            capacity: capacity,
            regenerationRate: regenerationRate,
            lastUpdate: block.number,
            isActive: true
        });

        poolIds.push(poolId);

        emit ResourcePoolCreated(poolId, msg.value, 0);

        return poolId;
    }

    /**
     * @notice Harvest resources from a pool
     * @param poolId Pool to harvest from
     * @return energyHarvested Energy obtained
     * @return nutrientsHarvested Nutrients obtained
     */
    function harvestFromPool(bytes32 poolId)
        external
        returns (uint256 energyHarvested, uint256 nutrientsHarvested)
    {
        ResourcePool storage pool = resourcePools[poolId];
        require(pool.isActive, "Pool inactive");

        // Regenerate resources based on blocks passed
        _regeneratePool(poolId);

        // Calculate harvest amount (10% of pool)
        energyHarvested = pool.energy / 10;
        nutrientsHarvested = pool.nutrients / 10;

        // Apply scarcity multiplier
        energyHarvested = (energyHarvested * 100) / scarcityMultiplier;
        nutrientsHarvested = (nutrientsHarvested * 100) / scarcityMultiplier;

        // Transfer resources
        pool.energy -= energyHarvested;
        pool.nutrients -= nutrientsHarvested;

        // Update organism stats
        ResourceStats storage stats = organismResources[msg.sender];
        stats.energyReserve += energyHarvested;
        stats.nutrientReserve += nutrientsHarvested;
        stats.lastFed = block.number;

        // Transfer energy
        payable(msg.sender).transfer(energyHarvested);

        emit ResourcesHarvested(msg.sender, poolId, energyHarvested, nutrientsHarvested);

        return (energyHarvested, nutrientsHarvested);
    }

    /**
     * @notice Set organism trophic level
     * @param organism Address of organism
     * @param level New trophic level
     */
    function setTrophicLevel(address organism, TrophicLevel level) external {
        TrophicLevel oldLevel = organismResources[organism].trophicLevel;

        // Update populations
        if (oldLevel != level) {
            if (organismResources[organism].energyReserve > 0) {
                trophicPopulation[oldLevel]--;
            }
            trophicPopulation[level]++;
        }

        organismResources[organism].trophicLevel = level;

        // Set consumption rate based on trophic level
        if (level == TrophicLevel.PRODUCER) {
            organismResources[organism].consumptionRate = 1 ether;
        } else if (level == TrophicLevel.PRIMARY) {
            organismResources[organism].consumptionRate = 2 ether;
        } else if (level == TrophicLevel.SECONDARY) {
            organismResources[organism].consumptionRate = 5 ether;
        } else if (level == TrophicLevel.TERTIARY) {
            organismResources[organism].consumptionRate = 10 ether;
        } else {
            organismResources[organism].consumptionRate = 0.5 ether;
        }

        emit TrophicLevelChanged(organism, oldLevel, level);
    }

    /**
     * @notice Transfer energy between organisms (trophic transfer)
     * @param from Source organism
     * @param to Destination organism
     * @param amount Energy to transfer
     */
    function transferEnergy(address from, address to, uint256 amount) external {
        require(organismResources[from].energyReserve >= amount, "Insufficient energy");

        // Apply trophic efficiency loss
        uint256 transferAmount = (amount * TROPHIC_EFFICIENCY) / 100;

        organismResources[from].energyReserve -= amount;
        organismResources[to].energyReserve += transferAmount;

        emit EnergyTransferred(from, to, transferAmount);
    }

    /**
     * @notice Update scarcity based on total population
     * @param totalPopulation Current total population
     */
    function updateScarcity(uint256 totalPopulation) external {
        string memory condition;

        if (totalPopulation < 100) {
            scarcityMultiplier = 50; // Abundance
            condition = "ABUNDANCE";
        } else if (totalPopulation < 500) {
            scarcityMultiplier = 100; // Normal
            condition = "NORMAL";
        } else if (totalPopulation < 1000) {
            scarcityMultiplier = 150; // Moderate scarcity
            condition = "MODERATE_SCARCITY";
        } else {
            scarcityMultiplier = 200; // High scarcity
            condition = "HIGH_SCARCITY";
        }

        emit ScarcityUpdate(scarcityMultiplier, condition);
    }

    /**
     * @notice Regenerate pool resources
     * @param poolId Pool to regenerate
     */
    function _regeneratePool(bytes32 poolId) private {
        ResourcePool storage pool = resourcePools[poolId];

        uint256 blocksPassed = block.number - pool.lastUpdate;
        uint256 regenAmount = blocksPassed * pool.regenerationRate;

        // Cap at capacity
        if (pool.nutrients + regenAmount > pool.capacity) {
            pool.nutrients = pool.capacity;
        } else {
            pool.nutrients += regenAmount;
        }

        pool.lastUpdate = block.number;
    }

    /**
     * @notice Get organism energy efficiency
     * @param organism Address of organism
     * @return efficiency Current efficiency percentage
     */
    function getEnergyEfficiency(address organism) external view returns (uint256 efficiency) {
        ResourceStats storage stats = organismResources[organism];

        // Base efficiency is 100%
        efficiency = 100;

        // Bonus for producers (photosynthesis)
        if (stats.trophicLevel == TrophicLevel.PRODUCER) {
            efficiency += 50;
        }

        // Add any organism-specific bonuses
        efficiency += stats.efficiencyBonus;

        return efficiency;
    }

    /**
     * @notice Get trophic pyramid stats
     * @return producers Producer count
     * @return primary Primary consumer count
     * @return secondary Secondary consumer count
     * @return tertiary Tertiary consumer count
     * @return decomposers Decomposer count
     */
    function getTrophicPyramid()
        external
        view
        returns (
            uint256 producers,
            uint256 primary,
            uint256 secondary,
            uint256 tertiary,
            uint256 decomposers
        )
    {
        return (
            trophicPopulation[TrophicLevel.PRODUCER],
            trophicPopulation[TrophicLevel.PRIMARY],
            trophicPopulation[TrophicLevel.SECONDARY],
            trophicPopulation[TrophicLevel.TERTIARY],
            trophicPopulation[TrophicLevel.DECOMPOSER]
        );
    }

    /**
     * @notice Add nutrients to pool
     * @param poolId Pool ID
     * @param amount Amount to add
     */
    function addNutrientsToPool(bytes32 poolId, uint256 amount) external {
        require(nutrientToken.balanceOf(msg.sender) >= amount, "Insufficient nutrients");

        nutrientToken.transferFrom(msg.sender, address(this), amount);
        resourcePools[poolId].nutrients += amount;
    }

    /**
     * @notice Consume resources (metabolism)
     * @param organism Organism consuming
     * @param energyAmount Energy to consume
     * @param nutrientAmount Nutrients to consume
     */
    function consumeResources(
        address organism,
        uint256 energyAmount,
        uint256 nutrientAmount
    ) external {
        ResourceStats storage stats = organismResources[organism];

        require(stats.energyReserve >= energyAmount, "Insufficient energy");
        require(stats.nutrientReserve >= nutrientAmount, "Insufficient nutrients");

        stats.energyReserve -= energyAmount;
        stats.nutrientReserve -= nutrientAmount;
    }

    /**
     * @notice Get pool count
     */
    function getPoolCount() external view returns (uint256) {
        return poolIds.length;
    }

    /**
     * @notice Get organism resource stats
     */
    function getOrganismResources(address organism)
        external
        view
        returns (
            uint256 energy,
            uint256 nutrients,
            TrophicLevel level,
            uint256 consumption,
            uint256 lastFed
        )
    {
        ResourceStats storage stats = organismResources[organism];
        return (
            stats.energyReserve,
            stats.nutrientReserve,
            stats.trophicLevel,
            stats.consumptionRate,
            stats.lastFed
        );
    }
}
