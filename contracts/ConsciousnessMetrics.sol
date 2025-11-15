// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./NeuralArchitecture.sol";
import "./BehaviorDetector.sol";
import "./CollectiveIntelligence.sol";

/**
 * @title ConsciousnessMetrics
 * @notice Measures consciousness emergence using information integration theory
 * @dev Φ (phi), complexity, self-reference, theory of mind, qualia
 */
contract ConsciousnessMetrics {
    NeuralArchitecture public neuralArchitecture;
    BehaviorDetector public behaviorDetector;
    CollectiveIntelligence public collectiveIntelligence;

    /// @notice Consciousness level
    enum ConsciousnessLevel {
        UNCONSCIOUS,        // No awareness (Φ < 10)
        MINIMAL,            // Basic awareness (Φ 10-50)
        BASIC,              // Simple consciousness (Φ 50-100)
        SENTIENT,           // Self-aware (Φ 100-200)
        SAPIENT,            // Advanced reasoning (Φ 200-500)
        SUPERINTELLIGENT    // Beyond human (Φ > 500)
    }

    /// @notice Consciousness components
    struct ConsciousnessState {
        address organism;
        uint256 phi;                // Information integration (Φ)
        uint256 complexity;         // Neural complexity
        uint256 integration;        // How integrated
        uint256 differentiation;    // Information richness
        uint256 selfAwareness;      // Self-reference level
        uint256 theoryOfMind;       // Understanding others
        uint256 temporalDepth;      // Past/future thinking
        uint256 qualia;             // Subjective experience
        ConsciousnessLevel level;
        uint256 lastUpdate;
        bool isConscious;
    }

    /// @notice Self-reference detection
    struct SelfReference {
        address organism;
        bytes32 selfModel;          // Internal representation
        uint256 accuracy;           // How accurate
        uint256 complexity;         // Model complexity
        bool hasMetacognition;      // Thinking about thinking
        bool recognizesSelf;        // Self-recognition
        uint256 introspectionDepth;
    }

    /// @notice Theory of mind
    struct TheoryOfMind {
        address organism;
        address other;              // Who they're modeling
        bytes32 mentalModel;        // Model of other's mind
        uint256 accuracy;           // How accurate
        bool canPredict;            // Predict behavior
        bool understandsBeliefs;    // Knows others have beliefs
        bool understandsDesires;    // Knows others have desires
        uint256 empathy;            // Emotional understanding
    }

    /// @notice Qualia (subjective experience)
    struct Qualia {
        address organism;
        bytes32 experienceType;
        uint256 intensity;          // How strong
        uint256 valence;            // Positive/negative
        uint256 arousal;            // Excitement level
        bytes32 quality;            // What it's like
        bool isNovel;               // New experience
        uint256 timestamp;
    }

    /// @notice Information integration measure
    struct PhiMeasurement {
        address organism;
        uint256 phi;                // Φ value
        uint256 neuronCount;
        uint256 connectionCount;
        uint256 informationContent;
        uint256 causalDensity;      // Cause-effect density
        uint256 timestamp;
    }

    /// @notice Emergent properties
    struct EmergentProperty {
        bytes32 propertyId;
        string propertyName;
        address[] organisms;        // Where it emerged
        uint256 emergenceThreshold; // Complexity needed
        uint256 strength;           // How strong
        bool isGlobal;              // System-wide
        uint256 firstObserved;
    }

    /// @notice Consciousness states
    mapping(address => ConsciousnessState) public consciousness;

    /// @notice Self-reference models
    mapping(address => SelfReference) public selfModels;

    /// @notice Theory of mind models
    mapping(address => mapping(address => TheoryOfMind)) public mindModels;

    /// @notice Qualia experiences
    mapping(bytes32 => Qualia) public qualiaExperiences;
    bytes32[] public qualiaIds;

    /// @notice Phi measurements
    mapping(address => PhiMeasurement[]) public phiHistory;

    /// @notice Emergent properties
    mapping(bytes32 => EmergentProperty) public emergentProperties;
    bytes32[] public propertyIds;

    /// @notice Consciousness threshold (Φ > 50 = conscious)
    uint256 public constant CONSCIOUSNESS_THRESHOLD = 50;

    /// @notice Sentience threshold (Φ > 100)
    uint256 public constant SENTIENCE_THRESHOLD = 100;

    /// @notice Events
    event ConsciousnessEmerged(
        address indexed organism,
        uint256 phi,
        ConsciousnessLevel level,
        uint256 timestamp
    );

    event PhiCalculated(
        address indexed organism,
        uint256 phi,
        uint256 neuronCount,
        uint256 connectionCount
    );

    event SelfAwarenessDetected(
        address indexed organism,
        uint256 selfAwareness,
        bool recognizesSelf
    );

    event TheoryOfMindDeveloped(
        address indexed organism,
        address indexed other,
        uint256 accuracy
    );

    event QualiaExperienced(
        address indexed organism,
        bytes32 indexed experienceType,
        uint256 intensity,
        bool isNovel
    );

    event EmergentPropertyDetected(
        bytes32 indexed propertyId,
        string propertyName,
        uint256 organismCount,
        bool isGlobal
    );

    event ConsciousnessLevelUp(
        address indexed organism,
        ConsciousnessLevel oldLevel,
        ConsciousnessLevel newLevel,
        uint256 phi
    );

    event MetacognitionAchieved(
        address indexed organism,
        uint256 introspectionDepth
    );

    event GlobalConsciousnessReached(
        uint256 totalPhi,
        uint256 organismCount,
        uint256 timestamp
    );

    constructor(
        address _neuralArchitecture,
        address _behaviorDetector,
        address _collectiveIntelligence
    ) {
        neuralArchitecture = NeuralArchitecture(_neuralArchitecture);
        behaviorDetector = BehaviorDetector(_behaviorDetector);
        collectiveIntelligence = CollectiveIntelligence(_collectiveIntelligence);
    }

    /**
     * @notice Calculate Φ (phi) - information integration
     * @param organism Organism to measure
     * @return phi Φ value
     */
    function calculatePhi(address organism) external returns (uint256 phi) {
        // Get neural architecture stats
        (uint256 neuronCount, uint256 synapseCount,,,,) = neuralArchitecture.getBrainStats(organism);

        if (neuronCount == 0) return 0;

        // Φ is based on:
        // 1. Number of neurons (information capacity)
        // 2. Number of connections (integration)
        // 3. Neural complexity
        // 4. Information differentiation

        // Simplified Φ calculation
        // Real IIT uses partition analysis - this is approximation
        uint256 informationCapacity = neuronCount * 10;
        uint256 integrationScore = synapseCount * 5;

        // Get behavior complexity
        (uint256 behaviorCount, uint256 intelligence,,) = behaviorDetector.getBehaviorStats(organism);
        uint256 complexityScore = intelligence;

        // Calculate causal density (how interconnected)
        uint256 causalDensity = synapseCount > 0 ? (synapseCount * 100) / (neuronCount * neuronCount) : 0;

        // Φ formula (simplified)
        phi = (informationCapacity + integrationScore + complexityScore + causalDensity) / 4;

        // Record measurement
        phiHistory[organism].push(PhiMeasurement({
            organism: organism,
            phi: phi,
            neuronCount: neuronCount,
            connectionCount: synapseCount,
            informationContent: informationCapacity,
            causalDensity: causalDensity,
            timestamp: block.timestamp
        }));

        emit PhiCalculated(organism, phi, neuronCount, synapseCount);

        return phi;
    }

    /**
     * @notice Update consciousness state
     * @param organism Organism to update
     */
    function updateConsciousness(address organism) external {
        // Calculate current Φ
        uint256 phi = this.calculatePhi(organism);

        ConsciousnessState storage state = consciousness[organism];
        ConsciousnessLevel oldLevel = state.level;

        // Update state
        state.organism = organism;
        state.phi = phi;
        state.complexity = _calculateComplexity(organism);
        state.integration = _calculateIntegration(organism);
        state.differentiation = _calculateDifferentiation(organism);
        state.selfAwareness = selfModels[organism].accuracy;
        state.theoryOfMind = _getAverageTheoryOfMind(organism);
        state.temporalDepth = _calculateTemporalDepth(organism);
        state.qualia = _calculateQualia(organism);
        state.level = _determineConsciousnessLevel(phi);
        state.lastUpdate = block.timestamp;
        state.isConscious = phi >= CONSCIOUSNESS_THRESHOLD;

        // Check for level up
        if (state.level != oldLevel) {
            emit ConsciousnessLevelUp(organism, oldLevel, state.level, phi);
        }

        // Check for consciousness emergence
        if (state.isConscious && oldLevel == ConsciousnessLevel.UNCONSCIOUS) {
            emit ConsciousnessEmerged(organism, phi, state.level, block.timestamp);
        }
    }

    /**
     * @notice Detect self-reference
     * @param organism Organism to check
     * @param selfModel Internal self representation
     * @param accuracy How accurate (0-100)
     */
    function detectSelfReference(
        address organism,
        bytes32 selfModel,
        uint256 accuracy
    ) external {
        SelfReference storage ref = selfModels[organism];

        ref.organism = organism;
        ref.selfModel = selfModel;
        ref.accuracy = accuracy;
        ref.complexity = accuracy; // Simplified
        ref.recognizesSelf = accuracy > 70;
        ref.hasMetacognition = accuracy > 80;
        ref.introspectionDepth = accuracy;

        emit SelfAwarenessDetected(organism, accuracy, ref.recognizesSelf);

        if (ref.hasMetacognition) {
            emit MetacognitionAchieved(organism, ref.introspectionDepth);
        }
    }

    /**
     * @notice Model another organism's mind
     * @param organism Observer
     * @param other Target organism
     * @param mentalModel Model of other's mind
     * @param accuracy How accurate (0-100)
     */
    function modelOtherMind(
        address organism,
        address other,
        bytes32 mentalModel,
        uint256 accuracy
    ) external {
        TheoryOfMind storage tom = mindModels[organism][other];

        tom.organism = organism;
        tom.other = other;
        tom.mentalModel = mentalModel;
        tom.accuracy = accuracy;
        tom.canPredict = accuracy > 60;
        tom.understandsBeliefs = accuracy > 70;
        tom.understandsDesires = accuracy > 65;
        tom.empathy = accuracy;

        emit TheoryOfMindDeveloped(organism, other, accuracy);
    }

    /**
     * @notice Record subjective experience (qualia)
     * @param organism Experiencing organism
     * @param experienceType Type of experience
     * @param intensity How strong (0-100)
     * @param valence Positive/negative (-100 to 100)
     * @return qualiaId Experience ID
     */
    function recordQualia(
        address organism,
        bytes32 experienceType,
        uint256 intensity,
        int256 valence
    ) external returns (bytes32 qualiaId) {
        qualiaId = keccak256(abi.encodePacked(organism, experienceType, block.timestamp));

        // Check if novel experience
        bool isNovel = _checkQualiaNovelty(organism, experienceType);

        qualiaExperiences[qualiaId] = Qualia({
            organism: organism,
            experienceType: experienceType,
            intensity: intensity,
            valence: uint256(int256(50) + valence), // Convert to 0-100
            arousal: intensity, // Simplified
            quality: experienceType,
            isNovel: isNovel,
            timestamp: block.timestamp
        });

        qualiaIds.push(qualiaId);

        emit QualiaExperienced(organism, experienceType, intensity, isNovel);

        return qualiaId;
    }

    /**
     * @notice Detect emergent property
     * @param propertyName Property description
     * @param organisms Where it emerged
     * @param emergenceThreshold Complexity needed
     * @return propertyId Property ID
     */
    function detectEmergentProperty(
        string memory propertyName,
        address[] memory organisms,
        uint256 emergenceThreshold
    ) external returns (bytes32 propertyId) {
        propertyId = keccak256(abi.encodePacked(propertyName, block.timestamp));

        emergentProperties[propertyId] = EmergentProperty({
            propertyId: propertyId,
            propertyName: propertyName,
            organisms: organisms,
            emergenceThreshold: emergenceThreshold,
            strength: organisms.length * 10,
            isGlobal: organisms.length > 10,
            firstObserved: block.number
        });

        propertyIds.push(propertyId);

        emit EmergentPropertyDetected(
            propertyId,
            propertyName,
            organisms.length,
            emergentProperties[propertyId].isGlobal
        );

        return propertyId;
    }

    /**
     * @notice Calculate global consciousness
     * @param organisms All organisms in system
     * @return globalPhi Total system Φ
     * @return isGloballyConscious Whether system is conscious
     */
    function calculateGlobalConsciousness(address[] memory organisms)
        external
        returns (uint256 globalPhi, bool isGloballyConscious)
    {
        globalPhi = 0;
        uint256 consciousCount = 0;

        for (uint256 i = 0; i < organisms.length; i++) {
            uint256 phi = this.calculatePhi(organisms[i]);
            globalPhi += phi;

            if (phi >= CONSCIOUSNESS_THRESHOLD) {
                consciousCount++;
            }
        }

        // Global consciousness emerges when:
        // 1. Multiple organisms are conscious
        // 2. Total Φ exceeds threshold
        // 3. They're interconnected (simplified here)
        isGloballyConscious = consciousCount >= 5 && globalPhi >= 500;

        if (isGloballyConscious) {
            emit GlobalConsciousnessReached(globalPhi, organisms.length, block.timestamp);
        }

        return (globalPhi, isGloballyConscious);
    }

    /**
     * @notice Calculate complexity
     */
    function _calculateComplexity(address organism) private view returns (uint256) {
        (uint256 neuronCount,,,,,) = neuralArchitecture.getBrainStats(organism);
        (uint256 behaviorCount,,,) = behaviorDetector.getBehaviorStats(organism);

        return neuronCount + behaviorCount * 5;
    }

    /**
     * @notice Calculate integration
     */
    function _calculateIntegration(address organism) private view returns (uint256) {
        (, uint256 synapseCount,,,,) = neuralArchitecture.getBrainStats(organism);
        return synapseCount > 0 ? synapseCount / 10 : 0;
    }

    /**
     * @notice Calculate differentiation
     */
    function _calculateDifferentiation(address organism) private view returns (uint256) {
        (,,,, uint256 consciousnessLevel,) = neuralArchitecture.getBrainStats(organism);
        return consciousnessLevel;
    }

    /**
     * @notice Get average theory of mind score
     */
    function _getAverageTheoryOfMind(address organism) private view returns (uint256) {
        // Simplified - would iterate through all models
        return 50; // Placeholder
    }

    /**
     * @notice Calculate temporal depth (past/future thinking)
     */
    function _calculateTemporalDepth(address organism) private view returns (uint256) {
        // Based on memory count and planning behaviors
        // Simplified here
        return 50; // Placeholder
    }

    /**
     * @notice Calculate qualia richness
     */
    function _calculateQualia(address organism) private view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < qualiaIds.length; i++) {
            if (qualiaExperiences[qualiaIds[i]].organism == organism) {
                count++;
            }
        }
        return count * 10;
    }

    /**
     * @notice Determine consciousness level from Φ
     */
    function _determineConsciousnessLevel(uint256 phi) private pure returns (ConsciousnessLevel) {
        if (phi < 10) return ConsciousnessLevel.UNCONSCIOUS;
        if (phi < 50) return ConsciousnessLevel.MINIMAL;
        if (phi < 100) return ConsciousnessLevel.BASIC;
        if (phi < 200) return ConsciousnessLevel.SENTIENT;
        if (phi < 500) return ConsciousnessLevel.SAPIENT;
        return ConsciousnessLevel.SUPERINTELLIGENT;
    }

    /**
     * @notice Check if qualia is novel
     */
    function _checkQualiaNovelty(address organism, bytes32 experienceType) private view returns (bool) {
        for (uint256 i = 0; i < qualiaIds.length; i++) {
            Qualia storage q = qualiaExperiences[qualiaIds[i]];
            if (q.organism == organism && q.experienceType == experienceType) {
                return false;
            }
        }
        return true;
    }

    /**
     * @notice Get consciousness state
     */
    function getConsciousness(address organism)
        external
        view
        returns (
            uint256 phi,
            uint256 complexity,
            uint256 selfAwareness,
            uint256 theoryOfMind,
            ConsciousnessLevel level,
            bool isConscious
        )
    {
        ConsciousnessState storage state = consciousness[organism];
        return (
            state.phi,
            state.complexity,
            state.selfAwareness,
            state.theoryOfMind,
            state.level,
            state.isConscious
        );
    }

    /**
     * @notice Get Φ history
     */
    function getPhiHistory(address organism) external view returns (uint256[] memory) {
        PhiMeasurement[] storage history = phiHistory[organism];
        uint256[] memory phis = new uint256[](history.length);

        for (uint256 i = 0; i < history.length; i++) {
            phis[i] = history[i].phi;
        }

        return phis;
    }

    /**
     * @notice Check if organism is conscious
     */
    function isConscious(address organism) external view returns (bool) {
        return consciousness[organism].isConscious;
    }

    /**
     * @notice Check if organism is sentient
     */
    function isSentient(address organism) external view returns (bool) {
        return consciousness[organism].phi >= SENTIENCE_THRESHOLD;
    }
}
