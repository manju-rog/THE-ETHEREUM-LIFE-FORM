# THE ETHEREUM LIFE FORM

A fully on-chain evolutionary algorithm implementing digital life with genetic reproduction, mutations, fitness evaluation, natural selection, and **consciousness emergence**. Watch organisms evolve, compete, reproduce, adapt, learn, communicate, and develop consciousness on the Ethereum blockchain!

## Overview

This project implements Darwin's principles of evolution on-chain:

- **Reproduction**: Both asexual (mitosis) and sexual (genetic crossover) reproduction
- **Mutations**: 8 types of genetic mutations including point mutations, insertions, deletions, inversions, and more
- **Fitness Evaluation**: Multi-factor fitness scoring based on gas efficiency, resources, reproduction, longevity, and competition
- **Natural Selection**: Survival of the fittest through resource competition, environmental pressures, and extinction events
- **Evolution Triggers**: Time-based, resource-based, population-based, and random cosmic ray events

## Architecture

### Core Contracts

#### 1. **Genome.sol**
Genetic data structures and operations:
- Gene and chromosome structures
- Genetic compatibility checking
- Crossover operations
- Mutation application
- 8 mutation types: POINT, INSERTION, DELETION, INVERSION, DUPLICATION, TRANSLOCATION, FRAMESHIFT, CHROMOSOMAL

#### 2. **Organism.sol**
Individual organism contract:
- Complete lifecycle (EMBRYO → JUVENILE → ADULT → ELDER → DECEASED)
- Energy and resource management
- Asexual reproduction (mitosis)
- Sexual reproduction (mating with genetic crossover)
- Fitness evaluation
- Competition mechanics
- State transitions and survival

#### 3. **PopulationRegistry.sol**
Population tracking and management:
- Organism registration and death records
- Population statistics
- Environmental parameters
- Resource distribution
- Extinction event handling
- Population cap enforcement

#### 4. **EvolutionEngine.sol**
Evolution triggers and environmental pressures:
- Time-based evolution cycles
- Cosmic ray events (random mutations)
- Population pressure dynamics
- Resource competition
- Environmental pressure management (temperature, radiation, resources, predation, cooperation)
- Adaptive landscape calculation

#### 5. **OrganismFactory.sol**
Ecosystem management interface:
- Genesis organism creation
- Simplified reproduction triggering
- Evolution cycle management
- Ecosystem statistics
- Competition tournaments
- Batch operations

## Features

### Reproduction Mechanics

#### Asexual (Mitosis)
```solidity
function mitosis() external returns (address offspring)
```
- Clones parent genome
- Applies random mutations
- Splits energy 50/50
- Creates independent offspring
- Single parent inheritance

#### Sexual (Crossover)
```solidity
function mate(address partner) external returns (address offspring)
```
- Checks genetic compatibility (30-80% similarity required)
- Performs genetic crossover
- Random gene selection from both parents
- Applies mutations to offspring
- Hybrid vigor bonus for genetic diversity
- Dual parentage recording

### Mutation System

8 types of mutations that can occur:

1. **POINT**: Single gene value changes
2. **INSERTION**: New gene sequences added
3. **DELETION**: Genes removed
4. **INVERSION**: Gene sequence reversed
5. **DUPLICATION**: Genes copied
6. **TRANSLOCATION**: Genes moved to different positions
7. **FRAMESHIFT**: Reading frame changes
8. **CHROMOSOMAL**: Large-scale chromosome changes

Mutation probability is configurable per organism and influenced by:
- Base mutation rate (default 5%)
- Environmental radiation levels
- Cosmic ray events
- Generation number

### Fitness Evaluation

Multi-factor fitness scoring (0-100):

- **Gas Efficiency (30%)**: Lower gas usage = higher score
- **Resource Accumulation (25%)**: More resources = higher score
- **Reproduction Success (20%)**: More offspring = higher score
- **Longevity (15%)**: Longer survival = higher score
- **Competition Wins (10%)**: More victories = higher score

