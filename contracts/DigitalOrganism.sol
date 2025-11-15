// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "./libraries/GeneticLib.sol";

/**
 * @title DigitalOrganism
 * @notice A self-modifying, evolving smart contract representing digital life
 * @dev Uses UUPS proxy pattern for evolution and self-modification
 */
contract DigitalOrganism is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using GeneticLib for uint256[];

    // Genome structure - the DNA of digital life
    struct Genome {
        bytes32 dnaHash; // Unique genetic signature
        uint256[] genes; // Mutable code parameters
        uint8 generation; // Evolutionary distance from genesis
        address[] ancestors; // Genetic lineage
        uint256 fitness; // Survival score
        uint256 energy; // Life force (ETH)
        uint256 birthBlock; // Block when organism was born
        bool alive; // Living status
        bytes evolutionCode; // Mutable bytecode section
        string ipfsGenomeHash; // IPFS hash for full genome data
    }

    // State variables
    Genome public genome;
    address public factory;
    address public ecosystem;
    uint256 public lastFeedBlock;
    uint256 public reproductionCount;
    mapping(address => bool) public offspring;

    // Constants
    uint256 public constant MIN_REPRODUCTION_ENERGY = 1 ether;
    uint256 public constant ENERGY_DECAY_RATE = 0.001 ether; // Per block
    uint256 public constant MIN_SURVIVAL_ENERGY = 0.1 ether;
    uint256 public constant MUTATION_COST = 0.05 ether;

    // Events
    event OrganismBorn(
        address indexed organism,
        bytes32 dnaHash,
        uint8 generation,
        address indexed parent
    );
    event EnergyReceived(
        address indexed from,
        uint256 amount,
        uint256 newEnergy
    );
    event Reproduced(
        address indexed parent,
        address indexed offspring,
        bytes32 offspringDNA
    );
    event Mutated(bytes32 oldDNA, bytes32 newDNA, uint256[] newGenes);
    event Evolved(address newImplementation, bytes evolutionCode);
    event Died(address indexed organism, uint256 finalAge, uint256 generation);
    event FitnessUpdated(uint256 oldFitness, uint256 newFitness);

    // Modifiers
    modifier onlyAlive() {
        require(genome.alive, "DigitalOrganism: Organism is dead");
        _;
    }

    modifier onlyFactory() {
        require(
            msg.sender == factory,
            "DigitalOrganism: Only factory can call"
        );
        _;
    }

    modifier onlyEcosystem() {
        require(
            msg.sender == ecosystem,
            "DigitalOrganism: Only ecosystem can call"
        );
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes a new organism (called by factory)
     * @param _owner The owner of this organism
     * @param _parentDNA Parent's DNA hash (bytes32(0) for genesis)
     * @param _parentGenes Parent's genes (empty for genesis)
     * @param _generation Generation number
     * @param _ancestors Array of ancestor addresses
     * @param _factory Factory contract address
     * @param _ecosystem Ecosystem contract address
     */
    function initialize(
        address _owner,
        bytes32 _parentDNA,
        uint256[] memory _parentGenes,
        uint8 _generation,
        address[] memory _ancestors,
        address _factory,
        address _ecosystem
    ) public initializer {
        __Ownable_init(_owner);
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();

        factory = _factory;
        ecosystem = _ecosystem;

        // Generate DNA
        bytes32 dnaHash;
        uint256[] memory genes;

        if (_generation == 0) {
            // Genesis organism
            uint256 seed = uint256(
                keccak256(abi.encodePacked(_owner, block.timestamp))
            );
            genes = GeneticLib.generateRandomGenes(seed);
            dnaHash = GeneticLib.generateDNAHash(bytes32(0), seed);
        } else {
            // Offspring - mutate parent genes
            uint256 mutationSeed = uint256(
                keccak256(
                    abi.encodePacked(
                        _parentDNA,
                        block.timestamp,
                        block.prevrandao
                    )
                )
            );
            genes = GeneticLib.mutateGenes(_parentGenes, mutationSeed);
            dnaHash = GeneticLib.generateDNAHash(_parentDNA, mutationSeed);
        }

        // Initialize genome
        genome.dnaHash = dnaHash;
        genome.genes = genes;
        genome.generation = _generation;
        genome.ancestors = _ancestors;
        genome.fitness = GeneticLib.calculateFitness(genes, 0, 0);
        genome.energy = 0;
        genome.birthBlock = block.number;
        genome.alive = true;
        genome.evolutionCode = "";
        genome.ipfsGenomeHash = "";

        lastFeedBlock = block.number;

        emit OrganismBorn(address(this), dnaHash, _generation, _owner);
    }

    /**
     * @notice Feed the organism with energy (ETH)
     * @dev Increases energy and updates fitness
     */
    function feed() external payable onlyAlive nonReentrant {
        require(msg.value > 0, "DigitalOrganism: Must send ETH");

        genome.energy += msg.value;
        lastFeedBlock = block.number;

        // Update fitness based on new energy
        _updateFitness();

        emit EnergyReceived(msg.sender, msg.value, genome.energy);
    }

    /**
     * @notice Reproduce and create offspring
     * @dev Consumes energy and creates new organism through factory
     */
    function reproduce() external onlyOwner onlyAlive nonReentrant {
        require(
            genome.energy >= MIN_REPRODUCTION_ENERGY,
            "DigitalOrganism: Insufficient energy to reproduce"
        );

        // Deduct reproduction cost
        uint256 reproductionCost = MIN_REPRODUCTION_ENERGY / 2;
        genome.energy -= reproductionCost;

        // Create new ancestor array
        address[] memory newAncestors = new address[](
            genome.ancestors.length + 1
        );
        for (uint256 i = 0; i < genome.ancestors.length; i++) {
            newAncestors[i] = genome.ancestors[i];
        }
        newAncestors[genome.ancestors.length] = address(this);

        // Call factory to create offspring
        IOrganismFactory(factory).createOffspring(
            owner(),
            genome.dnaHash,
            genome.genes,
            genome.generation + 1,
            newAncestors
        );

        reproductionCount++;

        emit Reproduced(address(this), msg.sender, genome.dnaHash);
    }

    /**
     * @notice Manually trigger mutation
     * @dev Costs energy and updates genes randomly
     */
    function mutate() external onlyOwner onlyAlive nonReentrant {
        require(
            genome.energy >= MUTATION_COST,
            "DigitalOrganism: Insufficient energy to mutate"
        );

        genome.energy -= MUTATION_COST;

        bytes32 oldDNA = genome.dnaHash;

        // Apply mutation
        uint256 mutationSeed = uint256(
            keccak256(
                abi.encodePacked(
                    genome.dnaHash,
                    block.timestamp,
                    block.prevrandao,
                    msg.sender
                )
            )
        );

        genome.genes = GeneticLib.mutateGenes(genome.genes, mutationSeed);
        genome.dnaHash = GeneticLib.generateDNAHash(
            genome.dnaHash,
            mutationSeed
        );

        // Update fitness
        _updateFitness();

        emit Mutated(oldDNA, genome.dnaHash, genome.genes);
    }

    /**
     * @notice Check if organism should die from energy depletion
     * @dev Called by ecosystem or anyone to check death conditions
     */
    function checkDeath() external {
        if (!genome.alive) return;

        // Calculate energy decay
        uint256 blocksSinceLastFeed = block.number - lastFeedBlock;
        uint256 energyDecay = blocksSinceLastFeed * ENERGY_DECAY_RATE;

        if (genome.energy <= energyDecay || genome.energy < MIN_SURVIVAL_ENERGY) {
            _die();
        }
    }

    /**
     * @notice Compete with another organism
     * @param opponent Address of opponent organism
     * @return won True if this organism won
     */
    function compete(
        address opponent
    ) external onlyEcosystem onlyAlive returns (bool won) {
        DigitalOrganism opponentOrganism = DigitalOrganism(payable(opponent));

        // Update both fitnesses
        _updateFitness();

        // Compare fitness scores
        uint256 opponentFitness = opponentOrganism.getFitness();

        if (genome.fitness >= opponentFitness) {
            // This organism wins - gain energy from opponent
            uint256 energyGain = 0.1 ether;
            genome.energy += energyGain;
            _updateFitness();
            return true;
        } else {
            // This organism loses - lose some energy
            if (genome.energy > 0.1 ether) {
                genome.energy -= 0.1 ether;
                _updateFitness();
            } else {
                _die();
            }
            return false;
        }
    }

    /**
     * @notice Evolve the organism by upgrading implementation
     * @param newImplementation New implementation address
     * @param _evolutionCode Custom evolution bytecode
     */
    function evolve(
        address newImplementation,
        bytes memory _evolutionCode
    ) external onlyOwner onlyAlive {
        require(
            newImplementation != address(0),
            "DigitalOrganism: Invalid implementation"
        );

        genome.evolutionCode = _evolutionCode;
        _authorizeUpgrade(newImplementation);

        emit Evolved(newImplementation, _evolutionCode);
    }

    /**
     * @notice Update IPFS genome hash
     * @param _ipfsHash IPFS hash of full genome data
     */
    function setIPFSGenomeHash(
        string memory _ipfsHash
    ) external onlyOwner onlyAlive {
        genome.ipfsGenomeHash = _ipfsHash;
    }

    /**
     * @notice Get current age in blocks
     */
    function getAge() public view returns (uint256) {
        return block.number - genome.birthBlock;
    }

    /**
     * @notice Get current fitness score
     */
    function getFitness() public view returns (uint256) {
        return genome.fitness;
    }

    /**
     * @notice Get all genes
     */
    function getGenes() public view returns (uint256[] memory) {
        return genome.genes;
    }

    /**
     * @notice Get ancestors
     */
    function getAncestors() public view returns (address[] memory) {
        return genome.ancestors;
    }

    /**
     * @notice Get DNA hash
     */
    function getDNAHash() public view returns (bytes32) {
        return genome.dnaHash;
    }

    /**
     * @notice Get generation
     */
    function getGeneration() public view returns (uint8) {
        return genome.generation;
    }

    /**
     * @notice Get energy
     */
    function getEnergy() public view returns (uint256) {
        return genome.energy;
    }

    /**
     * @notice Check if organism is alive
     */
    function isAlive() public view returns (bool) {
        return genome.alive;
    }

    /**
     * @notice Get full genome data
     */
    function getGenome() public view returns (
        bytes32 dnaHash,
        uint8 generation,
        uint256 fitness,
        uint256 energy,
        uint256 birthBlock,
        bool alive
    ) {
        return (
            genome.dnaHash,
            genome.generation,
            genome.fitness,
            genome.energy,
            genome.birthBlock,
            genome.alive
        );
    }

    /**
     * @notice Internal function to update fitness
     */
    function _updateFitness() internal {
        uint256 oldFitness = genome.fitness;
        genome.fitness = GeneticLib.calculateFitness(
            genome.genes,
            genome.energy,
            getAge()
        );

        emit FitnessUpdated(oldFitness, genome.fitness);
    }

    /**
     * @notice Internal function to handle organism death
     */
    function _die() internal {
        genome.alive = false;
        uint256 age = getAge();

        emit Died(address(this), age, genome.generation);

        // Transfer remaining energy to owner
        if (genome.energy > 0) {
            uint256 remainingEnergy = genome.energy;
            genome.energy = 0;
            (bool success, ) = owner().call{value: remainingEnergy}("");
            require(success, "DigitalOrganism: Energy transfer failed");
        }
    }

    /**
     * @notice Authorize upgrade (required by UUPS)
     */
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    /**
     * @notice Receive function to accept ETH
     */
    receive() external payable {
        if (genome.alive && msg.value > 0) {
            genome.energy += msg.value;
            lastFeedBlock = block.number;
            _updateFitness();
            emit EnergyReceived(msg.sender, msg.value, genome.energy);
        }
    }
}

/**
 * @notice Interface for OrganismFactory
 */
interface IOrganismFactory {
    function createOffspring(
        address owner,
        bytes32 parentDNA,
        uint256[] memory parentGenes,
        uint8 generation,
        address[] memory ancestors
    ) external returns (address);
}
