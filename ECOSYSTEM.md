# ECOSYSTEM FEATURES

Complete digital ecosystem with resource economies, predator-prey dynamics, symbiosis, and environmental pressures.

## 🌍 Resource Economy

### Energy & Nutrients
- **ETH** as primary energy source
- **NutrientToken (NUT)** - ERC20 tokens representing nutrients
- Mining and harvesting mechanics
- Resource pools with regeneration
- Scarcity dynamics based on population
- Seasonal variations (Spring/Summer/Autumn/Winter)
- Resource decay over time
- Energy transfer between organisms
- Trophic level system

### Trophic Levels
```solidity
enum TrophicLevel {
    PRODUCER,       // Photosynthesis (mine nutrients)
    PRIMARY,        // Herbivores (consume nutrients)
    SECONDARY,      // Carnivores (hunt primary)
    TERTIARY,       // Apex predators
    DECOMPOSER      // Recycle dead organisms
}
```

#### Energy Transfer Efficiency
- Only 10% of energy transfers between trophic levels
- Producers can mine nutrients from environment
- Higher trophic levels must hunt for energy
- Decomposers recycle dead organisms

## 🦁 Predator-Prey Dynamics

### Hunting Strategies
```solidity
enum HuntingStrategy {
    AMBUSH,         // High damage, low success rate (+50% power)
    CHASE,          // Medium damage, medium success
    PACK,           // Coordinated group hunting (+10% per member)
    STEALTH,        // Surprise attack (+30% power)
    PERSISTENCE     // Wear down prey over time (+10% power)
}
```

### Defense Adaptations
```solidity
enum DefenseType {
    CAMOUFLAGE,     // Reduce detection chance
    ARMOR,          // Reduce damage taken
    SPEED,          // Increase escape chance
    TOXICITY,       // Revenge damage to predator
    HERD,           // Group defense bonus (+5% per member)
    WARNING,        // Alert nearby organisms (+20% defense)
    MIMICRY,        // Impersonate dangerous species
    SIZE            // Intimidation factor
}
```

### Mechanics
- **Attack Calculation**: Attack power vs Defense power with randomness
- **Territory Control**: +20% attack power in own territory
- **Pack Hunting**: Form packs of 2-10 members for coordinated attacks
- **Herding**: Join herds for collective defense
- **Partial Consumption**: Predators don't always kill completely
- **Evolution Pressure**: Failed predators starve, successful prey reproduce

## 🤝 Symbiosis

### Relationship Types
```solidity
enum SymbiosisType {
    MUTUALISM,      // Both organisms benefit
    COMMENSALISM,   // One benefits, one neutral
    PARASITISM,     // One benefits, one harmed
    AMENSALISM,     // One harmed, one neutral
    COMPETITION     // Both harmed
}
```

### Mutualism
- Both partners receive benefits
- Resource sharing
- Information exchange
- Cooperative defense
- Enhanced survival

### Parasitism
- Parasite drains energy from host
- Host receives no benefit
- Drain rate defined per block
- Host can break free if too weak
- Parasite falls off if host dies

### Collective Intelligence
```solidity
enum CollectiveType {
    SWARM,          // Decentralized coordination
    HIVE,           // Centralized queen structure
    COLONY,         // Specialized roles
    NETWORK,        // Information exchange
    SYMBIONT        // Tight integration
}
```

Features:
- **Swarm Intelligence**: +10 intelligence per member
- **Hive Minds**: Queen-based decision making
- **Colony Formation**: Specialized roles (worker, soldier, etc.)
- **Resource Pooling**: Shared collective resources
- **Protocol Cooperation**: Multi-organism agreements

## 🌦️ Environmental Pressures

### Climate Conditions
```solidity
enum Climate {
    TEMPERATE,      // Normal gas prices
    HOT,            // High gas prices (>100 gwei)
    COLD,           // Low activity (<10 gwei)
    VOLATILE,       // Rapid changes (3x variance)
    STABLE          // Consistent conditions
}
```