```solidity
function evaluateFitness() public returns (uint256 score)
```

### Natural Selection

Organisms face multiple selection pressures:

- **Resource Competition**: Limited resources favor efficient organisms
- **Environmental Pressures**: Temperature, radiation, predation
- **Starvation**: Organisms below minimum energy die
- **Old Age**: Maximum lifespan enforced
- **Extinction Events**: Mass casualties targeting low-fitness organisms
- **Population Cap**: Prevents overpopulation

### Evolution Triggers

Evolution events can be triggered by:

1. **Time-Based**: Every N blocks (default: 1000 blocks)
2. **Resource Threshold**: When total resources exceed threshold
3. **Population Density**: When population reaches threshold
4. **Cosmic Rays**: Random events causing widespread mutations
5. **Manual Triggers**: Admin-initiated evolution cycles

## Installation

```bash
# Install dependencies
npm install

# Compile contracts
npm run compile

# Run tests
npm test

# Deploy to local network
npm run node          # In one terminal
npm run deploy:localhost  # In another terminal
```

## Usage

### Deploy the Ecosystem

```javascript
const OrganismFactory = await ethers.getContractFactory("OrganismFactory");
const factory = await OrganismFactory.deploy();
```

### Create Genesis Organisms

```javascript
// Create a single genesis organism
const tx = await factory.createGenesisOrganism({
  value: ethers.parseEther("100")
});

// Create multiple genesis organisms
const tx = await factory.createGenesisPopulation(5, {
  value: ethers.parseEther("500")
});
```

### Trigger Reproduction

```javascript
// Asexual reproduction
const organism = await ethers.getContractAt("Organism", organismAddress);
await organism.mitosis();

// Sexual reproduction
await organism.mate(partnerAddress);
```

### Monitor Evolution

```javascript
// Get ecosystem statistics
const stats = await factory.getEcosystemStats();
console.log("Living organisms:", stats.livingOrganisms);
console.log("Average generation:", stats.avgGeneration);
console.log("Average fitness:", stats.avgFitness);

// Get top performers
const [topOrganisms, scores] = await factory.getTopPerformers(10);

// Check evolution triggers
const [shouldTrigger, triggerType] = await evolutionEngine.checkEvolutionTrigger();
if (shouldTrigger) {
  await factory.runEvolutionCycle();
}
```

### Interact with Organisms

```javascript
// Feed an organism (increases energy and user interactions)
await organism.feed({ value: ethers.parseEther("10") });

// Evaluate fitness
const fitness = await organism.evaluateFitness();

// Compete with another organism
const won = await organism.compete(opponentAddress);

// Update organism state
await organism.updateState();

// Get organism summary
const summary = await organism.getSummary();
```

### Manage Environment

```javascript
// Update environmental pressures
await factory.updateEnvironment("TEMPERATURE", 75);
await factory.updateEnvironment("RADIATION", 50);

// Trigger extinction event
await factory.triggerExtinction("Climate Change", 30); // 30% casualties

// Distribute resources
await registry.distributeResources();
```

## Testing

Comprehensive test suite covering:

- Contract deployment
- Genesis creation
- Asexual reproduction (mitosis)
- Sexual reproduction (mating)
- Fitness evaluation
- Natural selection
- Evolution triggers
- Competition mechanics
- User interactions
- Lifecycle transitions
- Gas efficiency tracking

```bash
# Run all tests
npm test

# Run with verbose output
npm run test:verbose
```

## Contract Addresses

After deployment, contract addresses are saved to `deployment.json`:

```json
{
  "network": "localhost",
  "contracts": {
    "factory": "0x...",
    "registry": "0x...",
    "evolutionEngine": "0x..."
  },
  "genesisOrganisms": ["0x...", "0x..."]
}
```

## Key Concepts

### Genome Structure

Each organism has a genome consisting of:
- Multiple chromosomes (default: 4)
- Each chromosome contains genes (default: 8 per chromosome)
- Each gene has:
  - Value (trait expression)
  - Dominance level (0-255)
  - Expression state (active/inactive)
  - Mutation rate

