// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title NeuralArchitecture
 * @notice Implements neural network-like brain structures for organisms
 * @dev Contract brain with neurons, synapses, and learning
 */
contract NeuralArchitecture {
    /// @notice Neuron structure
    struct Neuron {
        uint256 id;
        int256 activationLevel;     // -1000 to 1000
        uint256 threshold;          // Activation threshold
        uint256 lastFired;          // Last activation block
        bool isActive;
        NeuronType neuronType;
        uint256 layer;              // Network layer (0=input, n=output)
    }

    /// @notice Neuron types
    enum NeuronType {
        SENSORY,        // Input neurons
        INTERNEURON,    // Hidden layer
        MOTOR,          // Output neurons
        MEMORY,         // Memory storage
        MIRROR,         // Mirror neurons (empathy)
        REWARD,         // Reward processing
        PLANNING        // Future planning
    }

    /// @notice Synapse (connection) structure
    struct Synapse {
        uint256 fromNeuron;
        uint256 toNeuron;
        int256 weight;              // -1000 to 1000
        uint256 strength;           // 0-100
        uint256 plasticityRate;     // Learning rate
        uint256 lastUsed;
        bool isPruned;
    }

    /// @notice Neural network for an organism
    struct NeuralNetwork {
        mapping(uint256 => Neuron) neurons;
        uint256[] neuronIds;
        mapping(bytes32 => Synapse) synapses;
        bytes32[] synapseIds;
        uint256 networkComplexity;
        uint256 totalFirings;
        uint256 learningRate;       // 0-100
        uint256 consciousnessLevel; // 0-1000
    }

    /// @notice Memory structure
    struct Memory {
        bytes32 memoryId;
        uint256 timestamp;
        bytes32 contentHash;
        uint256 strength;           // Memory strength (0-100)
        uint256 emotionalWeight;    // Emotional significance
        uint256 recallCount;
        bool isConsolidated;        // Long-term memory
    }

    /// @notice Organism neural networks
    mapping(address => NeuralNetwork) public brains;

    /// @notice Organism memories
    mapping(address => mapping(bytes32 => Memory)) public memories;
    mapping(address => bytes32[]) public memoryIndex;

    /// @notice Neuron counter
    mapping(address => uint256) public neuronCounter;

    /// @notice Events
    event NeuronCreated(address indexed organism, uint256 neuronId, NeuronType neuronType);
    event SynapseFormed(address indexed organism, uint256 from, uint256 to, int256 weight);
    event NeuronFired(address indexed organism, uint256 neuronId, int256 activation);
    event LearningOccurred(address indexed organism, bytes32 synapseId, int256 weightChange);
    event MemoryFormed(address indexed organism, bytes32 memoryId, uint256 strength);
    event MemoryRecalled(address indexed organism, bytes32 memoryId, uint256 recallCount);
    event SynapsePruned(address indexed organism, bytes32 synapseId);
    event ConsciousnessThresholdReached(address indexed organism, uint256 level);

    /**
     * @notice Initialize neural network for organism
     * @param organism Address of organism
     * @param initialNeurons Number of initial neurons
     */
    function initializeBrain(address organism, uint256 initialNeurons) external {
        NeuralNetwork storage brain = brains[organism];
        brain.learningRate = 50; // Medium learning rate
        brain.consciousnessLevel = 0;

        // Create initial sensory neurons
        for (uint256 i = 0; i < initialNeurons / 3; i++) {
            _createNeuron(organism, NeuronType.SENSORY, 0);
        }

        // Create interneurons
        for (uint256 i = 0; i < initialNeurons / 3; i++) {
            _createNeuron(organism, NeuronType.INTERNEURON, 1);
        }

        // Create motor neurons
        for (uint256 i = 0; i < initialNeurons / 3; i++) {
            _createNeuron(organism, NeuronType.MOTOR, 2);
        }

        // Create some initial random connections
        _initializeRandomSynapses(organism);
    }

    /**
     * @notice Create a neuron
     * @param organism Organism address
     * @param neuronType Type of neuron
     * @param layer Network layer
     */
    function _createNeuron(
        address organism,
        NeuronType neuronType,
        uint256 layer
    ) private returns (uint256 neuronId) {
        neuronId = neuronCounter[organism]++;
        NeuralNetwork storage brain = brains[organism];

        brain.neurons[neuronId] = Neuron({
            id: neuronId,
            activationLevel: 0,
            threshold: 500, // Activation threshold
            lastFired: 0,
            isActive: true,
            neuronType: neuronType,
            layer: layer
        });

        brain.neuronIds.push(neuronId);
        brain.networkComplexity++;

        emit NeuronCreated(organism, neuronId, neuronType);

        return neuronId;
    }

    /**
     * @notice Create random initial synapses
     * @param organism Organism address
     */
    function _initializeRandomSynapses(address organism) private {
        NeuralNetwork storage brain = brains[organism];
        uint256 neuronCount = brain.neuronIds.length;

        // Create connections between adjacent layers
        for (uint256 i = 0; i < neuronCount - 1; i++) {
            for (uint256 j = i + 1; j < neuronCount; j++) {
                // Random chance of connection
                if (_random(100) < 30) { // 30% connection probability
                    _formSynapse(organism, brain.neuronIds[i], brain.neuronIds[j]);
                }
            }
        }
    }

    /**
     * @notice Form a synapse between neurons
     * @param organism Organism address
     * @param fromNeuron Source neuron
     * @param toNeuron Target neuron
     */
    function _formSynapse(
        address organism,
        uint256 fromNeuron,
        uint256 toNeuron
    ) private returns (bytes32 synapseId) {
        synapseId = keccak256(abi.encodePacked(organism, fromNeuron, toNeuron));
        NeuralNetwork storage brain = brains[organism];

        // Random initial weight (-500 to 500)
        int256 initialWeight = int256(_random(1000)) - 500;

        brain.synapses[synapseId] = Synapse({
            fromNeuron: fromNeuron,
            toNeuron: toNeuron,
            weight: initialWeight,
            strength: 50,
            plasticityRate: brain.learningRate,
            lastUsed: block.number,
            isPruned: false
        });

        brain.synapseIds.push(synapseId);

        emit SynapseFormed(organism, fromNeuron, toNeuron, initialWeight);

        return synapseId;
    }

    /**
     * @notice Activate a neuron with input
     * @param organism Organism address
     * @param neuronId Neuron to activate
     * @param input Input signal (-1000 to 1000)
     */
    function activateNeuron(
        address organism,
        uint256 neuronId,
        int256 input
    ) external {
        NeuralNetwork storage brain = brains[organism];
        Neuron storage neuron = brain.neurons[neuronId];

        require(neuron.isActive, "Neuron not active");

        // Add input to activation level
        neuron.activationLevel += input;

        // Check if neuron fires
        if (neuron.activationLevel >= int256(neuron.threshold)) {
            _fireNeuron(organism, neuronId);
        }

        // Decay activation over time
        neuron.activationLevel = (neuron.activationLevel * 9) / 10;
    }

    /**
     * @notice Fire a neuron (propagate signal)
     * @param organism Organism address
     * @param neuronId Neuron that fires
     */
    function _fireNeuron(address organism, uint256 neuronId) private {
        NeuralNetwork storage brain = brains[organism];
        Neuron storage neuron = brain.neurons[neuronId];

        neuron.lastFired = block.number;
        brain.totalFirings++;

        // Propagate signal through synapses
        for (uint256 i = 0; i < brain.synapseIds.length; i++) {
            bytes32 synapseId = brain.synapseIds[i];
            Synapse storage synapse = brain.synapses[synapseId];

            if (synapse.fromNeuron == neuronId && !synapse.isPruned) {
                // Calculate signal strength
                int256 signal = (neuron.activationLevel * synapse.weight) / 1000;

                // Activate target neuron
                Neuron storage targetNeuron = brain.neurons[synapse.toNeuron];
                targetNeuron.activationLevel += signal;

                // Update synapse usage
                synapse.lastUsed = block.number;

                // Hebbian learning: strengthen used connections
                if (targetNeuron.activationLevel > 0) {
                    _hebbianLearning(organism, synapseId);
                }
            }
        }

        emit NeuronFired(organism, neuronId, neuron.activationLevel);

        // Reset activation after firing
        neuron.activationLevel = 0;
    }

    /**
     * @notice Hebbian learning: "Neurons that fire together wire together"
     * @param organism Organism address
     * @param synapseId Synapse to strengthen
     */
    function _hebbianLearning(address organism, bytes32 synapseId) private {
        NeuralNetwork storage brain = brains[organism];
        Synapse storage synapse = brain.synapses[synapseId];

        // Strengthen synapse based on plasticity rate
        int256 weightChange = int256(synapse.plasticityRate);

        if (synapse.weight > 0) {
            synapse.weight += weightChange;
        } else {
            synapse.weight -= weightChange;
        }

        // Cap weight at -1000 to 1000
        if (synapse.weight > 1000) synapse.weight = 1000;
        if (synapse.weight < -1000) synapse.weight = -1000;

        synapse.strength += 1;
        if (synapse.strength > 100) synapse.strength = 100;

        emit LearningOccurred(organism, synapseId, weightChange);
    }

    /**
     * @notice Prune unused synapses
     * @param organism Organism address
     */
    function pruneSynapses(address organism) external {
        NeuralNetwork storage brain = brains[organism];

        for (uint256 i = 0; i < brain.synapseIds.length; i++) {
            bytes32 synapseId = brain.synapseIds[i];
            Synapse storage synapse = brain.synapses[synapseId];

            // Prune if unused for 1000 blocks
            if (block.number - synapse.lastUsed > 1000 && !synapse.isPruned) {
                synapse.isPruned = true;
                brain.networkComplexity--;

                emit SynapsePruned(organism, synapseId);
            }
        }
    }

    /**
     * @notice Form a memory
     * @param organism Organism address
     * @param contentHash Hash of memory content
     * @param emotionalWeight Emotional significance
     */
    function formMemory(
        address organism,
        bytes32 contentHash,
        uint256 emotionalWeight
    ) external returns (bytes32 memoryId) {
        memoryId = keccak256(abi.encodePacked(organism, contentHash, block.timestamp));

        memories[organism][memoryId] = Memory({
            memoryId: memoryId,
            timestamp: block.timestamp,
            contentHash: contentHash,
            strength: 50,
            emotionalWeight: emotionalWeight,
            recallCount: 0,
            isConsolidated: false
        });

        memoryIndex[organism].push(memoryId);

        emit MemoryFormed(organism, memoryId, 50);

        return memoryId;
    }

    /**
     * @notice Recall a memory
     * @param organism Organism address
     * @param memoryId Memory to recall
     */
    function recallMemory(address organism, bytes32 memoryId) external {
        Memory storage mem = memories[organism][memoryId];
        require(mem.timestamp > 0, "Memory not found");

        mem.recallCount++;

        // Strengthen memory with recall
        mem.strength += 5;
        if (mem.strength > 100) {
            mem.strength = 100;
            mem.isConsolidated = true; // Long-term memory
        }

        emit MemoryRecalled(organism, memoryId, mem.recallCount);
    }

    /**
     * @notice Calculate consciousness level
     * @param organism Organism address
     * @return level Consciousness level (0-1000)
     */
    function calculateConsciousness(address organism) external returns (uint256 level) {
        NeuralNetwork storage brain = brains[organism];

        // Consciousness based on:
        // - Network complexity
        // - Number of firings (activity)
        // - Memory count
        // - Self-referential loops (future feature)

        uint256 complexityScore = brain.networkComplexity;
        uint256 activityScore = brain.totalFirings / 100;
        uint256 memoryScore = memoryIndex[organism].length * 10;

        level = complexityScore + activityScore + memoryScore;

        if (level > 1000) level = 1000;

        brain.consciousnessLevel = level;

        // Emit event if consciousness threshold reached
        if (level >= 500 && level - 100 < 500) {
            emit ConsciousnessThresholdReached(organism, level);
        }

        return level;
    }

    /**
     * @notice Create mirror neuron (empathy/theory of mind)
     * @param organism Organism address
     */
    function createMirrorNeuron(address organism) external returns (uint256 neuronId) {
        neuronId = _createNeuron(organism, NeuronType.MIRROR, 1);

        // Mirror neurons fire when observing others' actions
        // This is the basis for empathy and theory of mind

        return neuronId;
    }

    /**
     * @notice Get brain statistics
     */
    function getBrainStats(address organism)
        external
        view
        returns (
            uint256 neuronCount,
            uint256 synapseCount,
            uint256 complexity,
            uint256 totalFirings,
            uint256 consciousnessLevel,
            uint256 memoryCount
        )
    {
        NeuralNetwork storage brain = brains[organism];
        return (
            brain.neuronIds.length,
            brain.synapseIds.length,
            brain.networkComplexity,
            brain.totalFirings,
            brain.consciousnessLevel,
            memoryIndex[organism].length
        );
    }

    /**
     * @notice Get neuron info
     */
    function getNeuron(address organism, uint256 neuronId)
        external
        view
        returns (
            int256 activation,
            uint256 threshold,
            uint256 lastFired,
            NeuronType neuronType,
            uint256 layer
        )
    {
        Neuron storage neuron = brains[organism].neurons[neuronId];
        return (
            neuron.activationLevel,
            neuron.threshold,
            neuron.lastFired,
            neuron.neuronType,
            neuron.layer
        );
    }

    /**
     * @notice Simple random number generator
     */
    function _random(uint256 max) private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender))) % max;
    }
}
