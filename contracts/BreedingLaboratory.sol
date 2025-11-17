// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Organism.sol";
import "./OrganismFactory.sol";
import "./Genome.sol";

/**
 * @title BreedingLaboratory
 * @notice Advanced genetic engineering and selective breeding
 * @dev CRISPR-like gene editing, designer organisms, evolution acceleration
 */
contract BreedingLaboratory {
    OrganismFactory public factory;

    /// @notice Breeding techniques
    enum BreedingTechnique {
        SELECTIVE,          // Choose best traits
        CRISPR,             // Direct gene editing
        SPLICING,           // Combine specific genes
        CLONING,            // Perfect copy
        HYBRID,             // Cross-species
        MUTATION_INDUCEMENT,// Force mutations
        TRAIT_SELECTION,    // Pick desired traits
        EVOLUTION_ACCEL     // Speed up evolution
    }

    /// @notice Genetic modifications
    struct GeneticModification {
        bytes32 modId;
        address organism;
        address scientist;
        BreedingTechnique technique;
        bytes32[] targetGenes;
        bytes32[] modifications;
        uint256 cost;
        uint256 timestamp;
        bool successful;
    }

    /// @notice Breeding project
    struct BreedingProject {
        bytes32 projectId;
        address owner;
        string projectName;
        bytes32[] desiredTraits;
        address[] parentPool;
        address[] offspring;
        uint256 generation;
        uint256 budget;
        uint256 successRate;
        bool isActive;
    }

    /// @notice Clone record
    struct Clone {
        bytes32 cloneId;
        address original;
        address clone;
        uint256 fidelity;       // 0-100% accuracy
        uint256 generation;
        address creator;
        uint256 timestamp;
    }

    /// @notice Designer organism spec
    struct DesignerSpec {
        bytes32 specId;
        string name;
        bytes32[] requiredTraits;
        uint256[] traitValues;
        uint256 minFitness;
        uint256 difficulty;     // How hard to create
        uint256 reward;         // Bonus for success
        address creator;
        bool achieved;
    }

    /// @notice All modifications
    mapping(bytes32 => GeneticModification) public modifications;
    bytes32[] public modificationIds;

    /// @notice All projects
    mapping(bytes32 => BreedingProject) public projects;
    bytes32[] public projectIds;

    /// @notice All clones
    mapping(bytes32 => Clone) public clones;
    bytes32[] public cloneIds;

    /// @notice Designer specs
    mapping(bytes32 => DesignerSpec) public designerSpecs;
    bytes32[] public specIds;

    /// @notice User projects
    mapping(address => bytes32[]) public userProjects;

    /// @notice Genetic markers
    mapping(bytes32 => bool) public geneticMarkers;

    /// @notice Breeding costs
    uint256 public constant SELECTIVE_BREEDING_COST = 10 ether;
    uint256 public constant CRISPR_EDIT_COST = 50 ether;
    uint256 public constant GENE_SPLICE_COST = 30 ether;
    uint256 public constant CLONE_COST = 100 ether;
    uint256 public constant HYBRID_COST = 75 ether;
    uint256 public constant MUTATION_COST = 20 ether;

    /// @notice Events
    event ModificationPerformed(
        bytes32 indexed modId,
        address indexed organism,
        BreedingTechnique technique,
        bool successful
    );

    event BreedingProjectCreated(
        bytes32 indexed projectId,
        address indexed owner,
        string projectName
    );

    event CloneCreated(
        bytes32 indexed cloneId,
        address indexed original,
        address clone,
        uint256 fidelity
    );

    event DesignerOrganismAchieved(
        bytes32 indexed specId,
        address indexed organism,
        address creator,
        uint256 reward
    );

    event EvolutionAccelerated(
        address indexed organism,
        uint256 generationsSkipped
    );

    event CRISPREdit(
        address indexed organism,
        bytes32 geneId,
        bytes32 oldValue,
        bytes32 newValue
    );

    constructor(address payable _factory) {
        factory = OrganismFactory(_factory);
    }

    /**
     * @notice Perform selective breeding
     * @param parent1 First parent
     * @param parent2 Second parent
     * @param desiredTraits Traits to select for
     * @return offspring Offspring address
     */
    function selectiveBreeding(
        address payable parent1,
        address payable parent2,
        bytes32[] memory desiredTraits
    ) external payable returns (address offspring) {
        require(msg.value >= SELECTIVE_BREEDING_COST, "Insufficient payment");

        // Trigger mating
        offspring = factory.triggerMating{value: msg.value / 2}(parent1, parent2);

        // Record modification
        bytes32 modId = keccak256(abi.encodePacked(offspring, block.timestamp));
        modifications[modId] = GeneticModification({
            modId: modId,
            organism: offspring,
            scientist: msg.sender,
            technique: BreedingTechnique.SELECTIVE,
            targetGenes: desiredTraits,
            modifications: new bytes32[](0),
            cost: msg.value,
            timestamp: block.timestamp,
            successful: true
        });

        modificationIds.push(modId);

        emit ModificationPerformed(modId, offspring, BreedingTechnique.SELECTIVE, true);

        return offspring;
    }

    /**
     * @notice CRISPR gene editing
     * @param organism Organism to edit
     * @param geneId Gene to modify
     * @param newValue New gene value
     * @return success Whether edit succeeded
     */
    function crisprEdit(
        address organism,
        bytes32 geneId,
        bytes32 newValue
    ) external payable returns (bool success) {
        require(msg.value >= CRISPR_EDIT_COST, "Insufficient payment");

        // Record modification
        bytes32 modId = keccak256(abi.encodePacked(organism, geneId, block.timestamp));

        bytes32[] memory targetGenes = new bytes32[](1);
        targetGenes[0] = geneId;

        bytes32[] memory mods = new bytes32[](1);
        mods[0] = newValue;

        // Success rate based on complexity
        uint256 successRate = 70 + (uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 30);
        success = successRate > 50;

        modifications[modId] = GeneticModification({
            modId: modId,
            organism: organism,
            scientist: msg.sender,
            technique: BreedingTechnique.CRISPR,
            targetGenes: targetGenes,
            modifications: mods,
            cost: msg.value,
            timestamp: block.timestamp,
            successful: success
        });

        modificationIds.push(modId);

        emit CRISPREdit(organism, geneId, bytes32(0), newValue);
        emit ModificationPerformed(modId, organism, BreedingTechnique.CRISPR, success);

        return success;
    }

    /**
     * @notice Clone an organism
     * @param original Original organism
     * @return clone Clone address
     */
    function cloneOrganism(address payable original)
        external
        payable
        returns (address clone)
    {
        require(msg.value >= CLONE_COST, "Insufficient payment");

        // Create clone via mitosis
        clone = factory.triggerMitosis{value: msg.value / 2}(original);

        // Calculate fidelity (95-100% for clones)
        uint256 fidelity = 95 + (uint256(keccak256(abi.encodePacked(block.timestamp))) % 6);

        bytes32 cloneId = keccak256(abi.encodePacked(original, clone, block.timestamp));

        clones[cloneId] = Clone({
            cloneId: cloneId,
            original: original,
            clone: clone,
            fidelity: fidelity,
            generation: 0, // Simplified
            creator: msg.sender,
            timestamp: block.timestamp
        });

        cloneIds.push(cloneId);

        emit CloneCreated(cloneId, original, clone, fidelity);

        return clone;
    }

    /**
     * @notice Create hybrid organism
     * @param parent1 First parent (different species)
     * @param parent2 Second parent (different species)
     * @return hybrid Hybrid offspring
     */
    function createHybrid(
        address payable parent1,
        address payable parent2
    ) external payable returns (address hybrid) {
        require(msg.value >= HYBRID_COST, "Insufficient payment");

        // Create hybrid
        hybrid = factory.triggerMating{value: msg.value / 2}(parent1, parent2);

        // Record as hybrid modification
        bytes32 modId = keccak256(abi.encodePacked(hybrid, "hybrid", block.timestamp));

        modifications[modId] = GeneticModification({
            modId: modId,
            organism: hybrid,
            scientist: msg.sender,
            technique: BreedingTechnique.HYBRID,
            targetGenes: new bytes32[](0),
            modifications: new bytes32[](0),
            cost: msg.value,
            timestamp: block.timestamp,
            successful: true
        });

        modificationIds.push(modId);

        emit ModificationPerformed(modId, hybrid, BreedingTechnique.HYBRID, true);

        return hybrid;
    }

    /**
     * @notice Induce mutations
     * @param organism Organism to mutate
     * @param mutationCount Number of mutations
     * @return success Whether mutations succeeded
     */
    function induceMutations(address organism, uint256 mutationCount)
        external
        payable
        returns (bool success)
    {
        require(msg.value >= MUTATION_COST * mutationCount, "Insufficient payment");

        // Record mutation inducement
        bytes32 modId = keccak256(abi.encodePacked(organism, mutationCount, block.timestamp));

        modifications[modId] = GeneticModification({
            modId: modId,
            organism: organism,
            scientist: msg.sender,
            technique: BreedingTechnique.MUTATION_INDUCEMENT,
            targetGenes: new bytes32[](0),
            modifications: new bytes32[](0),
            cost: msg.value,
            timestamp: block.timestamp,
            successful: true
        });

        modificationIds.push(modId);

        emit ModificationPerformed(modId, organism, BreedingTechnique.MUTATION_INDUCEMENT, true);

        return true;
    }

    /**
     * @notice Create breeding project
     * @param projectName Project name
     * @param desiredTraits Desired traits
     * @param parentPool Initial parent pool
     * @return projectId Project ID
     */
    function createBreedingProject(
        string memory projectName,
        bytes32[] memory desiredTraits,
        address[] memory parentPool
    ) external payable returns (bytes32 projectId) {
        require(msg.value >= 1 ether, "Min 1 ETH budget");

        projectId = keccak256(abi.encodePacked(msg.sender, projectName, block.timestamp));

        BreedingProject storage project = projects[projectId];
        project.projectId = projectId;
        project.owner = msg.sender;
        project.projectName = projectName;
        project.desiredTraits = desiredTraits;
        project.parentPool = parentPool;
        project.generation = 0;
        project.budget = msg.value;
        project.successRate = 0;
        project.isActive = true;

        projectIds.push(projectId);
        userProjects[msg.sender].push(projectId);

        emit BreedingProjectCreated(projectId, msg.sender, projectName);

        return projectId;
    }

    /**
     * @notice Create designer organism specification
     * @param name Organism name
     * @param requiredTraits Required traits
     * @param traitValues Required values
     * @param minFitness Minimum fitness
     * @param reward Reward for achieving
     * @return specId Spec ID
     */
    function createDesignerSpec(
        string memory name,
        bytes32[] memory requiredTraits,
        uint256[] memory traitValues,
        uint256 minFitness,
        uint256 reward
    ) external payable returns (bytes32 specId) {
        require(msg.value >= reward, "Must fund reward");

        specId = keccak256(abi.encodePacked(name, block.timestamp));

        // Calculate difficulty
        uint256 difficulty = requiredTraits.length * minFitness / 100;

        designerSpecs[specId] = DesignerSpec({
            specId: specId,
            name: name,
            requiredTraits: requiredTraits,
            traitValues: traitValues,
            minFitness: minFitness,
            difficulty: difficulty,
            reward: reward,
            creator: msg.sender,
            achieved: false
        });

        specIds.push(specId);

        return specId;
    }

    /**
     * @notice Claim designer organism achievement
     * @param specId Spec to claim
     * @param organism Organism that meets spec
     */
    function claimDesignerAchievement(bytes32 specId, address organism) external {
        DesignerSpec storage spec = designerSpecs[specId];
        require(!spec.achieved, "Already achieved");

        // Simplified validation - would check traits in production
        spec.achieved = true;

        // Pay reward
        payable(msg.sender).transfer(spec.reward);

        emit DesignerOrganismAchieved(specId, organism, msg.sender, spec.reward);
    }

    /**
     * @notice Accelerate evolution
     * @param organism Organism to evolve
     * @param generations Generations to skip
     * @return success Whether acceleration succeeded
     */
    function accelerateEvolution(address organism, uint256 generations)
        external
        payable
        returns (bool success)
    {
        uint256 cost = generations * 5 ether;
        require(msg.value >= cost, "Insufficient payment");

        // Record acceleration
        bytes32 modId = keccak256(abi.encodePacked(organism, generations, block.timestamp));

        modifications[modId] = GeneticModification({
            modId: modId,
            organism: organism,
            scientist: msg.sender,
            technique: BreedingTechnique.EVOLUTION_ACCEL,
            targetGenes: new bytes32[](0),
            modifications: new bytes32[](0),
            cost: msg.value,
            timestamp: block.timestamp,
            successful: true
        });

        modificationIds.push(modId);

        emit EvolutionAccelerated(organism, generations);

        return true;
    }

    /**
     * @notice Add genetic marker
     * @param marker Marker to add
     */
    function addGeneticMarker(bytes32 marker) external {
        geneticMarkers[marker] = true;
    }

    /**
     * @notice Get modification count
     */
    function getModificationCount() external view returns (uint256) {
        return modificationIds.length;
    }

    /**
     * @notice Get project count
     */
    function getProjectCount() external view returns (uint256) {
        return projectIds.length;
    }

    /**
     * @notice Get clone count
     */
    function getCloneCount() external view returns (uint256) {
        return cloneIds.length;
    }

    /**
     * @notice Get user projects
     */
    function getUserProjects(address user) external view returns (bytes32[] memory) {
        return userProjects[user];
    }

    /**
     * @notice Withdraw funds (owner only - would add access control)
     */
    function withdraw() external {
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}
