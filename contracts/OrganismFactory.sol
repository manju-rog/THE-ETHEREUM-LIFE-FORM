// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Organism.sol";
import "./PopulationRegistry.sol";
import "./EvolutionEngine.sol";

contract OrganismFactory {
    PopulationRegistry public registry;
    EvolutionEngine public evolutionEngine;
    address[] public genesisOrganisms;
    address public owner;

    uint256 public constant MIN_CREATION_ENERGY = 100 ether;

    event OrganismCreated(address indexed organism, address indexed creator, uint256 generation);

    constructor() {
        owner = msg.sender;
        registry = new PopulationRegistry();
        evolutionEngine = new EvolutionEngine(address(registry));
    }

    function createGenesisOrganism() external payable returns (address) {
        require(msg.value >= MIN_CREATION_ENERGY, "Insufficient energy");

        Organism organism = new Organism(
            address(registry),
            address(0),
            address(0),
            0,
            msg.value
        );

        genesisOrganisms.push(address(organism));
        emit OrganismCreated(address(organism), msg.sender, 0);
        return address(organism);
    }

    function createGenesisPopulation(uint256 count) external payable returns (address[] memory) {
        require(count > 0 && count <= 100, "Count 1-100");
        require(msg.value >= MIN_CREATION_ENERGY * count, "Insufficient energy");

        address[] memory organisms = new address[](count);
        uint256 energyPerOrganism = msg.value / count;

        for (uint256 i = 0; i < count; i++) {
            Organism organism = new Organism(
                address(registry),
                address(0),
                address(0),
                0,
                energyPerOrganism
            );
            organisms[i] = address(organism);
            genesisOrganisms.push(organisms[i]);
            emit OrganismCreated(organisms[i], msg.sender, 0);
        }

        return organisms;
    }

    function triggerMitosis(address payable parent) external payable returns (address) {
        Organism parentOrg = Organism(parent);
        require(parentOrg.state() == Organism.State.ADULT || parentOrg.state() == Organism.State.ELDER, "Must be adult");

        uint256 energy = msg.value > 0 ? msg.value : 100 ether;

        Organism child = new Organism(
            address(registry),
            parent,
            address(0),
            parentOrg.generation() + 1,
            energy
        );

        parentOrg.addOffspring(address(child));
        emit OrganismCreated(address(child), msg.sender, parentOrg.generation() + 1);
        return address(child);
    }

    function triggerMating(address payable parent1, address payable parent2) external payable returns (address) {
        Organism org1 = Organism(parent1);
        Organism org2 = Organism(parent2);

        require(org1.state() == Organism.State.ADULT || org1.state() == Organism.State.ELDER, "Parent1 must be adult");
        require(org2.state() == Organism.State.ADULT || org2.state() == Organism.State.ELDER, "Parent2 must be adult");

        uint256 newGen = org1.generation() > org2.generation() ? org1.generation() + 1 : org2.generation() + 1;
        uint256 energy = msg.value > 0 ? msg.value : 150 ether;

        Organism child = new Organism(
            address(registry),
            parent1,
            parent2,
            newGen,
            energy
        );

        org1.addOffspring(address(child));
        org2.addOffspring(address(child));
        emit OrganismCreated(address(child), msg.sender, newGen);
        return address(child);
    }

    function getEcosystemStats() external view returns (
        uint256 totalOrganisms,
        uint256 livingOrganisms,
        uint256 avgGeneration,
        uint256 avgFitness,
        uint256 genesisCount
    ) {
        (totalOrganisms, livingOrganisms, avgGeneration, avgFitness) = registry.getPopulationStats();
        genesisCount = genesisOrganisms.length;
    }

    function getGenesisOrganisms() external view returns (address[] memory) {
        return genesisOrganisms;
    }

    receive() external payable {}
}
