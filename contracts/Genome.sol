// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title Genome
 * @notice Genetic data structures and utilities for the Ethereum Life Form
 * @dev Implements a digital genome with genes, chromosomes, and genetic operations
 */
library Genome {
    /// @notice Mutation types that can occur during evolution
    enum MutationType {
        POINT,          // Single gene changes
        INSERTION,      // New gene sequences
        DELETION,       // Gene removal
        INVERSION,      // Sequence reversal
        DUPLICATION,    // Gene copying
        TRANSLOCATION,  // Gene moving
        FRAMESHIFT,     // Reading frame changes
        CHROMOSOMAL     // Large-scale changes
    }

    /// @notice Individual gene structure
    struct Gene {
        uint256 value;          // Gene value (can represent traits, behaviors, etc.)
        uint8 dominance;        // Dominance level (0-255)
        bool expressed;         // Whether gene is currently active
        uint32 mutationRate;    // Probability of mutation (0-1000000 = 0-100%)
    }

    /// @notice Chromosome structure containing multiple genes
    struct Chromosome {
        Gene[] genes;
        uint256 length;
        bytes32 hash;           // Hash of chromosome for quick comparison
    }

    /// @notice Complete genome structure
    struct GenomeData {
        Chromosome[] chromosomes;
        uint256 generation;     // Generation number
        uint256 mutationCount;  // Total mutations accumulated
        uint256 lastMutation;   // Block number of last mutation
        bytes32 signature;      // Unique genome signature
    }

    /// @notice Genetic compatibility check between two organisms
    struct CompatibilityResult {
        bool compatible;
        uint256 similarity;     // 0-100 percentage
        uint256 hybridVigor;    // Bonus from genetic diversity
    }

    /**
     * @notice Initialize a new genome with random genes
     * @param seed Random seed for generation
     * @param numChromosomes Number of chromosomes to create
     * @param genesPerChromosome Number of genes per chromosome
     * @return GenomeData The initialized genome
     */
    function initialize(
        uint256 seed,
        uint256 numChromosomes,
        uint256 genesPerChromosome
    ) internal pure returns (GenomeData memory) {
        GenomeData memory genome;
        genome.generation = 0;
        genome.mutationCount = 0;
        genome.lastMutation = 0;

        // Note: In practice, you'd need to create this in storage due to dynamic arrays
        // This is a simplified view for the structure
        genome.signature = keccak256(abi.encodePacked(seed, numChromosomes, genesPerChromosome));

        return genome;
    }

    /**
     * @notice Calculate compatibility between two genomes
     * @param genome1 First genome
     * @param genome2 Second genome
     * @return CompatibilityResult Compatibility details
     */
    function checkCompatibility(
        GenomeData storage genome1,
        GenomeData storage genome2
    ) internal view returns (CompatibilityResult memory) {
        CompatibilityResult memory result;

        // Must have same number of chromosomes
        if (genome1.chromosomes.length != genome2.chromosomes.length) {
            result.compatible = false;
            result.similarity = 0;
            result.hybridVigor = 0;
            return result;
        }

        uint256 totalGenes = 0;
        uint256 similarGenes = 0;

        // Compare each chromosome
        for (uint256 i = 0; i < genome1.chromosomes.length; i++) {
            Chromosome storage chr1 = genome1.chromosomes[i];
            Chromosome storage chr2 = genome2.chromosomes[i];

            uint256 minLength = chr1.genes.length < chr2.genes.length
                ? chr1.genes.length
                : chr2.genes.length;

            totalGenes += minLength;

            // Compare genes
            for (uint256 j = 0; j < minLength; j++) {
                // Genes are similar if values are within 10% of each other
                uint256 diff = chr1.genes[j].value > chr2.genes[j].value
                    ? chr1.genes[j].value - chr2.genes[j].value
                    : chr2.genes[j].value - chr1.genes[j].value;

                if (diff * 10 <= chr1.genes[j].value) {
                    similarGenes++;
                }
            }
        }

        // Calculate similarity percentage
        result.similarity = totalGenes > 0 ? (similarGenes * 100) / totalGenes : 0;

        // Compatible if similarity is between 30% and 80% (too similar or too different is bad)
        result.compatible = result.similarity >= 30 && result.similarity <= 80;

        // Hybrid vigor is higher with moderate genetic diversity
        if (result.similarity >= 40 && result.similarity <= 60) {
            result.hybridVigor = 50; // 50% bonus
        } else if (result.similarity >= 30 && result.similarity <= 70) {
            result.hybridVigor = 25; // 25% bonus
        } else {
            result.hybridVigor = 0;
        }

        return result;
    }

    /**
     * @notice Perform crossover between two parent genomes
     * @param parent1 First parent genome
     * @param parent2 Second parent genome
     * @param randomSeed Random seed for crossover points
     * @return bytes32 Hash representing the offspring genome signature
     */
    function crossover(
        GenomeData storage parent1,
        GenomeData storage parent2,
        uint256 randomSeed
    ) internal view returns (bytes32) {
        // Create signature for offspring based on both parents
        bytes32 offspringSig = keccak256(
            abi.encodePacked(
                parent1.signature,
                parent2.signature,
                randomSeed,
                block.timestamp
            )
        );

        return offspringSig;
    }

    /**
     * @notice Apply a random mutation to a genome
     * @param genome The genome to mutate
     * @param mutationType Type of mutation to apply
     * @param randomSeed Random seed for mutation
     */
    function mutate(
        GenomeData storage genome,
        MutationType mutationType,
        uint256 randomSeed
    ) internal {
        genome.mutationCount++;
        genome.lastMutation = block.number;

        // Update genome signature to reflect mutation
        genome.signature = keccak256(
            abi.encodePacked(
                genome.signature,
                uint256(mutationType),
                randomSeed,
                block.number
            )
        );
    }

    /**
     * @notice Calculate hash of a chromosome
     * @param chromosome The chromosome to hash
     * @return bytes32 The chromosome hash
     */
    function hashChromosome(Chromosome storage chromosome) internal view returns (bytes32) {
        bytes memory geneData;

        for (uint256 i = 0; i < chromosome.genes.length; i++) {
            geneData = abi.encodePacked(
                geneData,
                chromosome.genes[i].value,
                chromosome.genes[i].dominance,
                chromosome.genes[i].expressed
            );
        }

        return keccak256(geneData);
    }
}