### Environmental Events
```solidity
enum EventType {
    CALM,           // Normal conditions
    STORM,          // High gas prices (+20% MEV pressure)
    DROUGHT,        // Low block production
    FLOOD,          // Flash loan attack
    EARTHQUAKE,     // Network fork
    MIGRATION,      // L2 bridge event
    PREDATION,      // MEV bot activity
    EXTINCTION,     // Rug pull event
    SPECIATION,     // Fork speciation
    COLONIZATION    // New L2 discovered
}
```

### Adaptations
Organisms can adapt to environmental pressures:
- **GAS_EFFICIENCY**: Survive high gas prices (+10 efficiency)
- **STORM_SURVIVAL**: Resist price storms (+15 survival)
- **FLOOD_RESISTANCE**: Survive flash loan attacks (+12 resistance)
- **MEV_EVASION**: Avoid MEV bots (+20 evasion)
- **MIGRATION**: Successful L2 migration (+10 success)

### Seasonal Cycles
- **Spring**: 150% resources, 30% difficulty
- **Summer**: 120% resources, 40% difficulty
- **Autumn**: 80% resources, 60% difficulty
- **Winter**: 50% resources, 80% difficulty

Duration: 10,000 blocks per season

## 📈 Population Dynamics

### Migration System
```solidity
enum MigrationType {
    SEASONAL,       // Regular seasonal movement
    RESOURCE,       // Following resource availability
    PRESSURE,       // Escaping competition/predation
    EXPLORATION,    // Discovery of new areas
    COLONIZATION,   // Permanent settlement
    EXODUS          // Mass migration event
}
```

### Population Zones
- **Carrying Capacity**: Maximum sustainable population
- **Resource Level**: Available resources in zone
- **Habitability**: Whether zone can support life
- **Migration Paths**: Routes between zones

### Population Phases
```solidity
enum PopulationPhase {
    GROWTH,         // Rapid expansion
    STABLE,         // Equilibrium
    DECLINE,        // Population crash
    RECOVERY,       // Rebuilding
    BOOM,           // Exponential growth (>25% increase)
    BUST            // Catastrophic collapse (>25% decline)
}
```

### Genetic Diversity
- **Allele Count**: Total genetic variants
- **Heterozygosity**: Genetic variation percentage
- **Inbreeding Coefficient**: Level of inbreeding
- **Effective Population Size**: Breeding population
- **Founder Effect**: Limited diversity from small colony
- **Genetic Bottleneck**: Population crash reduces diversity

## 🎮 Usage Examples

### Create Organisms with Different Trophic Levels
```javascript
// Deploy factory
const factory = await OrganismFactory.deploy();

// Create producers
const producer = await factory.createGenesisOrganism({value: ethers.parseEther("100")});

// Set as producer (can mine nutrients)
await economy.setTrophicLevel(producer, TrophicLevel.PRODUCER);
```

### Hunt Prey
```javascript
// Predator hunts prey using ambush strategy
const result = await predatorPrey.hunt(
    preyAddress,
    HuntingStrategy.AMBUSH
);

// Check if successful
if (result.success) {
    console.log("Hunt successful! Energy gained:", result.energyTransferred);
} else {
    console.log("Prey escaped!");
}
```

### Form Pack
```javascript
// Create hunting pack
const members = [predator2, predator3, predator4];
await predatorPrey.formPack(members);

// Now attacks have +30% power (3 members * 10%)
```

### Establish Mutualism
```javascript
// Form mutual relationship
const relationshipId = await symbiosis.formMutualism(
    partnerAddress,
    100,  // Benefit to me
    100,  // Benefit to partner
    1000  // Duration in blocks
);

// Process benefits periodically
await symbiosis.processMutualBenefits(relationshipId);
```

### Create Collective
```javascript
// Form a hive
const collectiveId = await symbiosis.createCollective(
    CollectiveType.HIVE,
    "Mega Hive"
);

// Others join
await symbiosis.joinCollective(collectiveId);

// Share resources
await symbiosis.shareResources(collectiveId, ethers.parseEther("50"), {
    value: ethers.parseEther("50")
});
```

