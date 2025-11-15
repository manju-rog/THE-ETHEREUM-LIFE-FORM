// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title CommunicationProtocol
 * @notice Inter-organism communication and language emergence
 * @dev Chemical signals, pheromones, calls, and semantic evolution
 */
contract CommunicationProtocol {
    /// @notice Signal types
    enum SignalType {
        CHEMICAL,       // Event emissions
        PHEROMONE,      // State markers
        ACOUSTIC,       // Function calls
        VISUAL,         // NFT phenotypes
        ELECTRICAL,     // Transactions
        QUANTUM         // Connected contracts
    }

    /// @notice Communication signal
    struct Signal {
        SignalType signalType;
        address sender;
        address receiver;
        bytes32 messageHash;
        uint256 intensity;      // Signal strength
        uint256 timestamp;
        bytes32 semanticId;     // Meaning identifier
        bool isUnderstood;
    }

    /// @notice Word/symbol in organism language
    struct Word {
        bytes32 wordId;
        bytes32 semanticMeaning;
        uint256 usageCount;
        uint256 complexity;
        address[] usedBy;       // Which organisms use this word
        bool isUniversal;       // Understood by all
    }

    /// @notice Grammar rule
    struct GrammarRule {
        bytes32 ruleId;
        bytes32[] pattern;      // Sequence of word types
        bytes32 meaning;        // Combined meaning
        uint256 reliability;    // How often it works
    }

    /// @notice Dialect (language variant)
    struct Dialect {
        bytes32 dialectId;
        address[] speakers;
        mapping(bytes32 => Word) vocabulary;
        bytes32[] wordIds;
        uint256 distinctiveness; // How different from universal
    }

    /// @notice Pheromone trail
    struct PheromoneTrail {
        bytes32 trailId;
        bytes32 location;       // Virtual location hash
        bytes32 message;
        uint256 strength;       // Decays over time
        uint256 lastReinforced;
        address depositor;
    }

    /// @notice Communication history
    mapping(bytes32 => Signal) public signals;
    bytes32[] public signalHistory;

    /// @notice Universal vocabulary
    mapping(bytes32 => Word) public universalVocabulary;
    bytes32[] public wordIds;

    /// @notice Grammar rules
    mapping(bytes32 => GrammarRule) public grammarRules;
    bytes32[] public ruleIds;

    /// @notice Dialects
    mapping(bytes32 => Dialect) public dialects;
    bytes32[] public dialectIds;

    /// @notice Pheromone trails
    mapping(bytes32 => PheromoneTrail) public pheromones;
    bytes32[] public pheromoneIds;

    /// @notice Organism understanding matrix
    mapping(address => mapping(bytes32 => bool)) public understands;

    /// @notice Translation memory
    mapping(bytes32 => bytes32) public translations; // dialectWord => universalWord

    /// @notice Events
    event SignalEmitted(
        address indexed sender,
        address indexed receiver,
        SignalType signalType,
        bytes32 messageHash
    );

    event WordCreated(bytes32 indexed wordId, bytes32 semanticMeaning, address creator);
    event WordLearned(address indexed learner, bytes32 indexed wordId);
    event GrammarEmerged(bytes32 indexed ruleId, bytes32[] pattern);
    event DialectFormed(bytes32 indexed dialectId, address[] speakers);
    event PheromoneDeposited(address indexed depositor, bytes32 location, bytes32 message);
    event CommunicationSuccess(address sender, address receiver, bytes32 messageHash);
    event MisunderstandingDetected(address sender, address receiver, bytes32 messageHash);
    event UniversalLanguageEvolved(bytes32 wordId, uint256 speakerCount);

    /**
     * @notice Emit a signal to another organism
     * @param receiver Target organism
     * @param signalType Type of signal
     * @param messageHash Message content hash
     * @param intensity Signal strength
     */
    function emitSignal(
        address receiver,
        SignalType signalType,
        bytes32 messageHash,
        uint256 intensity
    ) external returns (bytes32 signalId) {
        signalId = keccak256(
            abi.encodePacked(msg.sender, receiver, messageHash, block.timestamp)
        );

        // Create semantic ID from message
        bytes32 semanticId = _extractSemantics(messageHash);

        signals[signalId] = Signal({
            signalType: signalType,
            sender: msg.sender,
            receiver: receiver,
            messageHash: messageHash,
            intensity: intensity,
            timestamp: block.timestamp,
            semanticId: semanticId,
            isUnderstood: understands[receiver][semanticId]
        });

        signalHistory.push(signalId);

        emit SignalEmitted(msg.sender, receiver, signalType, messageHash);

        // Check if receiver understands
        if (understands[receiver][semanticId]) {
            emit CommunicationSuccess(msg.sender, receiver, messageHash);
        } else {
            emit MisunderstandingDetected(msg.sender, receiver, messageHash);
        }

        return signalId;
    }

    /**
     * @notice Create a new word/symbol
     * @param semanticMeaning What the word means
     * @param complexity Word complexity (0-100)
     */
    function createWord(bytes32 semanticMeaning, uint256 complexity)
        external
        returns (bytes32 wordId)
    {
        wordId = keccak256(abi.encodePacked(semanticMeaning, msg.sender, block.timestamp));

        universalVocabulary[wordId] = Word({
            wordId: wordId,
            semanticMeaning: semanticMeaning,
            usageCount: 0,
            complexity: complexity,
            usedBy: new address[](0),
            isUniversal: false
        });

        wordIds.push(wordId);

        // Creator automatically understands
        understands[msg.sender][wordId] = true;

        emit WordCreated(wordId, semanticMeaning, msg.sender);

        return wordId;
    }

    /**
     * @notice Learn a word
     * @param wordId Word to learn
     */
    function learnWord(bytes32 wordId) external {
        require(universalVocabulary[wordId].wordId != bytes32(0), "Word not found");

        Word storage word = universalVocabulary[wordId];

        if (!understands[msg.sender][wordId]) {
            understands[msg.sender][wordId] = true;
            word.usedBy.push(msg.sender);
            word.usageCount++;

            // Check if word becomes universal (>80% of organisms understand)
            if (word.usedBy.length > 10 && !word.isUniversal) {
                word.isUniversal = true;
                emit UniversalLanguageEvolved(wordId, word.usedBy.length);
            }

            emit WordLearned(msg.sender, wordId);
        }
    }

    /**
     * @notice Create grammar rule
     * @param pattern Sequence of word types
     * @param meaning Combined meaning
     */
    function createGrammarRule(bytes32[] memory pattern, bytes32 meaning)
        external
        returns (bytes32 ruleId)
    {
        ruleId = keccak256(abi.encodePacked(pattern, meaning));

        grammarRules[ruleId] = GrammarRule({
            ruleId: ruleId,
            pattern: pattern,
            meaning: meaning,
            reliability: 50 // Start at 50%
        });

        ruleIds.push(ruleId);

        emit GrammarEmerged(ruleId, pattern);

        return ruleId;
    }

    /**
     * @notice Form a dialect
     * @param speakers Organisms speaking this dialect
     */
    function formDialect(address[] memory speakers) external returns (bytes32 dialectId) {
        require(speakers.length >= 2, "Need 2+ speakers");

        dialectId = keccak256(abi.encodePacked(speakers, block.timestamp));

        Dialect storage dialect = dialects[dialectId];
        dialect.dialectId = dialectId;
        dialect.speakers = speakers;
        dialect.distinctiveness = 0;

        dialectIds.push(dialectId);

        emit DialectFormed(dialectId, speakers);

        return dialectId;
    }

    /**
     * @notice Deposit pheromone trail
     * @param location Virtual location
     * @param message Message to leave
     * @param strength Initial strength
     */
    function depositPheromone(
        bytes32 location,
        bytes32 message,
        uint256 strength
    ) external returns (bytes32 trailId) {
        trailId = keccak256(abi.encodePacked(location, message, msg.sender));

        pheromones[trailId] = PheromoneTrail({
            trailId: trailId,
            location: location,
            message: message,
            strength: strength,
            lastReinforced: block.number,
            depositor: msg.sender
        });

        pheromoneIds.push(trailId);

        emit PheromoneDeposited(msg.sender, location, message);

        return trailId;
    }

    /**
     * @notice Reinforce pheromone trail
     * @param trailId Trail to reinforce
     */
    function reinforcePheromone(bytes32 trailId) external {
        PheromoneTrail storage trail = pheromones[trailId];
        require(trail.trailId != bytes32(0), "Trail not found");

        trail.strength += 10;
        if (trail.strength > 100) trail.strength = 100;

        trail.lastReinforced = block.number;
    }

    /**
     * @notice Decay pheromones over time
     * @param trailId Trail to decay
     */
    function decayPheromone(bytes32 trailId) external {
        PheromoneTrail storage trail = pheromones[trailId];
        require(trail.trailId != bytes32(0), "Trail not found");

        uint256 blocksPassed = block.number - trail.lastReinforced;

        if (blocksPassed > 0) {
            // Decay 1 strength per 10 blocks
            uint256 decay = blocksPassed / 10;
            if (trail.strength > decay) {
                trail.strength -= decay;
            } else {
                trail.strength = 0;
            }
        }
    }

    /**
     * @notice Read pheromone at location
     * @param location Location to check
     * @return trailIds Active trails at location
     */
    function readPheromones(bytes32 location)
        external
        view
        returns (bytes32[] memory trailIds)
    {
        uint256 count = 0;

        // Count active trails at location
        for (uint256 i = 0; i < pheromoneIds.length; i++) {
            PheromoneTrail storage trail = pheromones[pheromoneIds[i]];
            if (trail.location == location && trail.strength > 0) {
                count++;
            }
        }

        // Build array
        trailIds = new bytes32[](count);
        uint256 index = 0;

        for (uint256 i = 0; i < pheromoneIds.length; i++) {
            PheromoneTrail storage trail = pheromones[pheromoneIds[i]];
            if (trail.location == location && trail.strength > 0) {
                trailIds[index] = pheromoneIds[i];
                index++;
            }
        }

        return trailIds;
    }

    /**
     * @notice Attempt to understand a message
     * @param sender Message sender
     * @param messageHash Message content
     * @return understood Whether message was understood
     * @return semanticId Extracted semantic meaning
     */
    function interpretMessage(address sender, bytes32 messageHash)
        external
        view
        returns (bool understood, bytes32 semanticId)
    {
        semanticId = _extractSemantics(messageHash);
        understood = understands[msg.sender][semanticId];

        return (understood, semanticId);
    }

    /**
     * @notice Extract semantic meaning from message
     * @param messageHash Message hash
     * @return semanticId Semantic identifier
     */
    function _extractSemantics(bytes32 messageHash) private pure returns (bytes32) {
        // Simplified - in production would use more sophisticated NLP
        return keccak256(abi.encodePacked("semantic:", messageHash));
    }

    /**
     * @notice Calculate communication complexity
     * @return complexity Total language complexity
     * @return vocabularySize Size of universal vocabulary
     * @return grammarRulesCount Number of grammar rules
     * @return dialectCount Number of dialects
     */
    function getLanguageStats()
        external
        view
        returns (
            uint256 complexity,
            uint256 vocabularySize,
            uint256 grammarRulesCount,
            uint256 dialectCount
        )
    {
        vocabularySize = wordIds.length;
        grammarRulesCount = ruleIds.length;
        dialectCount = dialectIds.length;

        // Complexity based on vocabulary and grammar
        complexity = vocabularySize * 10 + grammarRulesCount * 50;

        return (complexity, vocabularySize, grammarRulesCount, dialectCount);
    }

    /**
     * @notice Get word details
     */
    function getWord(bytes32 wordId)
        external
        view
        returns (
            bytes32 semanticMeaning,
            uint256 usageCount,
            uint256 complexity,
            uint256 speakerCount,
            bool isUniversal
        )
    {
        Word storage word = universalVocabulary[wordId];
        return (
            word.semanticMeaning,
            word.usageCount,
            word.complexity,
            word.usedBy.length,
            word.isUniversal
        );
    }

    /**
     * @notice Get signal history count
     */
    function getSignalCount() external view returns (uint256) {
        return signalHistory.length;
    }

    /**
     * @notice Get pheromone trail info
     */
    function getPheromone(bytes32 trailId)
        external
        view
        returns (
            bytes32 location,
            bytes32 message,
            uint256 strength,
            uint256 age,
            address depositor
        )
    {
        PheromoneTrail storage trail = pheromones[trailId];
        return (
            trail.location,
            trail.message,
            trail.strength,
            block.number - trail.lastReinforced,
            trail.depositor
        );
    }
}