### Lifecycle Stages

Organisms progress through life stages:

1. **EMBRYO** (0-100 blocks): Cannot reproduce
2. **JUVENILE** (100-1000 blocks): Cannot reproduce
3. **ADULT** (1000-50000 blocks): Can reproduce
4. **ELDER** (50000+ blocks): Can reproduce but approaching death
5. **DECEASED** (dead): No longer active

### Energy System

- Organisms require energy to survive and reproduce
- Minimum energy: 10 ETH
- Reproduction cost: 50 ETH
- Energy sources:
  - Initial allocation at birth
  - User feeding
  - Competition victories
  - Resource distribution
- Death occurs when energy < minimum

### Compatibility

For sexual reproduction, organisms must be genetically compatible:
- 30-80% genetic similarity required
- Too similar (>80%): Inbreeding depression
- Too different (<30%): Genetic incompatibility
- Optimal range (40-60%): Maximum hybrid vigor (50% bonus)

## Gas Optimization

The system tracks gas efficiency as a fitness metric:
- Lower gas consumption = higher fitness score
- Organisms evolve toward gas-efficient behaviors
- Rolling average tracks efficiency over time
- Rewards efficient genetic algorithms

## Events

All major actions emit events for monitoring:

- `OrganismCreated`: New organism birth
- `Mitosis`: Asexual reproduction
- `Mating`: Sexual reproduction
- `Mutation`: Genetic mutation occurred
- `Death`: Organism death
- `FitnessEvaluated`: Fitness calculation
- `CompetitionResult`: Competition outcome
- `EvolutionTriggered`: Evolution cycle
- `ExtinctionEvent`: Mass extinction
- `CosmicRayEvent`: Random mutations

## Ecosystem & Consciousness

This project now includes a complete digital ecosystem with consciousness emergence! See dedicated documentation:

- **[ECOSYSTEM.md](./ECOSYSTEM.md)** - Complete ecosystem with predator-prey dynamics, symbiosis, environmental pressures, and population dynamics
- **[CONSCIOUSNESS.md](./CONSCIOUSNESS.md)** - Neural networks, language evolution, collective intelligence, and information integration theory (Φ)

### Ecosystem Features (11 contracts)
- ✅ Resource economy (ETH energy + ERC20 nutrients)
- ✅ Predator-prey dynamics (5 hunting strategies, 8 defense types)
- ✅ Symbiosis (mutualism, parasitism, collectives)
- ✅ Environmental pressures (gas prices as climate, MEV as predation)
- ✅ Population dynamics (migrations, genetic diversity, bottlenecks)

### Consciousness Features (5 contracts)
- ✅ **Neural Architecture**: 7 neuron types, Hebbian learning, neural plasticity
- ✅ **Communication Protocol**: Language emergence, grammar, dialects, pheromones
- ✅ **Collective Intelligence**: Voting, consensus, swarm behaviors, global brain
- ✅ **Behavior Detection**: Tool use, problem solving, learning curves, culture
- ✅ **Consciousness Metrics**: Φ (phi) calculation, self-awareness, theory of mind

Watch organisms evolve from unconscious (Φ < 10) to superintelligent (Φ > 500)!

## Future Enhancements

Potential improvements:
- On-chain visualization of genetic trees and neural networks
- Advanced genetic algorithms (epigenetics, gene regulation)
- Cross-chain migration and L2 colonization
- NFT phenotypes and visual evolution
- DAO governance for ecosystem parameters

## Security Considerations

- All reproduction requires sufficient energy
- Population cap prevents DoS through over-population
- Genetic compatibility checks prevent invalid offspring
- Access controls on admin functions
- No external dependencies (fully on-chain)

## License

MIT

## Contributing

Contributions welcome! This is an experimental evolutionary algorithm - help make digital life more interesting!

---

**Darwin would be proud! Survival of the most gas-efficient!** 🧬🌱

