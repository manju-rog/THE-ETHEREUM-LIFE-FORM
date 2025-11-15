// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./ResourceEconomy.sol";

/**
 * @title PredatorPrey
 * @notice Implements hunting, defense, and predator-prey dynamics
 * @dev Food chain interactions with attack/defense calculations
 */
contract PredatorPrey {
    ResourceEconomy public economy;

    /// @notice Hunting strategy
    enum HuntingStrategy {
        AMBUSH,         // High damage, low success rate
        CHASE,          // Medium damage, medium success
        PACK,           // Coordinated group hunting
        STEALTH,        // Surprise attack
        PERSISTENCE     // Wear down prey over time
    }

    /// @notice Defense adaptation
    enum DefenseType {
        CAMOUFLAGE,     // Reduce detection chance
        ARMOR,          // Reduce damage taken
        SPEED,          // Increase escape chance
        TOXICITY,       // Revenge damage
        HERD,           // Group defense bonus
        WARNING,        // Alert nearby organisms
        MIMICRY,        // Impersonate dangerous species
        SIZE            // Intimidation factor
    }

    /// @notice Predator stats
    struct PredatorStats {
        HuntingStrategy strategy;
        uint256 attackPower;
        uint256 huntingSuccess;
        uint256 kills;
        uint256 lastHunt;
        uint256 packSize;
        uint256 territory;
    }

    /// @notice Prey stats
    struct PreyStats {
        DefenseType defense;
        uint256 defensePower;
        uint256 escapes;
        uint256 camouflageLevel;
        uint256 speedBonus;
        uint256 herdSize;
        bool isWarning;
    }

    /// @notice Attack outcome
    struct AttackResult {
        bool success;
        uint256 energyTransferred;
        uint256 damageDealt;
        uint256 revengeActivated;
        bool preyEscaped;
    }

    /// @notice Organism predator stats
    mapping(address => PredatorStats) public predators;

    /// @notice Organism prey stats
    mapping(address => PreyStats) public prey;

    /// @notice Territory ownership
    mapping(uint256 => address) public territoryOwner;

    /// @notice Pack membership
    mapping(address => address[]) public packs;

    /// @notice Hunting cooldown (blocks)
    uint256 public constant HUNT_COOLDOWN = 10;

    /// @notice Events
    event HuntInitiated(
        address indexed predator,
        address indexed prey,
        HuntingStrategy strategy
    );

    event AttackResolved(
        address indexed predator,
        address indexed prey,
        bool success,
        uint256 energyTransferred
    );

    event PreyEscaped(
        address indexed prey,
        address indexed predator,
        DefenseType defenseUsed
    );

    event PackFormed(address indexed leader, address[] members);
    event TerritoryEstablished(address indexed owner, uint256 territoryId);
    event RevengeActivated(address indexed prey, address indexed predator, uint256 damage);

    constructor(address _economy) {
        economy = ResourceEconomy(_economy);
    }

    /**
     * @notice Hunt prey organism
     * @param preyAddress Address of prey
     * @param strategy Hunting strategy to use
     * @return result Attack outcome
     */
    function hunt(address preyAddress, HuntingStrategy strategy)
        external
        returns (AttackResult memory result)
    {
        PredatorStats storage predatorStats = predators[msg.sender];

        require(
            block.number >= predatorStats.lastHunt + HUNT_COOLDOWN,
            "Hunting cooldown"
        );

        // Get organism resources
        (uint256 preyEnergy, uint256 preyNutrients,,,) = economy.getOrganismResources(preyAddress);
        require(preyEnergy > 0, "Prey has no energy");

        // Calculate attack power
        uint256 attackPower = _calculateAttackPower(msg.sender, strategy);

        // Calculate defense power
        uint256 defensePower = _calculateDefensePower(preyAddress);

        // Determine success
        result.success = _resolveAttack(attackPower, defensePower);

        if (result.success) {
            // Energy transfer (90% lost to trophic inefficiency)
            result.energyTransferred = (preyEnergy * 10) / 100;

            // Transfer energy through economy
            economy.transferEnergy(preyAddress, msg.sender, preyEnergy / 2);

            result.damageDealt = preyEnergy / 2;

            // Update stats
            predatorStats.kills++;
            predatorStats.huntingSuccess++;

            // Check for toxicity revenge
            if (prey[preyAddress].defense == DefenseType.TOXICITY) {
                result.revengeActivated = preyEnergy / 10;
                emit RevengeActivated(preyAddress, msg.sender, result.revengeActivated);
            }

            emit AttackResolved(msg.sender, preyAddress, true, result.energyTransferred);
        } else {
            // Prey escaped
            result.preyEscaped = true;
            prey[preyAddress].escapes++;

            emit PreyEscaped(preyAddress, msg.sender, prey[preyAddress].defense);
            emit AttackResolved(msg.sender, preyAddress, false, 0);
        }

        predatorStats.lastHunt = block.number;
        predatorStats.strategy = strategy;

        emit HuntInitiated(msg.sender, preyAddress, strategy);

        return result;
    }

    /**
     * @notice Form a hunting pack
     * @param members Pack members
     */
    function formPack(address[] memory members) external {
        require(members.length >= 2, "Pack needs 2+ members");
        require(members.length <= 10, "Pack too large");

        packs[msg.sender] = members;

        PredatorStats storage stats = predators[msg.sender];
        stats.packSize = members.length;

        // Pack bonus: +10% attack per member
        stats.attackPower += (members.length * 10);

        emit PackFormed(msg.sender, members);
    }

    /**
     * @notice Establish territory
     * @param territoryId Territory identifier
     */
    function establishTerritory(uint256 territoryId) external {
        require(territoryOwner[territoryId] == address(0), "Territory occupied");

        territoryOwner[territoryId] = msg.sender;
        predators[msg.sender].territory = territoryId;

        emit TerritoryEstablished(msg.sender, territoryId);
    }

    /**
     * @notice Set defense adaptation
     * @param defenseType Type of defense to use
     */
    function setDefense(DefenseType defenseType) external {
        PreyStats storage stats = prey[msg.sender];
        stats.defense = defenseType;

        // Set defense power based on type
        if (defenseType == DefenseType.ARMOR) {
            stats.defensePower = 200;
        } else if (defenseType == DefenseType.SPEED) {
            stats.speedBonus = 150;
        } else if (defenseType == DefenseType.CAMOUFLAGE) {
            stats.camouflageLevel = 180;
        } else if (defenseType == DefenseType.TOXICITY) {
            stats.defensePower = 100; // Doesn't prevent attack, but revenge
        } else if (defenseType == DefenseType.SIZE) {
            stats.defensePower = 250;
        } else {
            stats.defensePower = 100;
        }
    }

    /**
     * @notice Join a herd for group defense
     * @param herd Address of herd to join
     */
    function joinHerd(address herd) external {
        PreyStats storage myStats = prey[msg.sender];
        PreyStats storage herdStats = prey[herd];

        herdStats.herdSize++;
        myStats.herdSize = herdStats.herdSize;
        myStats.defense = DefenseType.HERD;

        // Herd bonus: +5% defense per member
        myStats.defensePower = 100 + (herdStats.herdSize * 5);
    }

    /**
     * @notice Activate warning system
     */
    function activateWarning() external {
        prey[msg.sender].isWarning = true;

        // Warning reduces predator success rate in area
        // Would alert nearby organisms in production
    }

    /**
     * @notice Calculate attack power
     * @param predator Predator address
     * @param strategy Hunting strategy
     * @return power Total attack power
     */
    function _calculateAttackPower(address predator, HuntingStrategy strategy)
        private
        view
        returns (uint256 power)
    {
        PredatorStats storage stats = predators[predator];

        // Base power
        power = stats.attackPower > 0 ? stats.attackPower : 100;

        // Strategy modifiers
        if (strategy == HuntingStrategy.AMBUSH) {
            power = (power * 150) / 100; // +50%
        } else if (strategy == HuntingStrategy.PACK) {
            power = (power * (100 + stats.packSize * 10)) / 100;
        } else if (strategy == HuntingStrategy.STEALTH) {
            power = (power * 130) / 100; // +30%
        } else if (strategy == HuntingStrategy.PERSISTENCE) {
            power = (power * 110) / 100; // +10%
        }

        // Territory bonus
        if (stats.territory > 0) {
            power = (power * 120) / 100; // +20% in own territory
        }

        return power;
    }

    /**
     * @notice Calculate defense power
     * @param preyAddress Prey address
     * @return power Total defense power
     */
    function _calculateDefensePower(address preyAddress)
        private
        view
        returns (uint256 power)
    {
        PreyStats storage stats = prey[preyAddress];

        power = stats.defensePower > 0 ? stats.defensePower : 100;

        // Add specific bonuses
        if (stats.defense == DefenseType.SPEED) {
            power += stats.speedBonus;
        } else if (stats.defense == DefenseType.CAMOUFLAGE) {
            power += stats.camouflageLevel;
        } else if (stats.defense == DefenseType.HERD) {
            power += (stats.herdSize * 5);
        }

        // Warning system bonus
        if (stats.isWarning) {
            power = (power * 120) / 100; // +20%
        }

        return power;
    }

    /**
     * @notice Resolve attack vs defense
     * @param attackPower Predator attack power
     * @param defensePower Prey defense power
     * @return success Whether attack succeeded
     */
    function _resolveAttack(uint256 attackPower, uint256 defensePower)
        private
        view
        returns (bool success)
    {
        // Add randomness
        uint256 randomFactor = uint256(
            keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender))
        ) % 100;

        uint256 totalAttack = attackPower + randomFactor;
        uint256 totalDefense = defensePower + (100 - randomFactor);

        return totalAttack > totalDefense;
    }

    /**
     * @notice Get predator stats
     */
    function getPredatorStats(address predator)
        external
        view
        returns (
            HuntingStrategy strategy,
            uint256 attackPower,
            uint256 kills,
            uint256 packSize,
            uint256 territory
        )
    {
        PredatorStats storage stats = predators[predator];
        return (
            stats.strategy,
            stats.attackPower,
            stats.kills,
            stats.packSize,
            stats.territory
        );
    }

    /**
     * @notice Get prey stats
     */
    function getPreyStats(address preyAddress)
        external
        view
        returns (
            DefenseType defense,
            uint256 defensePower,
            uint256 escapes,
            uint256 herdSize,
            bool isWarning
        )
    {
        PreyStats storage stats = prey[preyAddress];
        return (
            stats.defense,
            stats.defensePower,
            stats.escapes,
            stats.herdSize,
            stats.isWarning
        );
    }
}
