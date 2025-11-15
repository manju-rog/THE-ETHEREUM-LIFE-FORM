// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title GeneticLib
 * @notice Library for genetic operations, mutations, and DNA manipulation
 * @dev Provides the fundamental building blocks for digital evolution
 */
library GeneticLib {
    // Constants for genetic operations
    uint256 constant DNA_LENGTH = 8; // Number of genes in a genome
    uint256 constant MUTATION_RATE = 100; // 1% mutation rate (100/10000)
    uint256 constant MAX_MUTATION_DELTA = 1000; // Max change per mutation

    /**
     * @notice Generates a random DNA hash based on parent DNA and block entropy
     * @param parentDNA The parent's DNA hash
     * @param salt Additional randomness salt
     * @return A new unique DNA hash
     */
    function generateDNAHash(
        bytes32 parentDNA,
        uint256 salt
    ) internal view returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                parentDNA,
                block.timestamp,
                block.prevrandao,
                block.number,
                salt
            )
        );
    }

    /**
     * @notice Generates initial random genes for a new organism
     * @param seed Random seed for generation
     * @return genes Array of gene values
     */
    function generateRandomGenes(
        uint256 seed
    ) internal view returns (uint256[] memory genes) {
        genes = new uint256[](DNA_LENGTH);

        for (uint256 i = 0; i < DNA_LENGTH; i++) {
            genes[i] = uint256(
                keccak256(
                    abi.encodePacked(
                        seed,
                        i,
                        block.timestamp,
                        block.prevrandao
                    )
                )
            ) % 10000; // Gene values 0-9999
        }

        return genes;
    }

    /**
     * @notice Applies mutations to genes during reproduction
     * @param parentGenes The parent's genes
     * @param mutationSeed Random seed for mutation
     * @return mutatedGenes New genes with mutations applied
     */
    function mutateGenes(
        uint256[] memory parentGenes,
        uint256 mutationSeed
    ) internal view returns (uint256[] memory mutatedGenes) {
        mutatedGenes = new uint256[](parentGenes.length);

        for (uint256 i = 0; i < parentGenes.length; i++) {
            // Determine if this gene mutates
            uint256 mutationRoll = uint256(
                keccak256(abi.encodePacked(mutationSeed, i, block.timestamp))
            ) % 10000;

            if (mutationRoll < MUTATION_RATE) {
                // Gene mutates!
                int256 delta = int256(
                    uint256(
                        keccak256(abi.encodePacked(mutationSeed, i, "delta"))
                    ) % (MAX_MUTATION_DELTA * 2)
                ) - int256(MAX_MUTATION_DELTA);

                int256 newValue = int256(parentGenes[i]) + delta;

                // Clamp to valid range
                if (newValue < 0) newValue = 0;
                if (newValue > 10000) newValue = 10000;

                mutatedGenes[i] = uint256(newValue);
            } else {
                // No mutation, copy parent gene
                mutatedGenes[i] = parentGenes[i];
            }
        }

        return mutatedGenes;
    }

    /**
     * @notice Crosses over genes from two parents
     * @param parent1Genes First parent's genes
     * @param parent2Genes Second parent's genes
     * @param crossoverSeed Random seed for crossover
     * @return offspring genes Result of genetic crossover
     */
    function crossover(
        uint256[] memory parent1Genes,
        uint256[] memory parent2Genes,
        uint256 crossoverSeed
    ) internal pure returns (uint256[] memory) {
        require(
            parent1Genes.length == parent2Genes.length,
            "GeneticLib: Parent genes must have same length"
        );

        uint256[] memory offspringGenes = new uint256[](parent1Genes.length);

        // Random crossover point
        uint256 crossoverPoint = crossoverSeed % parent1Genes.length;

        for (uint256 i = 0; i < parent1Genes.length; i++) {
            if (i < crossoverPoint) {
                offspringGenes[i] = parent1Genes[i];
            } else {
                offspringGenes[i] = parent2Genes[i];
            }
        }

        return offspringGenes;
    }

    /**
     * @notice Calculates fitness based on gene values and environmental factors
     * @param genes The organism's genes
     * @param energy Current energy level
     * @param age Age in blocks
     * @return fitness Calculated fitness score
     */
    function calculateFitness(
        uint256[] memory genes,
        uint256 energy,
        uint256 age
    ) internal pure returns (uint256 fitness) {
        // Base fitness from genes (sum of all gene values)
        uint256 geneticFitness = 0;
        for (uint256 i = 0; i < genes.length; i++) {
            geneticFitness += genes[i];
        }

        // Energy bonus (logarithmic scaling)
        uint256 energyBonus = energy > 0 ? sqrt(energy) * 100 : 0;

        // Age penalty (older organisms are less fit)
        uint256 agePenalty = age * 10;

        // Calculate total fitness
        fitness = geneticFitness + energyBonus;
        if (fitness > agePenalty) {
            fitness -= agePenalty;
        } else {
            fitness = 0;
        }

        return fitness;
    }

    /**
     * @notice Square root function for fitness calculations
     * @param x Input value
     * @return y Square root of x
     */
    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    /**
     * @notice Encodes genes into a compact bytes representation
     * @param genes Array of gene values
     * @return Encoded gene data
     */
    function encodeGenes(
        uint256[] memory genes
    ) internal pure returns (bytes memory) {
        return abi.encode(genes);
    }

    /**
     * @notice Decodes genes from bytes representation
     * @param data Encoded gene data
     * @return genes Decoded gene array
     */
    function decodeGenes(
        bytes memory data
    ) internal pure returns (uint256[] memory genes) {
        return abi.decode(data, (uint256[]));
    }
}
