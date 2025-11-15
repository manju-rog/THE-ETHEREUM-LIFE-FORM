// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Genome.sol";
import "./PopulationRegistry.sol";

/**
 * @title Organism
 * @notice Simplified organism without self-replication
 * @dev All reproduction handled by factory to avoid circular references
 */
contract Organism {
    using Genome for Genome.GenomeData;

    enum State {
        EMBRYO,
        JUVENILE,
        ADULT,
        ELDER,
        DECEASED
    }

    struct Stats {
        uint256 energy;
        uint256 gasEfficiency;
        uint256 resourcesAccumulated;
        uint256 reproductionCount;
        uint256 competitionWins;
        uint256 userInteractions;
    }

    Genome.GenomeData public genome;
    Stats public stats;
    State public state;
    PopulationRegistry public registry;

    address public parent1;
    address public parent2;
    address[] public offspring;

    uint256 public immutable birthBlock;
    uint256 public generation;

    uint256 public constant MIN_ENERGY = 10 ether;
    uint256 public mutationRate = 50000; // 5%

    event FitnessEvaluated(address indexed organism, uint256 score);
    event Death(address indexed organism, uint256 age, string cause);

    modifier alive() {
        require(state != State.DECEASED, "Dead");
        _;
    }

    constructor(
        address _registry,
        address _parent1,
        address _parent2,
        uint256 _generation,
        uint256 _initialEnergy
    ) {
        registry = PopulationRegistry(_registry);
        parent1 = _parent1;
        parent2 = _parent2;
        generation = _generation;
        birthBlock = block.number;
        state = State.EMBRYO;
        stats.energy = _initialEnergy;
        stats.gasEfficiency = 100000;

        _initializeGenome();
        registry.registerOrganism(address(this), generation, _parent1, _parent2);
    }

    function _initializeGenome() private {
        uint256 seed = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, address(this))));

        for (uint256 i = 0; i < 4; i++) {
            genome.chromosomes.push();
            Genome.Chromosome storage chr = genome.chromosomes[i];
            for (uint256 j = 0; j < 8; j++) {
                uint256 geneValue = uint256(keccak256(abi.encodePacked(seed, i, j)));
                chr.genes.push(Genome.Gene({
                    value: geneValue,
                    dominance: uint8(geneValue % 256),
                    expressed: (geneValue % 2) == 0,
                    mutationRate: 50000
                }));
            }
            chr.length = chr.genes.length;
            chr.hash = Genome.hashChromosome(chr);
        }

        genome.generation = generation;
        genome.signature = keccak256(abi.encodePacked(seed, block.timestamp));
    }

    function evaluateFitness() public returns (uint256 score) {
        uint256 gasScore = stats.gasEfficiency < 50000 ? 100 : 100 - ((stats.gasEfficiency - 50000) * 100) / 150000;
        uint256 resourceScore = stats.resourcesAccumulated > 1000 ether ? 100 : (stats.resourcesAccumulated * 100) / 1000 ether;
        uint256 reproductionScore = stats.reproductionCount >= 10 ? 100 : stats.reproductionCount * 10;

        score = (gasScore * 40 + resourceScore * 30 + reproductionScore * 30) / 100;
        if (score > 100) score = 100;

        registry.updateFitness(address(this), score);
        emit FitnessEvaluated(address(this), score);
        return score;
    }

    function updateState() external alive {
        uint256 age = block.number - birthBlock;
        if (age < 100) state = State.EMBRYO;
        else if (age < 1000) state = State.JUVENILE;
        else if (age < 50000) state = State.ADULT;
        else state = State.ELDER;

        if (stats.energy < MIN_ENERGY) {
            _die("Starvation");
        }
    }

    function _die(string memory cause) private {
        state = State.DECEASED;
        uint256 age = block.number - birthBlock;
        registry.recordDeath(address(this), cause);
        emit Death(address(this), age, cause);
    }

    function feed() external payable {
        stats.energy += msg.value;
        stats.resourcesAccumulated += msg.value;
        stats.userInteractions++;
    }

    function addOffspring(address child) external {
        offspring.push(child);
        stats.reproductionCount++;
    }

    function getSummary() external view returns (
        State currentState,
        uint256 age,
        uint256 energy,
        uint256 numOffspring,
        uint256 currentGeneration
    ) {
        return (state, block.number - birthBlock, stats.energy, offspring.length, generation);
    }

    receive() external payable {
        stats.energy += msg.value;
    }
}
