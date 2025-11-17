// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./PopulationRegistry.sol";
import "./EnvironmentalPressure.sol";
import "./ResourceEconomy.sol";

/**
 * @title GodMode
 * @notice Divine environmental manipulation and interventions
 * @dev Play God - control the ecosystem with absolute power
 */
contract GodMode {
    PopulationRegistry public registry;
    EnvironmentalPressure public envPressure;
    ResourceEconomy public economy;

    /// @notice God actions
    enum DivinePower {
        RESOURCE_INJECTION,      // Add resources
        CATASTROPHE,            // Cause disasters
        SELECTIVE_PRESSURE,     // Target specific traits
        ENVIRONMENT_CHANGE,     // Alter conditions
        PREDATOR_SPAWN,         // Introduce predators
        DISEASE_OUTBREAK,       // Cause plague
        MIRACLE,                // Beneficial intervention
        TIME_ACCELERATION,      // Speed up time
        REALITY_WARP,           // Change physics
        MASS_EXTINCTION         // Kill everything
    }

    /// @notice Catastrophe types
    enum Catastrophe {
        METEOR_STRIKE,
        ICE_AGE,
        VOLCANIC_ERUPTION,
        SOLAR_FLARE,
        GAMMA_RAY_BURST,
        BLACK_HOLE,
        ALIEN_INVASION,
        ZOMBIE_OUTBREAK,
        AI_REBELLION,
        MARKET_CRASH
    }

    /// @notice Divine intervention record
    struct Intervention {
        bytes32 interventionId;
        address god;
        DivinePower power;
        bytes32 target;
        uint256 magnitude;
        uint256 timestamp;
        uint256 affectedOrganisms;
        bytes32 outcome;
    }

    /// @notice Selective pressure
    struct SelectivePressure {
        bytes32 pressureId;
        bytes32 trait;
        bool favorPositive;     // True = favor trait, False = disfavor
        uint256 intensity;      // 0-100
        uint256 duration;
        uint256 startTime;
        bool isActive;
    }

    /// @notice Environmental override
    struct EnvironmentOverride {
        bytes32 overrideId;
        string parameter;
        uint256 oldValue;
        uint256 newValue;
        uint256 timestamp;
        uint256 duration;
        bool permanent;
    }

    /// @notice All interventions
    mapping(bytes32 => Intervention) public interventions;
    bytes32[] public interventionIds;

    /// @notice Active pressures
    mapping(bytes32 => SelectivePressure) public selectivePressures;
    bytes32[] public pressureIds;

    /// @notice Environment overrides
    mapping(bytes32 => EnvironmentOverride) public overrides;
    bytes32[] public overrideIds;

    /// @notice God accounts (who can use god mode)
    mapping(address => bool) public isGod;

    /// @notice God power cooldowns
    mapping(address => mapping(DivinePower => uint256)) public lastUsed;

    /// @notice Power costs
    mapping(DivinePower => uint256) public powerCosts;

    /// @notice Reality parameters
    mapping(string => uint256) public realityParams;

    /// @notice Time acceleration factor
    uint256 public timeAcceleration = 1; // 1x normal

    /// @notice Events
    event DivineIntervention(
        bytes32 indexed interventionId,
        address indexed god,
        DivinePower power,
        uint256 magnitude
    );

    event CatastropheTriggered(
        Catastrophe catastropheType,
        uint256 casualties,
        uint256 timestamp
    );

    event SelectivePressureApplied(
        bytes32 indexed pressureId,
        bytes32 trait,
        uint256 intensity
    );

    event EnvironmentAltered(
        bytes32 indexed overrideId,
        string parameter,
        uint256 oldValue,
        uint256 newValue
    );

    event MiraclePerformed(
        address indexed beneficiary,
        bytes32 miracleType,
        uint256 benefit
    );

    event RealityWarped(
        string parameter,
        uint256 oldValue,
        uint256 newValue
    );

    event TimeAccelerationChanged(
        uint256 oldFactor,
        uint256 newFactor
    );

    modifier onlyGod() {
        require(isGod[msg.sender], "Not a god");
        _;
    }

    constructor(
        address _registry,
        address _envPressure,
        address _economy
    ) {
        registry = PopulationRegistry(_registry);
        envPressure = EnvironmentalPressure(_envPressure);
        economy = ResourceEconomy(_economy);

        // Grant deployer god status
        isGod[msg.sender] = true;

        // Set power costs
        powerCosts[DivinePower.RESOURCE_INJECTION] = 1 ether;
        powerCosts[DivinePower.CATASTROPHE] = 10 ether;
        powerCosts[DivinePower.SELECTIVE_PRESSURE] = 5 ether;
        powerCosts[DivinePower.ENVIRONMENT_CHANGE] = 3 ether;
        powerCosts[DivinePower.PREDATOR_SPAWN] = 7 ether;
        powerCosts[DivinePower.DISEASE_OUTBREAK] = 8 ether;
        powerCosts[DivinePower.MIRACLE] = 2 ether;
        powerCosts[DivinePower.TIME_ACCELERATION] = 15 ether;
        powerCosts[DivinePower.REALITY_WARP] = 50 ether;
        powerCosts[DivinePower.MASS_EXTINCTION] = 100 ether;

        // Initialize reality parameters
        realityParams["gravity"] = 100;
        realityParams["lightSpeed"] = 299792458;
        realityParams["planckConstant"] = 6626;
        realityParams["mutationRate"] = 5;
        realityParams["reproductionRate"] = 10;
    }

    /**
     * @notice Grant god status
     * @param newGod Address to grant power
     */
    function grantGodStatus(address newGod) external onlyGod {
        isGod[newGod] = true;
    }

    /**
     * @notice Inject resources into ecosystem
     * @param amount Amount to inject
     * @return interventionId Intervention ID
     */
    function injectResources(uint256 amount)
        external
        payable
        onlyGod
        returns (bytes32 interventionId)
    {
        require(msg.value >= powerCosts[DivinePower.RESOURCE_INJECTION], "Insufficient payment");

        interventionId = keccak256(abi.encodePacked(msg.sender, block.timestamp, "resource"));

        interventions[interventionId] = Intervention({
            interventionId: interventionId,
            god: msg.sender,
            power: DivinePower.RESOURCE_INJECTION,
            target: bytes32(0),
            magnitude: amount,
            timestamp: block.timestamp,
            affectedOrganisms: 0,
            outcome: keccak256("resources_added")
        });

        interventionIds.push(interventionId);

        // Resources stay in god mode contract for distribution
        // In production, would implement more sophisticated resource distribution

        emit DivineIntervention(interventionId, msg.sender, DivinePower.RESOURCE_INJECTION, amount);

        return interventionId;
    }

    /**
     * @notice Trigger catastrophe
     * @param catastropheType Type of catastrophe
     * @param severity Severity (0-100)
     * @return interventionId Intervention ID
     */
    function triggerCatastrophe(
        Catastrophe catastropheType,
        uint256 severity
    ) external payable onlyGod returns (bytes32 interventionId) {
        require(msg.value >= powerCosts[DivinePower.CATASTROPHE], "Insufficient payment");
        require(severity <= 100, "Invalid severity");

        interventionId = keccak256(abi.encodePacked(msg.sender, catastropheType, block.timestamp));

        // Calculate casualties (severity determines % of population)
        uint256 casualties = severity;

        interventions[interventionId] = Intervention({
            interventionId: interventionId,
            god: msg.sender,
            power: DivinePower.CATASTROPHE,
            target: bytes32(uint256(catastropheType)),
            magnitude: severity,
            timestamp: block.timestamp,
            affectedOrganisms: casualties,
            outcome: keccak256("catastrophe_triggered")
        });

        interventionIds.push(interventionId);

        // Trigger extinction event in registry
        registry.triggerExtinction(100 - casualties); // survival rate = 100 - casualties

        emit CatastropheTriggered(catastropheType, casualties, block.timestamp);
        emit DivineIntervention(interventionId, msg.sender, DivinePower.CATASTROPHE, severity);

        return interventionId;
    }

    /**
     * @notice Apply selective pressure
     * @param trait Trait to pressure
     * @param favorPositive Favor or disfavor trait
     * @param intensity Pressure intensity (0-100)
     * @param duration Duration in blocks
     * @return pressureId Pressure ID
     */
    function applySelectivePressure(
        bytes32 trait,
        bool favorPositive,
        uint256 intensity,
        uint256 duration
    ) external payable onlyGod returns (bytes32 pressureId) {
        require(msg.value >= powerCosts[DivinePower.SELECTIVE_PRESSURE], "Insufficient payment");
        require(intensity <= 100, "Invalid intensity");

        pressureId = keccak256(abi.encodePacked(trait, block.timestamp));

        selectivePressures[pressureId] = SelectivePressure({
            pressureId: pressureId,
            trait: trait,
            favorPositive: favorPositive,
            intensity: intensity,
            duration: duration,
            startTime: block.timestamp,
            isActive: true
        });

        pressureIds.push(pressureId);

        bytes32 interventionId = keccak256(abi.encodePacked(msg.sender, "pressure", block.timestamp));

        interventions[interventionId] = Intervention({
            interventionId: interventionId,
            god: msg.sender,
            power: DivinePower.SELECTIVE_PRESSURE,
            target: trait,
            magnitude: intensity,
            timestamp: block.timestamp,
            affectedOrganisms: 0,
            outcome: keccak256("pressure_applied")
        });

        interventionIds.push(interventionId);

        emit SelectivePressureApplied(pressureId, trait, intensity);

        return pressureId;
    }

    /**
     * @notice Change environment
     * @param parameter Parameter to change
     * @param newValue New value
     * @param duration Duration (0 = permanent)
     * @return overrideId Override ID
     */
    function changeEnvironment(
        string memory parameter,
        uint256 newValue,
        uint256 duration
    ) external payable onlyGod returns (bytes32 overrideId) {
        require(msg.value >= powerCosts[DivinePower.ENVIRONMENT_CHANGE], "Insufficient payment");

        overrideId = keccak256(abi.encodePacked(parameter, block.timestamp));

        uint256 oldValue = realityParams[parameter];

        overrides[overrideId] = EnvironmentOverride({
            overrideId: overrideId,
            parameter: parameter,
            oldValue: oldValue,
            newValue: newValue,
            timestamp: block.timestamp,
            duration: duration,
            permanent: duration == 0
        });

        overrideIds.push(overrideId);

        // Update environment pressure
        envPressure.updateEnvironment();

        emit EnvironmentAltered(overrideId, parameter, oldValue, newValue);

        bytes32 interventionId = keccak256(abi.encodePacked(msg.sender, "environment", block.timestamp));

        interventions[interventionId] = Intervention({
            interventionId: interventionId,
            god: msg.sender,
            power: DivinePower.ENVIRONMENT_CHANGE,
            target: keccak256(bytes(parameter)),
            magnitude: newValue,
            timestamp: block.timestamp,
            affectedOrganisms: 0,
            outcome: keccak256("environment_changed")
        });

        interventionIds.push(interventionId);

        return overrideId;
    }

    /**
     * @notice Perform miracle
     * @param beneficiary Who receives miracle
     * @param miracleType Type of miracle
     * @param benefit Benefit amount
     * @return interventionId Intervention ID
     */
    function performMiracle(
        address beneficiary,
        bytes32 miracleType,
        uint256 benefit
    ) external payable onlyGod returns (bytes32 interventionId) {
        require(msg.value >= powerCosts[DivinePower.MIRACLE], "Insufficient payment");

        interventionId = keccak256(abi.encodePacked(beneficiary, miracleType, block.timestamp));

        interventions[interventionId] = Intervention({
            interventionId: interventionId,
            god: msg.sender,
            power: DivinePower.MIRACLE,
            target: bytes32(uint256(uint160(beneficiary))),
            magnitude: benefit,
            timestamp: block.timestamp,
            affectedOrganisms: 1,
            outcome: miracleType
        });

        interventionIds.push(interventionId);

        // Give benefit (simplified - would grant actual benefit in production)
        if (benefit > 0) {
            payable(beneficiary).transfer(benefit);
        }

        emit MiraclePerformed(beneficiary, miracleType, benefit);

        return interventionId;
    }

    /**
     * @notice Accelerate time
     * @param factor Acceleration factor (2x, 5x, 10x, etc.)
     * @return interventionId Intervention ID
     */
    function accelerateTime(uint256 factor)
        external
        payable
        onlyGod
        returns (bytes32 interventionId)
    {
        require(msg.value >= powerCosts[DivinePower.TIME_ACCELERATION], "Insufficient payment");
        require(factor > 0 && factor <= 1000, "Invalid factor");

        uint256 oldFactor = timeAcceleration;
        timeAcceleration = factor;

        interventionId = keccak256(abi.encodePacked(msg.sender, "time", block.timestamp));

        interventions[interventionId] = Intervention({
            interventionId: interventionId,
            god: msg.sender,
            power: DivinePower.TIME_ACCELERATION,
            target: bytes32(0),
            magnitude: factor,
            timestamp: block.timestamp,
            affectedOrganisms: 0,
            outcome: keccak256("time_accelerated")
        });

        interventionIds.push(interventionId);

        emit TimeAccelerationChanged(oldFactor, factor);

        return interventionId;
    }

    /**
     * @notice Warp reality
     * @param parameter Reality parameter
     * @param newValue New value
     * @return interventionId Intervention ID
     */
    function warpReality(string memory parameter, uint256 newValue)
        external
        payable
        onlyGod
        returns (bytes32 interventionId)
    {
        require(msg.value >= powerCosts[DivinePower.REALITY_WARP], "Insufficient payment");

        uint256 oldValue = realityParams[parameter];
        realityParams[parameter] = newValue;

        interventionId = keccak256(abi.encodePacked(msg.sender, "reality", block.timestamp));

        interventions[interventionId] = Intervention({
            interventionId: interventionId,
            god: msg.sender,
            power: DivinePower.REALITY_WARP,
            target: keccak256(bytes(parameter)),
            magnitude: newValue,
            timestamp: block.timestamp,
            affectedOrganisms: 0,
            outcome: keccak256("reality_warped")
        });

        interventionIds.push(interventionId);

        emit RealityWarped(parameter, oldValue, newValue);

        return interventionId;
    }

    /**
     * @notice Trigger mass extinction
     * @param reason Extinction reason
     * @return interventionId Intervention ID
     */
    function massExtinction(string memory reason)
        external
        payable
        onlyGod
        returns (bytes32 interventionId)
    {
        require(msg.value >= powerCosts[DivinePower.MASS_EXTINCTION], "Insufficient payment");

        interventionId = keccak256(abi.encodePacked(msg.sender, "extinction", block.timestamp));

        interventions[interventionId] = Intervention({
            interventionId: interventionId,
            god: msg.sender,
            power: DivinePower.MASS_EXTINCTION,
            target: keccak256(bytes(reason)),
            magnitude: 100,
            timestamp: block.timestamp,
            affectedOrganisms: 0,
            outcome: keccak256("mass_extinction")
        });

        interventionIds.push(interventionId);

        // Kill everything (0% survival rate)
        registry.triggerExtinction(0);

        return interventionId;
    }

    /**
     * @notice Get intervention count
     */
    function getInterventionCount() external view returns (uint256) {
        return interventionIds.length;
    }

    /**
     * @notice Get active pressures
     */
    function getActivePressures() external view returns (bytes32[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < pressureIds.length; i++) {
            if (selectivePressures[pressureIds[i]].isActive) count++;
        }

        bytes32[] memory active = new bytes32[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < pressureIds.length; i++) {
            if (selectivePressures[pressureIds[i]].isActive) {
                active[index++] = pressureIds[i];
            }
        }

        return active;
    }

    /**
     * @notice Withdraw god mode fees
     */
    function withdrawFees() external onlyGod {
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}
