// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title CollectiveIntelligence
 * @notice Swarm behaviors, consensus formation, and collective consciousness
 * @dev Voting, distributed processing, emergent goals, hive minds
 */
contract CollectiveIntelligence {
    /// @notice Collective types
    enum CollectiveType {
        SWARM,          // Decentralized coordination
        HIVE,           // Centralized queen structure
        COLONY,         // Specialized roles
        NETWORK,        // Information exchange
        DEMOCRACY,      // Equal voting
        OLIGARCHY,      // Leader-based
        CONSENSUS       // Agreement required
    }

    /// @notice Decision types
    enum DecisionType {
        RESOURCE_ALLOCATION,
        TERRITORY_CLAIM,
        HUNTING_TARGET,
        DEFENSE_STRATEGY,
        MIGRATION_PATH,
        ALLIANCE_FORMATION,
        CONFLICT_RESOLUTION,
        GOAL_SETTING,
        KNOWLEDGE_SHARING,
        EVOLUTIONARY_PRESSURE
    }

    /// @notice Vote types
    enum VoteType {
        SIMPLE_MAJORITY,    // >50%
        SUPERMAJORITY,      // >66%
        UNANIMOUS,          // 100%
        WEIGHTED,           // By fitness/age
        QUADRATIC,          // Sqrt of stake
        RANKED_CHOICE       // Preference ranking
    }

    /// @notice Collective structure
    struct Collective {
        bytes32 collectiveId;
        CollectiveType collectiveType;
        address[] members;
        address leader;             // For hierarchical types
        uint256 totalIntelligence;  // Sum of member intelligence
        uint256 cohesion;           // 0-100 group unity
        uint256 formationBlock;
        mapping(bytes32 => uint256) collectiveMemory;
        bool isActive;
    }

    /// @notice Voting proposal
    struct Proposal {
        bytes32 proposalId;
        bytes32 collectiveId;
        DecisionType decisionType;
        VoteType voteType;
        bytes32 proposalData;
        address proposer;
        uint256 startBlock;
        uint256 endBlock;
        mapping(address => Vote) votes;
        address[] voters;
        uint256 yesWeight;
        uint256 noWeight;
        bool executed;
        bool passed;
    }

    /// @notice Individual vote
    struct Vote {
        bool support;           // Yes/no
        uint256 weight;         // Voting power
        uint256 preference;     // For ranked choice
        bytes32 reasoning;      // Why they voted this way
        uint256 timestamp;
    }

    /// @notice Consensus state
    struct ConsensusState {
        bytes32 consensusId;
        bytes32 topic;
        uint256 convergence;    // 0-100 agreement level
        uint256 iterations;     // Rounds of discussion
        bytes32 currentConsensus;
        mapping(address => bytes32) positions;
        address[] participants;
        bool hasConverged;
    }

    /// @notice Swarm behavior
    struct SwarmBehavior {
        bytes32 behaviorId;
        string behaviorName;
        address[] participants;
        bytes32 goal;
        uint256 coordination;   // 0-100 how coordinated
        uint256 efficiency;     // Task completion rate
        uint256 emergenceLevel; // Complexity of behavior
        bool isEmergent;        // Not explicitly programmed
    }

    /// @notice Distributed task
    struct DistributedTask {
        bytes32 taskId;
        bytes32 collectiveId;
        bytes32 taskData;
        mapping(address => bytes32) assignments;
        address[] workers;
        uint256 completion;     // 0-100 percent done
        uint256 startBlock;
        uint256 deadline;
        bool isComplete;
    }

    /// @notice Emergent goal
    struct EmergentGoal {
        bytes32 goalId;
        bytes32 description;
        uint256 priority;       // 0-100
        uint256 complexity;
        address[] contributors;
        uint256 progress;       // 0-100
        bool wasPlanned;        // False if emergent
        uint256 emergenceBlock;
    }

    /// @notice All collectives
    mapping(bytes32 => Collective) public collectives;
    bytes32[] public collectiveIds;

    /// @notice All proposals
    mapping(bytes32 => Proposal) public proposals;
    bytes32[] public proposalIds;

    /// @notice All consensus processes
    mapping(bytes32 => ConsensusState) public consensusStates;
    bytes32[] public consensusIds;

    /// @notice Swarm behaviors
    mapping(bytes32 => SwarmBehavior) public swarmBehaviors;
    bytes32[] public behaviorIds;

    /// @notice Distributed tasks
    mapping(bytes32 => DistributedTask) public tasks;
    bytes32[] public taskIds;

    /// @notice Emergent goals
    mapping(bytes32 => EmergentGoal) public emergentGoals;
    bytes32[] public goalIds;

    /// @notice Member collectives
    mapping(address => bytes32[]) public memberOf;

    /// @notice Collective consciousness level
    mapping(bytes32 => uint256) public collectiveConsciousness;

    /// @notice Global brain connections
    mapping(address => mapping(address => uint256)) public brainConnections;

    /// @notice Events
    event CollectiveFormed(
        bytes32 indexed collectiveId,
        CollectiveType collectiveType,
        uint256 memberCount
    );

    event ProposalCreated(
        bytes32 indexed proposalId,
        bytes32 indexed collectiveId,
        DecisionType decisionType,
        address proposer
    );

    event VoteCast(
        bytes32 indexed proposalId,
        address indexed voter,
        bool support,
        uint256 weight
    );

    event ConsensusReached(
        bytes32 indexed consensusId,
        bytes32 result,
        uint256 convergence,
        uint256 iterations
    );

    event SwarmBehaviorEmergent(
        bytes32 indexed behaviorId,
        string behaviorName,
        uint256 participantCount,
        uint256 emergenceLevel
    );

    event CollectiveConsciousnessEvolved(
        bytes32 indexed collectiveId,
        uint256 consciousnessLevel,
        uint256 memberCount
    );

    event EmergentGoalDetected(
        bytes32 indexed goalId,
        bytes32 description,
        uint256 complexity,
        bool wasPlanned
    );

    event DistributedTaskCompleted(
        bytes32 indexed taskId,
        uint256 workerCount,
        uint256 efficiency
    );

    event HiveMindDecision(
        bytes32 indexed collectiveId,
        address indexed leader,
        bytes32 decision
    );

    event GlobalBrainConnection(
        address indexed organism1,
        address indexed organism2,
        uint256 connectionStrength
    );

    /**
     * @notice Form a new collective
     * @param collectiveType Type of collective
     * @param initialMembers Initial member list
     * @param leader Leader for hierarchical types
     * @return collectiveId Collective ID
     */
    function formCollective(
        CollectiveType collectiveType,
        address[] memory initialMembers,
        address leader
    ) external returns (bytes32 collectiveId) {
        require(initialMembers.length >= 2, "Need 2+ members");

        collectiveId = keccak256(
            abi.encodePacked(initialMembers, collectiveType, block.timestamp)
        );

        Collective storage collective = collectives[collectiveId];
        collective.collectiveId = collectiveId;
        collective.collectiveType = collectiveType;
        collective.members = initialMembers;
        collective.leader = leader;
        collective.totalIntelligence = initialMembers.length * 100; // Simplified
        collective.cohesion = 50; // Start at medium cohesion
        collective.formationBlock = block.number;
        collective.isActive = true;

        collectiveIds.push(collectiveId);

        // Add to member tracking
        for (uint256 i = 0; i < initialMembers.length; i++) {
            memberOf[initialMembers[i]].push(collectiveId);
        }

        emit CollectiveFormed(collectiveId, collectiveType, initialMembers.length);

        return collectiveId;
    }

    /**
     * @notice Create a proposal for collective decision
     * @param collectiveId Collective making decision
     * @param decisionType Type of decision
     * @param voteType Voting mechanism
     * @param proposalData Proposal details
     * @param duration Voting period in blocks
     * @return proposalId Proposal ID
     */
    function createProposal(
        bytes32 collectiveId,
        DecisionType decisionType,
        VoteType voteType,
        bytes32 proposalData,
        uint256 duration
    ) external returns (bytes32 proposalId) {
        require(collectives[collectiveId].isActive, "Collective not active");

        proposalId = keccak256(
            abi.encodePacked(collectiveId, proposalData, block.timestamp)
        );

        Proposal storage proposal = proposals[proposalId];
        proposal.proposalId = proposalId;
        proposal.collectiveId = collectiveId;
        proposal.decisionType = decisionType;
        proposal.voteType = voteType;
        proposal.proposalData = proposalData;
        proposal.proposer = msg.sender;
        proposal.startBlock = block.number;
        proposal.endBlock = block.number + duration;
        proposal.executed = false;
        proposal.passed = false;

        proposalIds.push(proposalId);

        emit ProposalCreated(proposalId, collectiveId, decisionType, msg.sender);

        return proposalId;
    }

    /**
     * @notice Cast vote on proposal
     * @param proposalId Proposal to vote on
     * @param support Yes or no
     * @param reasoning Why voting this way
     */
    function vote(
        bytes32 proposalId,
        bool support,
        bytes32 reasoning
    ) external {
        Proposal storage proposal = proposals[proposalId];
        require(block.number <= proposal.endBlock, "Voting ended");
        require(proposal.votes[msg.sender].timestamp == 0, "Already voted");

        // Check membership
        Collective storage collective = collectives[proposal.collectiveId];
        bool isMember = false;
        for (uint256 i = 0; i < collective.members.length; i++) {
            if (collective.members[i] == msg.sender) {
                isMember = true;
                break;
            }
        }
        require(isMember, "Not a member");

        // Calculate vote weight based on vote type
        uint256 weight = _calculateVoteWeight(
            proposal.voteType,
            msg.sender,
            proposal.collectiveId
        );

        proposal.votes[msg.sender] = Vote({
            support: support,
            weight: weight,
            preference: 0,
            reasoning: reasoning,
            timestamp: block.timestamp
        });

        proposal.voters.push(msg.sender);

        if (support) {
            proposal.yesWeight += weight;
        } else {
            proposal.noWeight += weight;
        }

        emit VoteCast(proposalId, msg.sender, support, weight);
    }

    /**
     * @notice Execute proposal after voting ends
     * @param proposalId Proposal to execute
     */
    function executeProposal(bytes32 proposalId) external {
        Proposal storage proposal = proposals[proposalId];
        require(block.number > proposal.endBlock, "Voting still active");
        require(!proposal.executed, "Already executed");

        // Check if passed based on vote type
        bool passed = _checkProposalPassed(proposalId);
        proposal.passed = passed;
        proposal.executed = true;

        // If passed, increase cohesion; if failed, decrease
        Collective storage collective = collectives[proposal.collectiveId];
        if (passed) {
            collective.cohesion = collective.cohesion + 5;
            if (collective.cohesion > 100) collective.cohesion = 100;
        } else {
            if (collective.cohesion > 5) collective.cohesion -= 5;
        }
    }

    /**
     * @notice Start consensus formation process
     * @param collectiveId Collective seeking consensus
     * @param topic Topic to reach consensus on
     * @return consensusId Consensus process ID
     */
    function startConsensus(bytes32 collectiveId, bytes32 topic)
        external
        returns (bytes32 consensusId)
    {
        require(collectives[collectiveId].isActive, "Collective not active");

        consensusId = keccak256(abi.encodePacked(collectiveId, topic, block.timestamp));

        ConsensusState storage state = consensusStates[consensusId];
        state.consensusId = consensusId;
        state.topic = topic;
        state.convergence = 0;
        state.iterations = 0;
        state.currentConsensus = bytes32(0);
        state.participants = collectives[collectiveId].members;
        state.hasConverged = false;

        consensusIds.push(consensusId);

        return consensusId;
    }

    /**
     * @notice Submit position for consensus
     * @param consensusId Consensus process
     * @param position Your position on topic
     */
    function submitPosition(bytes32 consensusId, bytes32 position) external {
        ConsensusState storage state = consensusStates[consensusId];
        require(!state.hasConverged, "Already converged");

        state.positions[msg.sender] = position;
        state.iterations++;

        // Check convergence
        _checkConsensusConvergence(consensusId);
    }

    /**
     * @notice Create emergent swarm behavior
     * @param behaviorName Behavior description
     * @param participants Participating organisms
     * @param goal Behavior goal
     * @return behaviorId Behavior ID
     */
    function createSwarmBehavior(
        string memory behaviorName,
        address[] memory participants,
        bytes32 goal
    ) external returns (bytes32 behaviorId) {
        require(participants.length >= 3, "Need 3+ for swarm");

        behaviorId = keccak256(abi.encodePacked(behaviorName, goal, block.timestamp));

        SwarmBehavior storage behavior = swarmBehaviors[behaviorId];
        behavior.behaviorId = behaviorId;
        behavior.behaviorName = behaviorName;
        behavior.participants = participants;
        behavior.goal = goal;
        behavior.coordination = 50; // Start medium
        behavior.efficiency = 0;
        behavior.emergenceLevel = participants.length * 10; // More complex with more participants
        behavior.isEmergent = true;

        behaviorIds.push(behaviorId);

        emit SwarmBehaviorEmergent(
            behaviorId,
            behaviorName,
            participants.length,
            behavior.emergenceLevel
        );

        return behaviorId;
    }

    /**
     * @notice Create distributed task
     * @param collectiveId Collective performing task
     * @param taskData Task details
     * @param workers Assigned workers
     * @param deadline Completion deadline
     * @return taskId Task ID
     */
    function createDistributedTask(
        bytes32 collectiveId,
        bytes32 taskData,
        address[] memory workers,
        uint256 deadline
    ) external returns (bytes32 taskId) {
        require(collectives[collectiveId].isActive, "Collective not active");

        taskId = keccak256(abi.encodePacked(collectiveId, taskData, block.timestamp));

        DistributedTask storage task = tasks[taskId];
        task.taskId = taskId;
        task.collectiveId = collectiveId;
        task.taskData = taskData;
        task.workers = workers;
        task.completion = 0;
        task.startBlock = block.number;
        task.deadline = deadline;
        task.isComplete = false;

        taskIds.push(taskId);

        return taskId;
    }

    /**
     * @notice Report task progress
     * @param taskId Task to update
     * @param workerProgress Worker's progress (0-100)
     */
    function reportTaskProgress(bytes32 taskId, uint256 workerProgress) external {
        DistributedTask storage task = tasks[taskId];
        require(!task.isComplete, "Task complete");

        // Simplified: average all worker progress
        task.completion = (task.completion + workerProgress) / 2;

        if (task.completion >= 100) {
            task.isComplete = true;

            // Calculate efficiency
            uint256 timeUsed = block.number - task.startBlock;
            uint256 timeAllowed = task.deadline - task.startBlock;
            uint256 efficiency = timeAllowed > 0 ? (timeAllowed * 100) / timeUsed : 100;

            emit DistributedTaskCompleted(taskId, task.workers.length, efficiency);
        }
    }

    /**
     * @notice Detect emergent goal
     * @param description Goal description
     * @param contributors Who's working on it
     * @param wasPlanned Was this goal planned or emergent?
     * @return goalId Goal ID
     */
    function detectEmergentGoal(
        bytes32 description,
        address[] memory contributors,
        bool wasPlanned
    ) external returns (bytes32 goalId) {
        goalId = keccak256(abi.encodePacked(description, block.timestamp));

        EmergentGoal storage goal = emergentGoals[goalId];
        goal.goalId = goalId;
        goal.description = description;
        goal.priority = wasPlanned ? 50 : 70; // Emergent goals higher priority
        goal.complexity = contributors.length * 15;
        goal.contributors = contributors;
        goal.progress = 0;
        goal.wasPlanned = wasPlanned;
        goal.emergenceBlock = block.number;

        goalIds.push(goalId);

        emit EmergentGoalDetected(goalId, description, goal.complexity, wasPlanned);

        return goalId;
    }

    /**
     * @notice Calculate collective consciousness level
     * @param collectiveId Collective to measure
     * @return consciousness Consciousness level (0-1000)
     */
    function calculateCollectiveConsciousness(bytes32 collectiveId)
        external
        returns (uint256 consciousness)
    {
        Collective storage collective = collectives[collectiveId];

        // Consciousness based on:
        // - Number of members (network effect)
        // - Total intelligence
        // - Cohesion (how unified)
        // - Number of connections between members

        uint256 networkEffect = collective.members.length * collective.members.length;
        uint256 cohesionBonus = collective.cohesion * 5;
        uint256 intelligenceBonus = collective.totalIntelligence / 10;

        consciousness = networkEffect + cohesionBonus + intelligenceBonus;

        // Cap at 1000
        if (consciousness > 1000) consciousness = 1000;

        collectiveConsciousness[collectiveId] = consciousness;

        emit CollectiveConsciousnessEvolved(
            collectiveId,
            consciousness,
            collective.members.length
        );

        return consciousness;
    }

    /**
     * @notice Connect two organism brains (global brain)
     * @param organism1 First organism
     * @param organism2 Second organism
     * @param strength Connection strength
     */
    function connectBrains(
        address organism1,
        address organism2,
        uint256 strength
    ) external {
        require(organism1 != organism2, "Cannot connect to self");

        brainConnections[organism1][organism2] = strength;
        brainConnections[organism2][organism1] = strength;

        emit GlobalBrainConnection(organism1, organism2, strength);
    }

    /**
     * @notice Hive mind decision (leader decides for all)
     * @param collectiveId Hive collective
     * @param decision Decision to make
     */
    function hiveMindDecision(bytes32 collectiveId, bytes32 decision) external {
        Collective storage collective = collectives[collectiveId];
        require(collective.collectiveType == CollectiveType.HIVE, "Not a hive");
        require(msg.sender == collective.leader, "Not the leader");

        // Store decision in collective memory
        collective.collectiveMemory[keccak256("latest_decision")] = uint256(decision);

        emit HiveMindDecision(collectiveId, msg.sender, decision);
    }

    /**
     * @notice Calculate vote weight based on vote type
     */
    function _calculateVoteWeight(
        VoteType voteType,
        address voter,
        bytes32 collectiveId
    ) private view returns (uint256) {
        Collective storage collective = collectives[collectiveId];

        if (voteType == VoteType.SIMPLE_MAJORITY || voteType == VoteType.SUPERMAJORITY) {
            return 1; // One vote per member
        } else if (voteType == VoteType.WEIGHTED) {
            // Weight by position in members array (age proxy)
            for (uint256 i = 0; i < collective.members.length; i++) {
                if (collective.members[i] == voter) {
                    return i + 1; // Earlier members have more weight
                }
            }
            return 1;
        } else if (voteType == VoteType.QUADRATIC) {
            // Quadratic voting - sqrt of position
            for (uint256 i = 0; i < collective.members.length; i++) {
                if (collective.members[i] == voter) {
                    return _sqrt(i + 1);
                }
            }
            return 1;
        }

        return 1;
    }

    /**
     * @notice Check if proposal passed
     */
    function _checkProposalPassed(bytes32 proposalId) private view returns (bool) {
        Proposal storage proposal = proposals[proposalId];
        uint256 totalVotes = proposal.yesWeight + proposal.noWeight;

        if (totalVotes == 0) return false;

        uint256 yesPercentage = (proposal.yesWeight * 100) / totalVotes;

        if (proposal.voteType == VoteType.SIMPLE_MAJORITY) {
            return yesPercentage > 50;
        } else if (proposal.voteType == VoteType.SUPERMAJORITY) {
            return yesPercentage > 66;
        } else if (proposal.voteType == VoteType.UNANIMOUS) {
            return yesPercentage == 100;
        }

        return yesPercentage > 50; // Default
    }

    /**
     * @notice Check if consensus has converged
     */
    function _checkConsensusConvergence(bytes32 consensusId) private {
        ConsensusState storage state = consensusStates[consensusId];

        // Simplified: check if >80% agree
        uint256 totalParticipants = state.participants.length;
        uint256 agreedCount = 0;

        // In production would properly count positions
        // Simplified here for gas efficiency
        agreedCount = totalParticipants * 85 / 100; // Assume 85% convergence

        state.convergence = (agreedCount * 100) / totalParticipants;

        if (state.convergence >= 80) {
            state.hasConverged = true;
            state.currentConsensus = keccak256(abi.encodePacked("consensus_reached"));

            emit ConsensusReached(consensusId, state.currentConsensus, state.convergence, state.iterations);
        }
    }

    /**
     * @notice Square root (integer approximation)
     */
    function _sqrt(uint256 x) private pure returns (uint256) {
        if (x == 0) return 0;
        uint256 z = (x + 1) / 2;
        uint256 y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
        return y;
    }

    /**
     * @notice Get collective info
     */
    function getCollectiveInfo(bytes32 collectiveId)
        external
        view
        returns (
            CollectiveType collectiveType,
            uint256 memberCount,
            address leader,
            uint256 totalIntelligence,
            uint256 cohesion,
            bool isActive
        )
    {
        Collective storage collective = collectives[collectiveId];
        return (
            collective.collectiveType,
            collective.members.length,
            collective.leader,
            collective.totalIntelligence,
            collective.cohesion,
            collective.isActive
        );
    }

    /**
     * @notice Get proposal results
     */
    function getProposalResults(bytes32 proposalId)
        external
        view
        returns (
            uint256 yesWeight,
            uint256 noWeight,
            uint256 voterCount,
            bool executed,
            bool passed
        )
    {
        Proposal storage proposal = proposals[proposalId];
        return (
            proposal.yesWeight,
            proposal.noWeight,
            proposal.voters.length,
            proposal.executed,
            proposal.passed
        );
    }

    /**
     * @notice Get swarm behavior stats
     */
    function getSwarmBehavior(bytes32 behaviorId)
        external
        view
        returns (
            string memory behaviorName,
            uint256 participantCount,
            uint256 coordination,
            uint256 emergenceLevel,
            bool isEmergent
        )
    {
        SwarmBehavior storage behavior = swarmBehaviors[behaviorId];
        return (
            behavior.behaviorName,
            behavior.participants.length,
            behavior.coordination,
            behavior.emergenceLevel,
            behavior.isEmergent
        );
    }

    /**
     * @notice Get collective count
     */
    function getCollectiveCount() external view returns (uint256) {
        return collectiveIds.length;
    }

    /**
     * @notice Get proposal count
     */
    function getProposalCount() external view returns (uint256) {
        return proposalIds.length;
    }
}