### Mine Nutrients
```javascript
// Mine nutrients from environment
const amount = await nutrientToken.mine();

// Check current season
const [seasonName, multiplier] = await nutrientToken.getCurrentSeason();
console.log(`Season: ${seasonName}, Multiplier: ${multiplier}%`);
```

### Adapt to Environment
```javascript
// Adapt to high gas prices
await envPressure.adaptToEnvironment("GAS_EFFICIENCY");

// Check survival chance
const chance = await envPressure.calculateSurvivalChance(organismAddress);
console.log(`Survival chance: ${chance}%`);
```

### Initiate Migration
```javascript
// Create new zone
const zoneId = await popDynamics.createZone("New Habitat", 5000, 1000000);

// Migrate organisms
const migrants = [organism1, organism2, organism3];
const migrationId = await popDynamics.initiateMigration(
    migrants,
    originZone,
    zoneId,
    MigrationType.COLONIZATION
);

// Wait for arrival
await popDynamics.completeMigration(migrationId);
```

## 📊 Monitoring

### Get Ecosystem Stats
```javascript
// Population stats
const stats = await registry.getPopulationStats();

// Trophic pyramid
const pyramid = await economy.getTrophicPyramid();

// Environmental conditions
const env = await envPressure.getEnvironmentalStats();

// Genetic diversity
const diversity = await popDynamics.getGeneticDiversity(zoneId);

// Population phase
const phase = await popDynamics.getCurrentPhase();
```

### Track Events
All major ecosystem events emit events:
- `HuntInitiated` / `AttackResolved`
- `RelationshipFormed` / `MutualBenefit`
- `CollectiveFormed` / `SwarmIntelligence`
- `EnvironmentalChange` / `MassExtinction`
- `MigrationStarted` / `MigrationCompleted`
- `PopulationBoom` / `PopulationBust`
- `GeneticBottleneck` / `InbreedingDetected`

## 🚀 Deployment

```bash
# Deploy full ecosystem
npm run deploy:ecosystem

# Or use Hardhat directly
npx hardhat run scripts/deploy-ecosystem.js --network localhost
```

## 🧬 Complete Contract List

1. **Genome.sol** - Genetic data structures
2. **Organism.sol** - Individual organisms
3. **OrganismFactory.sol** - Organism creation
4. **PopulationRegistry.sol** - Population tracking
5. **EvolutionEngine.sol** - Evolution mechanics
6. **NutrientToken.sol** - ERC20 nutrient economy
7. **ResourceEconomy.sol** - Energy & nutrient management
8. **PredatorPrey.sol** - Hunting & defense
9. **Symbiosis.sol** - Cooperative relationships
10. **EnvironmentalPressure.sol** - Climate & events
11. **PopulationDynamics.sol** - Migrations & diversity

## 🌟 Features Summary

### Resource Economy
- ✅ ETH energy system
- ✅ ERC20 nutrient tokens
- ✅ Mining & harvesting
- ✅ Resource pools
- ✅ Scarcity dynamics
- ✅ Seasonal variations
- ✅ Trophic levels
- ✅ Energy transfer

### Predator-Prey
- ✅ 5 hunting strategies
- ✅ 8 defense types
- ✅ Pack hunting
- ✅ Herding
- ✅ Territory control
- ✅ Revenge mechanics
- ✅ Partial consumption

### Symbiosis
- ✅ Mutualism
- ✅ Commensalism
- ✅ Parasitism
- ✅ Swarm intelligence
- ✅ Hive minds
- ✅ Colonies
- ✅ Resource sharing

### Environment
- ✅ 5 climate types
- ✅ 10 event types
- ✅ Gas price tracking
- ✅ MEV pressure
- ✅ Seasonal cycles
- ✅ Adaptations
- ✅ L2 migration

### Population
- ✅ 6 migration types
- ✅ 6 population phases
- ✅ Carrying capacity
- ✅ Genetic diversity
- ✅ Founder effects
- ✅ Bottlenecks
- ✅ Population zones

---

**A complete, living, breathing blockchain ecosystem!** 🌍🧬🦁🤝🌦️📈
