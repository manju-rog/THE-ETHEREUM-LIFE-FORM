// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title NutrientToken
 * @notice ERC20 token representing nutrients in the ecosystem
 * @dev Used alongside ETH (energy) for organism survival
 */
contract NutrientToken is ERC20, Ownable {
    /// @notice Nutrient types
    enum NutrientType {
        CARBON,      // Basic building blocks
        NITROGEN,    // Growth enhancement
        PHOSPHORUS,  // Reproduction boost
        MINERALS     // Defense/armor
    }

    /// @notice Nutrient properties per type
    mapping(NutrientType => uint256) public nutrientEfficiency;

    /// @notice Mining difficulty (increases over time)
    uint256 public miningDifficulty;

    /// @notice Last mining block
    mapping(address => uint256) public lastMiningBlock;

    /// @notice Mining cooldown (blocks)
    uint256 public constant MINING_COOLDOWN = 100;

    /// @notice Nutrient decay rate (per 1000 blocks)
    uint256 public constant DECAY_RATE = 50; // 5%

    /// @notice Last decay block
    uint256 public lastDecayBlock;

    /// @notice Seasonal multiplier (0-200, 100 = normal)
    uint256 public seasonalMultiplier;

    /// @notice Season duration (blocks)
    uint256 public constant SEASON_DURATION = 10000;

    /// @notice Events
    event NutrientsMined(address indexed miner, uint256 amount, uint256 difficulty);
    event NutrientsDecayed(address indexed holder, uint256 amount);
    event SeasonChanged(uint256 newMultiplier, string seasonName);
    event NutrientsHarvested(address indexed harvester, uint256 amount);

    constructor() ERC20("Ecosystem Nutrients", "NUT") Ownable(msg.sender) {
        miningDifficulty = 1;
        lastDecayBlock = block.number;
        seasonalMultiplier = 100; // Normal season

        // Set initial nutrient efficiencies
        nutrientEfficiency[NutrientType.CARBON] = 100;
        nutrientEfficiency[NutrientType.NITROGEN] = 150;
        nutrientEfficiency[NutrientType.PHOSPHORUS] = 200;
        nutrientEfficiency[NutrientType.MINERALS] = 125;

        // Mint initial supply to ecosystem (1 million)
        _mint(msg.sender, 1_000_000 * 10**decimals());
    }

    /**
     * @notice Mine nutrients from the environment
     * @return amount Amount of nutrients mined
     */
    function mine() external returns (uint256 amount) {
        require(
            block.number >= lastMiningBlock[msg.sender] + MINING_COOLDOWN,
            "Mining cooldown"
        );

        // Calculate mining reward based on difficulty and randomness
        uint256 randomFactor = uint256(
            keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender))
        ) % 100;

        // Base amount decreases with difficulty
        uint256 baseAmount = 1000 * 10**decimals() / miningDifficulty;

        // Apply seasonal multiplier
        amount = (baseAmount * seasonalMultiplier * randomFactor) / 10000;

        // Increase difficulty
        miningDifficulty += 1;

        lastMiningBlock[msg.sender] = block.number;

        _mint(msg.sender, amount);

        emit NutrientsMined(msg.sender, amount, miningDifficulty);

        return amount;
    }

    /**
     * @notice Harvest nutrients from resource pools
     * @param pool Address of resource pool
     * @return amount Amount harvested
     */
    function harvest(address pool) external returns (uint256 amount) {
        // Resource pool must have balance
        uint256 poolBalance = balanceOf(pool);
        require(poolBalance > 0, "Empty pool");

        // Harvest 10% of pool
        amount = poolBalance / 10;

        _transfer(pool, msg.sender, amount);

        emit NutrientsHarvested(msg.sender, amount);

        return amount;
    }

    /**
     * @notice Apply nutrient decay to an address
     * @param holder Address to apply decay to
     */
    function applyDecay(address holder) external {
        uint256 blocksPassed = block.number - lastDecayBlock;

        if (blocksPassed >= 1000) {
            uint256 balance = balanceOf(holder);
            if (balance > 0) {
                uint256 decayAmount = (balance * DECAY_RATE) / 1000;
                _burn(holder, decayAmount);

                emit NutrientsDecayed(holder, decayAmount);
            }

            lastDecayBlock = block.number;
        }
    }

    /**
     * @notice Update seasonal multiplier
     * @dev Called automatically based on block number
     */
    function updateSeason() external {
        uint256 seasonIndex = (block.number / SEASON_DURATION) % 4;

        string memory seasonName;

        if (seasonIndex == 0) {
            seasonalMultiplier = 150; // Spring - abundance
            seasonName = "SPRING";
        } else if (seasonIndex == 1) {
            seasonalMultiplier = 120; // Summer - growth
            seasonName = "SUMMER";
        } else if (seasonIndex == 2) {
            seasonalMultiplier = 80;  // Autumn - decline
            seasonName = "AUTUMN";
        } else {
            seasonalMultiplier = 50;  // Winter - scarcity
            seasonName = "WINTER";
        }

        emit SeasonChanged(seasonalMultiplier, seasonName);
    }

    /**
     * @notice Get current season
     * @return seasonName Name of current season
     * @return multiplier Current multiplier
     */
    function getCurrentSeason() external view returns (string memory seasonName, uint256 multiplier) {
        uint256 seasonIndex = (block.number / SEASON_DURATION) % 4;

        if (seasonIndex == 0) {
            return ("SPRING", 150);
        } else if (seasonIndex == 1) {
            return ("SUMMER", 120);
        } else if (seasonIndex == 2) {
            return ("AUTUMN", 80);
        } else {
            return ("WINTER", 50);
        }
    }

    /**
     * @notice Create resource pool
     * @param amount Amount of nutrients for pool
     * @return poolAddress Address of created pool
     */
    function createResourcePool(uint256 amount) external returns (address poolAddress) {
        require(balanceOf(msg.sender) >= amount, "Insufficient nutrients");

        // Create deterministic address for pool
        poolAddress = address(
            uint160(
                uint256(keccak256(abi.encodePacked(msg.sender, block.timestamp)))
            )
        );

        _transfer(msg.sender, poolAddress, amount);

        return poolAddress;
    }

    /**
     * @notice Burn nutrients (consumption)
     * @param amount Amount to burn
     */
    function consume(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    /**
     * @notice Get nutrient efficiency for type
     * @param nutrientType Type of nutrient
     * @return efficiency Efficiency multiplier
     */
    function getNutrientEfficiency(NutrientType nutrientType) external view returns (uint256 efficiency) {
        return nutrientEfficiency[nutrientType];
    }
}
