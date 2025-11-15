// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./ResourceEconomy.sol";

/**
 * @title Symbiosis
 * @notice Implements cooperative evolution patterns
 * @dev Mutualism, commensalism, parasitism, and collective intelligence
 */
contract Symbiosis {
    ResourceEconomy public economy;

    /// @notice Symbiotic relationship types
    enum SymbiosisType {
        MUTUALISM,      // Both benefit
        COMMENSALISM,   // One benefits, one neutral
        PARASITISM,     // One benefits, one harmed
        AMENSALISM,     // One harmed, one neutral
        COMPETITION     // Both harmed
    }

    /// @notice Collective intelligence type
    enum CollectiveType {
        SWARM,          // Decentralized coordination
        HIVE,           // Centralized queen structure
        COLONY,         // Specialized roles
        NETWORK,        // Information exchange
        SYMBIONT        // Tight integration
    }

    /// @notice Symbiotic relationship
    struct Relationship {
        address partner1;
        address partner2;
        SymbiosisType symbiosisType;
        uint256 partner1Benefit;    // Can be negative for harm
        uint256 partner2Benefit;
        uint256 duration;           // Blocks
        uint256 startBlock;
        bool isActive;
    }

    /// @notice Collective structure
    struct Collective {
        CollectiveType collectiveType;
        address leader;             // Queen/coordinator
        address[] members;
        mapping(address => bool) isMember;
        mapping(address => bytes32) roles;
        uint256 intelligence;       // Collective intelligence level
        uint256 resources;          // Shared resources
        bool isActive;
    }

    /// @notice Protocol cooperation agreement
    struct ProtocolAgreement {
        address[] participants;
        bytes32 agreementHash;
        uint256 totalBenefit;
        uint256 duration;
        mapping(address => uint256) contributions;
        mapping(address => uint256) benefits;
        bool isActive;
    }

    /// @notice All relationships
    mapping(bytes32 => Relationship) public relationships;
    bytes32[] public relationshipIds;

    /// @notice Collective structures
    mapping(bytes32 => Collective) public collectives;
    bytes32[] public collectiveIds;

    /// @notice Protocol agreements
    mapping(bytes32 => ProtocolAgreement) public agreements;

    /// @notice Organism relationships
    mapping(address => bytes32[]) public organismRelationships;

    /// @notice Organism collective membership
    mapping(address => bytes32) public memberOfCollective;

    /// @notice Events
    event RelationshipFormed(
        bytes32 indexed relationshipId,
        address indexed partner1,
        address indexed partner2,
        SymbiosisType symbiosisType
    );

    event MutualBenefit(
        bytes32 indexed relationshipId,
        uint256 partner1Gain,
        uint256 partner2Gain
    );

    event ParasiteAttached(
        address indexed parasite,
        address indexed host,
        uint256 drainRate
    );

    event CollectiveFormed(
        bytes32 indexed collectiveId,
        CollectiveType collectiveType,
        address indexed leader
    );

    event SwarmIntelligence(
        bytes32 indexed collectiveId,
        uint256 intelligenceLevel,
        uint256 memberCount
    );

    event ResourceShared(
        address indexed from,
        address indexed to,
        uint256 amount,
        string reason
    );

    constructor(address _economy) {
        economy = ResourceEconomy(_economy);
    }

    /**
     * @notice Form a mutualistic relationship
     * @param partner Partner organism
     * @param benefit1 Benefit to caller
     * @param benefit2 Benefit to partner
     * @param duration Relationship duration
     * @return relationshipId ID of relationship
     */
    function formMutualism(
        address partner,
        uint256 benefit1,
        uint256 benefit2,
        uint256 duration
    ) external returns (bytes32 relationshipId) {
        relationshipId = keccak256(
            abi.encodePacked(msg.sender, partner, block.timestamp)
        );

        relationships[relationshipId] = Relationship({
            partner1: msg.sender,
            partner2: partner,
            symbiosisType: SymbiosisType.MUTUALISM,
            partner1Benefit: benefit1,
            partner2Benefit: benefit2,
            duration: duration,
            startBlock: block.number,
            isActive: true
        });

        relationshipIds.push(relationshipId);
        organismRelationships[msg.sender].push(relationshipId);
        organismRelationships[partner].push(relationshipId);

        emit RelationshipFormed(relationshipId, msg.sender, partner, SymbiosisType.MUTUALISM);

        return relationshipId;
    }

    /**
     * @notice Form a parasitic relationship
     * @param host Host organism
     * @param drainRate Resource drain rate per block
     * @return relationshipId ID of relationship
     */
    function formParasitism(
        address host,
        uint256 drainRate
    ) external returns (bytes32 relationshipId) {
        // Check if parasite can attach
        (uint256 hostEnergy,,,,) = economy.getOrganismResources(host);
        require(hostEnergy > drainRate * 100, "Host too weak");

        relationshipId = keccak256(
            abi.encodePacked(msg.sender, host, block.timestamp)
        );

        relationships[relationshipId] = Relationship({
            partner1: msg.sender,       // Parasite
            partner2: host,
            symbiosisType: SymbiosisType.PARASITISM,
            partner1Benefit: drainRate,
            partner2Benefit: 0,         // Host gains nothing
            duration: 0,                // Until broken
            startBlock: block.number,
            isActive: true
        });

        relationshipIds.push(relationshipId);

        emit ParasiteAttached(msg.sender, host, drainRate);

        return relationshipId;
    }

    /**
     * @notice Create a collective (hive/swarm/colony)
     * @param collectiveType Type of collective
     * @param name Collective name
     * @return collectiveId ID of collective
     */
    function createCollective(
        CollectiveType collectiveType,
        string memory name
    ) external returns (bytes32 collectiveId) {
        collectiveId = keccak256(abi.encodePacked(name, msg.sender, block.timestamp));

        Collective storage collective = collectives[collectiveId];
        collective.collectiveType = collectiveType;
        collective.leader = msg.sender;
        collective.members.push(msg.sender);
        collective.isMember[msg.sender] = true;
        collective.intelligence = 100; // Base intelligence
        collective.isActive = true;

        collectiveIds.push(collectiveId);
        memberOfCollective[msg.sender] = collectiveId;

        emit CollectiveFormed(collectiveId, collectiveType, msg.sender);

        return collectiveId;
    }

    /**
     * @notice Join a collective
     * @param collectiveId Collective to join
     */
    function joinCollective(bytes32 collectiveId) external {
        Collective storage collective = collectives[collectiveId];
        require(collective.isActive, "Collective inactive");
        require(!collective.isMember[msg.sender], "Already member");

        collective.members.push(msg.sender);
        collective.isMember[msg.sender] = true;
        memberOfCollective[msg.sender] = collectiveId;

        // Increase collective intelligence
        collective.intelligence += 10; // +10 per member

        emit SwarmIntelligence(
            collectiveId,
            collective.intelligence,
            collective.members.length
        );
    }

    /**
     * @notice Assign role in colony
     * @param collectiveId Colony ID
     * @param member Member to assign
     * @param role Role identifier
     */
    function assignRole(
        bytes32 collectiveId,
        address member,
        bytes32 role
    ) external {
        Collective storage collective = collectives[collectiveId];
        require(msg.sender == collective.leader, "Only leader");
        require(collective.isMember[member], "Not a member");

        collective.roles[member] = role;
    }

    /**
     * @notice Share resources with collective
     * @param collectiveId Collective to share with
     * @param amount Amount to share
     */
    function shareResources(bytes32 collectiveId, uint256 amount) external payable {
        Collective storage collective = collectives[collectiveId];
        require(collective.isMember[msg.sender], "Not a member");
        require(msg.value >= amount, "Insufficient value");

        collective.resources += amount;

        emit ResourceShared(msg.sender, collective.leader, amount, "Collective contribution");
    }

    /**
     * @notice Distribute collective resources
     * @param collectiveId Collective ID
     * @param recipient Recipient address
     * @param amount Amount to distribute
     */
    function distributeCollectiveResources(
        bytes32 collectiveId,
        address recipient,
        uint256 amount
    ) external {
        Collective storage collective = collectives[collectiveId];
        require(msg.sender == collective.leader, "Only leader");
        require(collective.resources >= amount, "Insufficient collective resources");

        collective.resources -= amount;
        payable(recipient).transfer(amount);

        emit ResourceShared(collective.leader, recipient, amount, "Collective distribution");
    }

    /**
     * @notice Execute swarm intelligence decision
     * @param collectiveId Collective ID
     * @param decision Decision hash
     * @return votes Vote count
     */
    function swarmDecision(bytes32 collectiveId, bytes32 decision)
        external
        returns (uint256 votes)
    {
        Collective storage collective = collectives[collectiveId];
        require(collective.collectiveType == CollectiveType.SWARM, "Not a swarm");

        // Simplified voting - in production would track individual votes
        votes = collective.members.length;

        // Execute decision if quorum reached (50%)
        if (votes >= collective.members.length / 2) {
            // Decision approved
            collective.intelligence += 5; // Learning from decisions
        }

        return votes;
    }

    /**
     * @notice Process mutual benefits
     * @param relationshipId Relationship to process
     */
    function processMutualBenefits(bytes32 relationshipId) external {
        Relationship storage rel = relationships[relationshipId];
        require(rel.isActive, "Relationship inactive");
        require(rel.symbiosisType == SymbiosisType.MUTUALISM, "Not mutualism");

        // Transfer benefits
        economy.transferEnergy(address(this), rel.partner1, rel.partner1Benefit);
        economy.transferEnergy(address(this), rel.partner2, rel.partner2Benefit);

        emit MutualBenefit(relationshipId, rel.partner1Benefit, rel.partner2Benefit);

        // Check duration
        if (block.number >= rel.startBlock + rel.duration) {
            rel.isActive = false;
        }
    }

    /**
     * @notice Process parasitic drain
     * @param relationshipId Relationship ID
     */
    function processParasiticDrain(bytes32 relationshipId) external {
        Relationship storage rel = relationships[relationshipId];
        require(rel.isActive, "Relationship inactive");
        require(rel.symbiosisType == SymbiosisType.PARASITISM, "Not parasitism");

        // Drain from host to parasite
        economy.transferEnergy(rel.partner2, rel.partner1, rel.partner1Benefit);

        // Host can break free if too weak
        (uint256 hostEnergy,,,,) = economy.getOrganismResources(rel.partner2);
        if (hostEnergy < rel.partner1Benefit * 10) {
            rel.isActive = false; // Host dies or parasite falls off
        }
    }

    /**
     * @notice Create protocol cooperation agreement
     * @param participants Participating organisms
     * @param agreementData Agreement data
     * @return agreementId Agreement ID
     */
    function createProtocolAgreement(
        address[] memory participants,
        bytes memory agreementData
    ) external returns (bytes32 agreementId) {
        require(participants.length >= 2, "Need 2+ participants");

        agreementId = keccak256(abi.encodePacked(agreementData, block.timestamp));

        ProtocolAgreement storage agreement = agreements[agreementId];
        agreement.participants = participants;
        agreement.agreementHash = keccak256(agreementData);
        agreement.isActive = true;

        return agreementId;
    }

    /**
     * @notice Get collective info
     */
    function getCollectiveInfo(bytes32 collectiveId)
        external
        view
        returns (
            CollectiveType collectiveType,
            address leader,
            uint256 memberCount,
            uint256 intelligence,
            uint256 resources
        )
    {
        Collective storage collective = collectives[collectiveId];
        return (
            collective.collectiveType,
            collective.leader,
            collective.members.length,
            collective.intelligence,
            collective.resources
        );
    }

    /**
     * @notice Get relationship info
     */
    function getRelationship(bytes32 relationshipId)
        external
        view
        returns (
            address partner1,
            address partner2,
            SymbiosisType symbiosisType,
            uint256 benefit1,
            uint256 benefit2,
            bool isActive
        )
    {
        Relationship storage rel = relationships[relationshipId];
        return (
            rel.partner1,
            rel.partner2,
            rel.symbiosisType,
            rel.partner1Benefit,
            rel.partner2Benefit,
            rel.isActive
        );
    }

    /**
     * @notice Get organism's relationships
     */
    function getOrganismRelationships(address organism)
        external
        view
        returns (bytes32[] memory)
    {
        return organismRelationships[organism];
    }
}
