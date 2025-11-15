// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title BehaviorDetector
 * @notice Detects and tracks complex behavioral patterns in organisms
 * @dev Tool use, problem solving, learning, memory, social structures
 */
contract BehaviorDetector {
    /// @notice Behavior types
    enum BehaviorType {
        TOOL_USE,           // Using resources as tools
        PROBLEM_SOLVING,    // Novel solutions to challenges
        SOCIAL_LEARNING,    // Learning from others
        INNOVATION,         // Creating new behaviors
        COOPERATION,        // Working together
        DECEPTION,          // Strategic misinformation
        ALTRUISM,           // Self-sacrifice for others
        TEACHING,           // Instructing others
        PLANNING,           // Future-oriented actions
        CULTURE             // Shared learned behaviors
    }

    /// @notice Learning types
    enum LearningType {
        TRIAL_AND_ERROR,    // Random exploration
        OBSERVATION,        // Watch and copy
        INSTRUCTION,        // Direct teaching
        INSIGHT,            // Sudden understanding
        HABITUATION,        // Desensitization
        CONDITIONING,       // Stimulus-response
        IMITATION,          // Copy others
        INNOVATION          // Create new solutions
    }

    /// @notice Behavior instance
    struct Behavior {
        bytes32 behaviorId;
        address organism;
        BehaviorType behaviorType;
        bytes32 context;        // What was happening
        bytes32 action;         // What they did
        bytes32 outcome;        // What resulted
        uint256 complexity;     // 0-100
        uint256 novelty;        // How original (0-100)
        uint256 timestamp;
        bool wasSuccessful;
        bool wasLearned;        // Vs innate
    }

    /// @notice Tool usage record
    struct ToolUse {
        bytes32 toolUseId;
        address organism;
        bytes32 tool;           // Resource used as tool
        bytes32 purpose;        // What it's for
        uint256 efficiency;     // How well it worked
        uint256 firstUse;       // When first used
        uint256 useCount;       // Times used
        bool isNovel;           // First in population
    }

    /// @notice Problem solving instance
    struct ProblemSolving {
        bytes32 problemId;
        bytes32 problem;        // Problem description
        address solver;
        bytes32 solution;       // Solution found
        uint256 attemptsNeeded; // How many tries
        uint256 timeToSolve;    // Blocks needed
        uint256 creativityScore; // How novel
        LearningType learningType;
        bool isOptimal;         // Best solution
    }

    /// @notice Learning progress
    struct LearningCurve {
        address organism;
        bytes32 skillId;
        uint256[] performance;  // Performance over time
        uint256 initialPerformance;
        uint256 currentPerformance;
        uint256 learningRate;   // How fast improving
        uint256 plateau;        // Performance ceiling
        uint256 practiceCount;
    }

    /// @notice Memory instance
    struct Memory {
        bytes32 memoryId;
        address organism;
        bytes32 experience;
        uint256 strength;       // 0-100 recall ability
        uint256 emotionalWeight; // Importance
        uint256 formationBlock;
        uint256 lastRecall;
        uint256 recallCount;
        bool isLongTerm;
    }

    /// @notice Social structure
    struct SocialStructure {
        bytes32 structureId;
        string structureName;
        address[] members;
        mapping(address => bytes32) roles;
        mapping(address => uint256) rank;
        uint256 hierarchy;      // How hierarchical (0-100)
        uint256 stability;      // How stable
        uint256 formationBlock;
    }

    /// @notice Cultural trait
    struct CulturalTrait {
        bytes32 traitId;
        bytes32 traitName;
        address originator;     // Who started it
        address[] practitioners; // Who practices it
        uint256 transmission;   // Spread rate
        uint256 fidelity;       // How accurately copied
        uint256 longevity;      // How long lasting
        uint256 emergenceBlock;
        bool isWidespread;
    }

    /// @notice Innovation record
    struct Innovation {
        bytes32 innovationId;
        address innovator;
        bytes32 innovation;
        uint256 impact;         // Effect on fitness
        uint256 adoptionRate;   // How fast spreading
        address[] adopters;
        uint256 creationBlock;
        bool isMeme;            // Cultural transmission
    }

    /// @notice Teaching event
    struct TeachingEvent {
        bytes32 eventId;
        address teacher;
        address student;
        bytes32 knowledge;
        uint256 effectiveness;  // Student improvement
        uint256 patience;       // Teaching quality
        uint256 timestamp;
        bool wasSuccessful;
    }

    /// @notice All behaviors
    mapping(bytes32 => Behavior) public behaviors;
    bytes32[] public behaviorIds;

    /// @notice Tool usage tracking
    mapping(bytes32 => ToolUse) public toolUses;
    bytes32[] public toolUseIds;

    /// @notice Problem solving records
    mapping(bytes32 => ProblemSolving) public problemSolving;
    bytes32[] public problemIds;

    /// @notice Learning curves
    mapping(address => mapping(bytes32 => LearningCurve)) public learningCurves;

    /// @notice Memories
    mapping(bytes32 => Memory) public memories;
    bytes32[] public memoryIds;

    /// @notice Social structures
    mapping(bytes32 => SocialStructure) public socialStructures;
    bytes32[] public structureIds;

    /// @notice Cultural traits
    mapping(bytes32 => CulturalTrait) public culturalTraits;
    bytes32[] public traitIds;

    /// @notice Innovations
    mapping(bytes32 => Innovation) public innovations;
    bytes32[] public innovationIds;

    /// @notice Teaching events
    mapping(bytes32 => TeachingEvent) public teachingEvents;
    bytes32[] public teachingIds;

    /// @notice Organism behavior count
    mapping(address => uint256) public behaviorCount;

    /// @notice Organism intelligence estimate
    mapping(address => uint256) public estimatedIntelligence;

    /// @notice Skill proficiency
    mapping(address => mapping(bytes32 => uint256)) public skillProficiency;

    /// @notice Events
    event BehaviorDetected(
        address indexed organism,
        BehaviorType behaviorType,
        uint256 complexity,
        uint256 novelty
    );

    event ToolUseObserved(
        address indexed organism,
        bytes32 indexed tool,
        bytes32 purpose,
        bool isNovel
    );

    event ProblemSolved(
        address indexed solver,
        bytes32 indexed problem,
        uint256 attemptsNeeded,
        uint256 creativityScore
    );

    event LearningProgress(
        address indexed organism,
        bytes32 indexed skill,
        uint256 performance,
        uint256 learningRate
    );

    event MemoryFormed(
        address indexed organism,
        bytes32 indexed memoryId,
        uint256 strength,
        bool isLongTerm
    );

    event SocialStructureFormed(
        bytes32 indexed structureId,
        string structureName,
        uint256 memberCount
    );

    event CultureEmerged(
        bytes32 indexed traitId,
        bytes32 traitName,
        address originator,
        uint256 practitioners
    );

    event InnovationCreated(
        address indexed innovator,
        bytes32 innovation,
        uint256 impact
    );

    event KnowledgeTransferred(
        address indexed teacher,
        address indexed student,
        bytes32 knowledge,
        bool successful
    );

    event IntelligenceEvolved(
        address indexed organism,
        uint256 newIntelligence,
        uint256 behaviorCount
    );

    /**
     * @notice Record a behavior
     * @param organism Organism performing behavior
     * @param behaviorType Type of behavior
     * @param context What was happening
     * @param action What they did
     * @param outcome Result
     * @param complexity Behavior complexity (0-100)
     * @param novelty How original (0-100)
     * @return behaviorId Behavior ID
     */
    function recordBehavior(
        address organism,
        BehaviorType behaviorType,
        bytes32 context,
        bytes32 action,
        bytes32 outcome,
        uint256 complexity,
        uint256 novelty,
        bool wasSuccessful
    ) external returns (bytes32 behaviorId) {
        behaviorId = keccak256(
            abi.encodePacked(organism, action, block.timestamp)
        );

        behaviors[behaviorId] = Behavior({
            behaviorId: behaviorId,
            organism: organism,
            behaviorType: behaviorType,
            context: context,
            action: action,
            outcome: outcome,
            complexity: complexity,
            novelty: novelty,
            timestamp: block.timestamp,
            wasSuccessful: wasSuccessful,
            wasLearned: true // Assume learned unless specified
        });

        behaviorIds.push(behaviorId);
        behaviorCount[organism]++;

        // Update intelligence estimate
        _updateIntelligence(organism, complexity, novelty);

        emit BehaviorDetected(organism, behaviorType, complexity, novelty);

        return behaviorId;
    }

    /**
     * @notice Record tool use
     * @param organism Organism using tool
     * @param tool Resource used as tool
     * @param purpose What it's for
     * @param efficiency How well it worked (0-100)
     * @return toolUseId Tool use ID
     */
    function recordToolUse(
        address organism,
        bytes32 tool,
        bytes32 purpose,
        uint256 efficiency
    ) external returns (bytes32 toolUseId) {
        toolUseId = keccak256(abi.encodePacked(organism, tool, purpose));

        ToolUse storage toolUse = toolUses[toolUseId];

        if (toolUse.firstUse == 0) {
            // First time using this tool
            toolUse.toolUseId = toolUseId;
            toolUse.organism = organism;
            toolUse.tool = tool;
            toolUse.purpose = purpose;
            toolUse.efficiency = efficiency;
            toolUse.firstUse = block.timestamp;
            toolUse.useCount = 1;
            toolUse.isNovel = _checkToolNovelty(tool, purpose);

            toolUseIds.push(toolUseId);

            emit ToolUseObserved(organism, tool, purpose, toolUse.isNovel);
        } else {
            // Repeated use - update efficiency
            toolUse.useCount++;
            toolUse.efficiency = (toolUse.efficiency + efficiency) / 2;
        }

        return toolUseId;
    }

    /**
     * @notice Record problem solving
     * @param solver Organism solving problem
     * @param problem Problem description
     * @param solution Solution found
     * @param attemptsNeeded Number of attempts
     * @param timeToSolve Blocks needed
     * @param learningType How they learned
     * @return problemId Problem ID
     */
    function recordProblemSolving(
        address solver,
        bytes32 problem,
        bytes32 solution,
        uint256 attemptsNeeded,
        uint256 timeToSolve,
        LearningType learningType
    ) external returns (bytes32 problemId) {
        problemId = keccak256(abi.encodePacked(problem, solver));

        uint256 creativityScore = _calculateCreativity(attemptsNeeded, timeToSolve, learningType);

        problemSolving[problemId] = ProblemSolving({
            problemId: problemId,
            problem: problem,
            solver: solver,
            solution: solution,
            attemptsNeeded: attemptsNeeded,
            timeToSolve: timeToSolve,
            creativityScore: creativityScore,
            learningType: learningType,
            isOptimal: attemptsNeeded <= 3 // Optimal if solved quickly
        });

        problemIds.push(problemId);

        emit ProblemSolved(solver, problem, attemptsNeeded, creativityScore);

        return problemId;
    }

    /**
     * @notice Track learning progress
     * @param organism Learning organism
     * @param skillId Skill being learned
     * @param performance Current performance (0-100)
     */
    function trackLearning(
        address organism,
        bytes32 skillId,
        uint256 performance
    ) external {
        LearningCurve storage curve = learningCurves[organism][skillId];

        if (curve.practiceCount == 0) {
            // First practice
            curve.organism = organism;
            curve.skillId = skillId;
            curve.initialPerformance = performance;
            curve.currentPerformance = performance;
            curve.learningRate = 0;
            curve.plateau = 100; // Assume can reach 100
            curve.practiceCount = 1;
        } else {
            // Update curve
            uint256 previousPerformance = curve.currentPerformance;
            curve.performance.push(performance);
            curve.currentPerformance = performance;
            curve.practiceCount++;

            // Calculate learning rate
            if (performance > previousPerformance) {
                curve.learningRate = performance - previousPerformance;
            }

            // Update skill proficiency
            skillProficiency[organism][skillId] = performance;
        }

        emit LearningProgress(organism, skillId, performance, curve.learningRate);
    }

    /**
     * @notice Form a memory
     * @param organism Organism forming memory
     * @param experience What happened
     * @param emotionalWeight Importance (0-100)
     * @return memoryId Memory ID
     */
    function formMemory(
        address organism,
        bytes32 experience,
        uint256 emotionalWeight
    ) external returns (bytes32 memoryId) {
        memoryId = keccak256(abi.encodePacked(organism, experience, block.timestamp));

        uint256 strength = emotionalWeight; // Emotional memories stronger

        memories[memoryId] = Memory({
            memoryId: memoryId,
            organism: organism,
            experience: experience,
            strength: strength,
            emotionalWeight: emotionalWeight,
            formationBlock: block.number,
            lastRecall: block.number,
            recallCount: 0,
            isLongTerm: emotionalWeight > 70 // High emotion = long term
        });

        memoryIds.push(memoryId);

        emit MemoryFormed(organism, memoryId, strength, memories[memoryId].isLongTerm);

        return memoryId;
    }

    /**
     * @notice Recall a memory
     * @param memoryId Memory to recall
     */
    function recallMemory(bytes32 memoryId) external {
        Memory storage mem = memories[memoryId];
        require(mem.memoryId != bytes32(0), "Memory not found");

        mem.lastRecall = block.number;
        mem.recallCount++;

        // Strengthen with recall
        if (mem.strength < 100) {
            mem.strength += 5;
        }

        // Becomes long term with repeated recall
        if (mem.recallCount > 5) {
            mem.isLongTerm = true;
        }
    }

    /**
     * @notice Form social structure
     * @param structureName Structure name
     * @param members Participating organisms
     * @param hierarchy How hierarchical (0-100)
     * @return structureId Structure ID
     */
    function formSocialStructure(
        string memory structureName,
        address[] memory members,
        uint256 hierarchy
    ) external returns (bytes32 structureId) {
        require(members.length >= 2, "Need 2+ members");

        structureId = keccak256(abi.encodePacked(structureName, block.timestamp));

        SocialStructure storage structure = socialStructures[structureId];
        structure.structureId = structureId;
        structure.structureName = structureName;
        structure.members = members;
        structure.hierarchy = hierarchy;
        structure.stability = 50; // Start medium
        structure.formationBlock = block.number;

        // Assign default roles
        for (uint256 i = 0; i < members.length; i++) {
            structure.roles[members[i]] = keccak256("member");
            structure.rank[members[i]] = i; // Order = rank
        }

        structureIds.push(structureId);

        emit SocialStructureFormed(structureId, structureName, members.length);

        return structureId;
    }

    /**
     * @notice Record cultural trait emergence
     * @param traitName Trait name
     * @param originator Who started it
     * @param practitioners Initial practitioners
     * @return traitId Trait ID
     */
    function recordCulturalTrait(
        bytes32 traitName,
        address originator,
        address[] memory practitioners
    ) external returns (bytes32 traitId) {
        traitId = keccak256(abi.encodePacked(traitName, originator));

        culturalTraits[traitId] = CulturalTrait({
            traitId: traitId,
            traitName: traitName,
            originator: originator,
            practitioners: practitioners,
            transmission: practitioners.length * 10, // Spread rate
            fidelity: 80, // Start at 80% accurate copy
            longevity: 0,
            emergenceBlock: block.number,
            isWidespread: practitioners.length > 10
        });

        traitIds.push(traitId);

        emit CultureEmerged(traitId, traitName, originator, practitioners.length);

        return traitId;
    }

    /**
     * @notice Record innovation
     * @param innovator Who created it
     * @param innovation What they created
     * @param impact Effect on fitness (0-100)
     * @return innovationId Innovation ID
     */
    function recordInnovation(
        address innovator,
        bytes32 innovation,
        uint256 impact
    ) external returns (bytes32 innovationId) {
        innovationId = keccak256(abi.encodePacked(innovator, innovation, block.timestamp));

        innovations[innovationId] = Innovation({
            innovationId: innovationId,
            innovator: innovator,
            innovation: innovation,
            impact: impact,
            adoptionRate: 0,
            adopters: new address[](0),
            creationBlock: block.number,
            isMeme: false
        });

        innovationIds.push(innovationId);

        emit InnovationCreated(innovator, innovation, impact);

        return innovationId;
    }

    /**
     * @notice Record teaching event
     * @param teacher Teaching organism
     * @param student Learning organism
     * @param knowledge Knowledge transferred
     * @param effectiveness Student improvement (0-100)
     * @return eventId Teaching event ID
     */
    function recordTeaching(
        address teacher,
        address student,
        bytes32 knowledge,
        uint256 effectiveness
    ) external returns (bytes32 eventId) {
        eventId = keccak256(abi.encodePacked(teacher, student, knowledge, block.timestamp));

        teachingEvents[eventId] = TeachingEvent({
            eventId: eventId,
            teacher: teacher,
            student: student,
            knowledge: knowledge,
            effectiveness: effectiveness,
            patience: 50, // Default
            timestamp: block.timestamp,
            wasSuccessful: effectiveness > 50
        });

        teachingIds.push(eventId);

        emit KnowledgeTransferred(teacher, student, knowledge, effectiveness > 50);

        return eventId;
    }

    /**
     * @notice Update intelligence estimate
     */
    function _updateIntelligence(
        address organism,
        uint256 complexity,
        uint256 novelty
    ) private {
        uint256 behaviorScore = (complexity + novelty) / 2;
        uint256 currentIntelligence = estimatedIntelligence[organism];

        // Moving average
        uint256 newIntelligence = (currentIntelligence * behaviorCount[organism] + behaviorScore) /
            (behaviorCount[organism] + 1);

        estimatedIntelligence[organism] = newIntelligence;

        emit IntelligenceEvolved(organism, newIntelligence, behaviorCount[organism]);
    }

    /**
     * @notice Check if tool use is novel
     */
    function _checkToolNovelty(bytes32 tool, bytes32 purpose) private view returns (bool) {
        // Check if this tool-purpose combo exists
        for (uint256 i = 0; i < toolUseIds.length; i++) {
            ToolUse storage use = toolUses[toolUseIds[i]];
            if (use.tool == tool && use.purpose == purpose) {
                return false; // Not novel
            }
        }
        return true; // Novel
    }

    /**
     * @notice Calculate creativity score
     */
    function _calculateCreativity(
        uint256 attemptsNeeded,
        uint256 timeToSolve,
        LearningType learningType
    ) private pure returns (uint256) {
        uint256 score = 50; // Base

        // Fewer attempts = more creative
        if (attemptsNeeded == 1) {
            score += 30; // Insight!
        } else if (attemptsNeeded <= 3) {
            score += 20;
        }

        // Faster = more creative
        if (timeToSolve < 10) {
            score += 20;
        }

        // Learning type bonus
        if (learningType == LearningType.INSIGHT) {
            score += 30;
        } else if (learningType == LearningType.INNOVATION) {
            score += 40;
        }

        // Cap at 100
        if (score > 100) score = 100;

        return score;
    }

    /**
     * @notice Get behavior stats
     */
    function getBehaviorStats(address organism)
        external
        view
        returns (
            uint256 totalBehaviors,
            uint256 intelligence,
            uint256 toolUseCount,
            uint256 problemsSolved
        )
    {
        totalBehaviors = behaviorCount[organism];
        intelligence = estimatedIntelligence[organism];

        // Count tool uses
        toolUseCount = 0;
        for (uint256 i = 0; i < toolUseIds.length; i++) {
            if (toolUses[toolUseIds[i]].organism == organism) {
                toolUseCount++;
            }
        }

        // Count problems solved
        problemsSolved = 0;
        for (uint256 i = 0; i < problemIds.length; i++) {
            if (problemSolving[problemIds[i]].solver == organism) {
                problemsSolved++;
            }
        }

        return (totalBehaviors, intelligence, toolUseCount, problemsSolved);
    }

    /**
     * @notice Get learning curve
     */
    function getLearningCurve(address organism, bytes32 skillId)
        external
        view
        returns (
            uint256 initialPerformance,
            uint256 currentPerformance,
            uint256 learningRate,
            uint256 practiceCount
        )
    {
        LearningCurve storage curve = learningCurves[organism][skillId];
        return (
            curve.initialPerformance,
            curve.currentPerformance,
            curve.learningRate,
            curve.practiceCount
        );
    }

    /**
     * @notice Get memory info
     */
    function getMemory(bytes32 memoryId)
        external
        view
        returns (
            address organism,
            bytes32 experience,
            uint256 strength,
            uint256 recallCount,
            bool isLongTerm
        )
    {
        Memory storage mem = memories[memoryId];
        return (
            mem.organism,
            mem.experience,
            mem.strength,
            mem.recallCount,
            mem.isLongTerm
        );
    }

    /**
     * @notice Get behavior count
     */
    function getBehaviorCount() external view returns (uint256) {
        return behaviorIds.length;
    }
}
