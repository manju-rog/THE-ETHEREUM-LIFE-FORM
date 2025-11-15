// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./DigitalOrganism.sol";

/**
 * @title OrganismFactory
 * @notice Factory for creating and managing digital organisms
 * @dev Uses CREATE2 for deterministic organism addresses
 */
contract OrganismFactory is Ownable, ReentrancyGuard {
    // State variables
    address public organismImplementation;
    address public ecosystem;
    uint256 public totalOrganisms;
    uint256 public totalAlive;

    mapping(address => bool) public isOrganism;
    mapping(address => address[]) public ownerToOrganisms;
    address[] public allOrganisms;

    // Events
    event OrganismCreated(
        address indexed organism,
        address indexed owner,
        uint8 generation,
        bytes32 dnaHash
    );
    event ImplementationUpdated(address indexed newImplementation);
    event EcosystemSet(address indexed ecosystem);

    constructor(address _initialOwner) Ownable(_initialOwner) {
        // Deploy initial implementation
        organismImplementation = address(new DigitalOrganism());
    }

    /**
     * @notice Create a genesis organism (generation 0)
     * @param owner Owner of the new organism
     * @return organism Address of created organism
     */
    function createGenesisOrganism(
        address owner
    ) external nonReentrant returns (address organism) {
        require(owner != address(0), "OrganismFactory: Invalid owner");

        // Generate unique salt for CREATE2
        bytes32 salt = keccak256(
            abi.encodePacked(owner, totalOrganisms, block.timestamp)
        );

        // Prepare initialization data
        bytes memory initData = abi.encodeWithSelector(
            DigitalOrganism.initialize.selector,
            owner, // owner
            bytes32(0), // parentDNA (none for genesis)
            new uint256[](0), // parentGenes (none for genesis)
            0, // generation
            new address[](0), // ancestors (none for genesis)
            address(this), // factory
            ecosystem // ecosystem
        );

        // Deploy proxy using CREATE2
        organism = address(
            new ERC1967Proxy{salt: salt}(organismImplementation, initData)
        );

        // Register organism
        _registerOrganism(organism, owner);

        DigitalOrganism org = DigitalOrganism(payable(organism));
        emit OrganismCreated(
            organism,
            owner,
            0,
            org.getDNAHash()
        );

        return organism;
    }

    /**
     * @notice Create offspring organism (called by parent organisms)
     * @param owner Owner of the offspring
     * @param parentDNA Parent's DNA hash
     * @param parentGenes Parent's genes
     * @param generation Generation number
     * @param ancestors Array of ancestor addresses
     * @return organism Address of created offspring
     */
    function createOffspring(
        address owner,
        bytes32 parentDNA,
        uint256[] memory parentGenes,
        uint8 generation,
        address[] memory ancestors
    ) external nonReentrant returns (address organism) {
        require(
            isOrganism[msg.sender],
            "OrganismFactory: Only organisms can create offspring"
        );
        require(owner != address(0), "OrganismFactory: Invalid owner");

        // Generate unique salt for CREATE2
        bytes32 salt = keccak256(
            abi.encodePacked(
                owner,
                totalOrganisms,
                block.timestamp,
                msg.sender,
                parentDNA
            )
        );

        // Prepare initialization data
        bytes memory initData = abi.encodeWithSelector(
            DigitalOrganism.initialize.selector,
            owner,
            parentDNA,
            parentGenes,
            generation,
            ancestors,
            address(this),
            ecosystem
        );

        // Deploy proxy using CREATE2
        organism = address(
            new ERC1967Proxy{salt: salt}(organismImplementation, initData)
        );

        // Register organism
        _registerOrganism(organism, owner);

        DigitalOrganism org = DigitalOrganism(payable(organism));
        emit OrganismCreated(
            organism,
            owner,
            generation,
            org.getDNAHash()
        );

        return organism;
    }

    /**
     * @notice Batch create multiple genesis organisms
     * @param owners Array of owner addresses
     * @return organisms Array of created organism addresses
     */
    function batchCreateGenesis(
        address[] memory owners
    ) external nonReentrant returns (address[] memory organisms) {
        organisms = new address[](owners.length);

        for (uint256 i = 0; i < owners.length; i++) {
            organisms[i] = this.createGenesisOrganism(owners[i]);
        }

        return organisms;
    }

    /**
     * @notice Update the organism implementation for future deployments
     * @param newImplementation New implementation address
     */
    function updateImplementation(
        address newImplementation
    ) external onlyOwner {
        require(
            newImplementation != address(0),
            "OrganismFactory: Invalid implementation"
        );

        organismImplementation = newImplementation;
        emit ImplementationUpdated(newImplementation);
    }

    /**
     * @notice Set the ecosystem contract address
     * @param _ecosystem Ecosystem contract address
     */
    function setEcosystem(address _ecosystem) external onlyOwner {
        require(
            _ecosystem != address(0),
            "OrganismFactory: Invalid ecosystem"
        );

        ecosystem = _ecosystem;
        emit EcosystemSet(_ecosystem);
    }

    /**
     * @notice Get all organisms owned by an address
     * @param owner Owner address
     * @return Array of organism addresses
     */
    function getOrganismsByOwner(
        address owner
    ) external view returns (address[] memory) {
        return ownerToOrganisms[owner];
    }

    /**
     * @notice Get all organisms
     * @return Array of all organism addresses
     */
    function getAllOrganisms() external view returns (address[] memory) {
        return allOrganisms;
    }

    /**
     * @notice Get alive organisms count
     * @return Count of alive organisms
     */
    function getAliveCount() external view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < allOrganisms.length; i++) {
            DigitalOrganism org = DigitalOrganism(payable(allOrganisms[i]));
            if (org.isAlive()) {
                count++;
            }
        }
        return count;
    }

    /**
     * @notice Get organism details
     * @param organism Organism address
     * @return dnaHash DNA hash
     * @return generation Generation number
     * @return fitness Fitness score
     * @return energy Energy level
     * @return alive Living status
     */
    function getOrganismDetails(
        address organism
    )
        external
        view
        returns (
            bytes32 dnaHash,
            uint8 generation,
            uint256 fitness,
            uint256 energy,
            bool alive
        )
    {
        require(
            isOrganism[organism],
            "OrganismFactory: Not a valid organism"
        );

        DigitalOrganism org = DigitalOrganism(payable(organism));

        return (
            org.getDNAHash(),
            org.getGeneration(),
            org.getFitness(),
            org.getEnergy(),
            org.isAlive()
        );
    }

    /**
     * @notice Internal function to register a new organism
     * @param organism Organism address
     * @param owner Owner address
     */
    function _registerOrganism(address organism, address owner) internal {
        isOrganism[organism] = true;
        ownerToOrganisms[owner].push(organism);
        allOrganisms.push(organism);
        totalOrganisms++;
        totalAlive++;
    }

    /**
     * @notice Predict organism address before deployment
     * @param owner Owner address
     * @param salt Salt for CREATE2
     * @return predicted Predicted organism address
     */
    function predictOrganismAddress(
        address owner,
        bytes32 salt
    ) external view returns (address predicted) {
        bytes memory initData = abi.encodeWithSelector(
            DigitalOrganism.initialize.selector,
            owner,
            bytes32(0),
            new uint256[](0),
            0,
            new address[](0),
            address(this),
            ecosystem
        );

        bytes memory bytecode = abi.encodePacked(
            type(ERC1967Proxy).creationCode,
            abi.encode(organismImplementation, initData)
        );

        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                keccak256(bytecode)
            )
        );

        return address(uint160(uint256(hash)));
    }
}
