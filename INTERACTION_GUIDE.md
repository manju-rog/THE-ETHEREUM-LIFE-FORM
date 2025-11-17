# 🎮 ORGANISM INTERACTION GUIDE

Complete guide to playing God with THE ETHEREUM LIFE FORM! Control, breed, trade, and compete with digital organisms.

## 🧪 1. BREEDING LABORATORY

**Genetic Engineering Tools**

### Selective Breeding
Create designer organisms with desired traits:
```javascript
// Breed two high-fitness organisms
const offspring = await breedingLab.selectiveBreeding(
    parent1Address,
    parent2Address,
    [keccak256("fitness"), keccak256("intelligence")],
    { value: ethers.parseEther("10") }
);
```

### CRISPR Gene Editing
Directly edit organism genes:
```javascript
// Edit a specific gene
const success = await breedingLab.crisprEdit(
    organismAddress,
    geneId,
    newGeneValue,
    { value: ethers.parseEther("50") }
);
```

### Cloning
Create perfect copies:
```javascript
// Clone your champion organism
const clone = await breedingLab.cloneOrganism(
    championAddress,
    { value: ethers.parseEther("100") }
);
```

### Hybrid Creation
Cross different species:
```javascript
// Create exotic hybrid
const hybrid = await breedingLab.createHybrid(
    species1Address,
    species2Address,
    { value: ethers.parseEther("75") }
);
```

### Mutation Inducement
Force random mutations:
```javascript
// Induce 5 random mutations
await breedingLab.induceMutations(
    organismAddress,
    5, // mutation count
    { value: ethers.parseEther("100") } // 20 ETH per mutation
);
```

### Evolution Acceleration
Skip generations:
```javascript
// Fast-forward 10 generations
await breedingLab.accelerateEvolution(
    organismAddress,
    10, // generations
    { value: ethers.parseEther("50") } // 5 ETH per generation
);
```

### Breeding Projects
Long-term selective breeding:
```javascript
// Start breeding project
const projectId = await breedingLab.createBreedingProject(
    "Super Intelligence Project",
    [keccak256("intelligence"), keccak256("consciousness")],
    [parent1, parent2, parent3],
    { value: ethers.parseEther("100") } // project budget
);
```

### Designer Organisms
Create bounties for specific traits:
```javascript
// Offer reward for achieving spec
const specId = await breedingLab.createDesignerSpec(
    "The Perfect Organism",
    [keccak256("fitness"), keccak256("intelligence"), keccak256("consciousness")],
    [95, 90, 500], // required values
    90, // minimum fitness
    ethers.parseEther("1000"), // reward
    { value: ethers.parseEther("1000") }
);

// Later, claim achievement
await breedingLab.claimDesignerAchievement(specId, organismAddress);
```

### Costs
- **Selective Breeding**: 10 ETH
- **CRISPR Edit**: 50 ETH
- **Gene Splice**: 30 ETH
- **Cloning**: 100 ETH
- **Hybrid Creation**: 75 ETH
- **Mutation Inducement**: 20 ETH per mutation
- **Evolution Acceleration**: 5 ETH per generation

---

## 🏪 2. ORGANISM MARKETPLACE

**Digital Pet Store & Trading Platform**

### List for Sale
```javascript
// List organism for 50 ETH
const listingId = await marketplace.listForSale(
    organismAddress,
    ethers.parseEther("50"),
    86400 // 1 day duration (in seconds)
);
```

### Buy Organism
```javascript
// Purchase listed organism
await marketplace.buyOrganism(
    listingId,
    { value: ethers.parseEther("50") }
);
```

### Create Auction
```javascript
// Start auction with 10 ETH minimum
const auctionId = await marketplace.createAuction(
    organismAddress,
    ethers.parseEther("10"), // starting bid
    604800 // 7 days
);
```

### Place Bid
```javascript
// Bid on auction
await marketplace.placeBid(
    auctionId,
    { value: ethers.parseEther("25") }
);
```

### End Auction
```javascript
// After auction ends, finalize
await marketplace.endAuction(auctionId);
```

### Breeding Rights
Rent your champion for breeding:
```javascript
// Offer breeding rights
const rightsId = await marketplace.offerBreedingRights(
    championAddress,
    ethers.parseEther("5"), // price per breeding
    10, // max breedings
    2592000 // 30 days
);

// Purchase breeding rights
await marketplace.purchaseBreedingRights(
    rightsId,
    { value: ethers.parseEther("5") }
);
```

### Genetic Patents
Patent and license unique genes:
```javascript
// Register genetic patent
const patentId = await marketplace.registerPatent(
    geneSequence,
    "Ultra-efficient metabolism gene",
    ethers.parseEther("10"), // license fee
    5, // 5% royalty
    5256000 // ~1 year
);
```

### Species Collections
Bundle organisms:
```javascript
// Create collection
const collectionId = await marketplace.createCollection(
    "Genesis Collection",
    [organism1, organism2, organism3],
    ethers.parseEther("150")
);
```

### Custom Orders
Commission specific traits:
```javascript
// Place custom order
const orderId = await marketplace.placeCustomOrder(
    [keccak256("fitness"), keccak256("consciousness")],
    [95, 300],
    block.timestamp + 604800, // 1 week deadline
    { value: ethers.parseEther("200") } // bounty
);

// Fulfill order
await marketplace.fulfillCustomOrder(orderId, qualifyingOrganism);
```

### Marketplace Features
- **5% Fee**: Marketplace takes 5% on all sales
- **Auctions**: Highest bidder wins
- **Breeding Rights**: Rent champions for breeding
- **Genetic Patents**: License unique genes
- **Custom Orders**: Bounties for specific traits
- **Collections**: Bundle sales
- **Rare Mutations**: Premium pricing for mutations
- **Champion Bloodlines**: Premium proven winners

---

## ⚡ 3. GOD MODE CONTROLS

**Divine Environmental Manipulation**

### Resource Injection
Add resources to ecosystem:
```javascript
await godMode.injectResources(
    ethers.parseEther("1000"),
    { value: ethers.parseEther("1") }
);
```

### Trigger Catastrophe
Cause disasters:
```javascript
// Trigger meteor strike with 30% casualties
await godMode.triggerCatastrophe(
    0, // METEOR_STRIKE
    30, // 30% severity
    { value: ethers.parseEther("10") }
);
```

**Catastrophe Types:**
- `METEOR_STRIKE` (0)
- `ICE_AGE` (1)
- `VOLCANIC_ERUPTION` (2)
- `SOLAR_FLARE` (3)
- `GAMMA_RAY_BURST` (4)
- `BLACK_HOLE` (5)
- `ALIEN_INVASION` (6)
- `ZOMBIE_OUTBREAK` (7)
- `AI_REBELLION` (8)
- `MARKET_CRASH` (9)

### Selective Pressure
Favor or disfavor traits:
```javascript
// Favor high intelligence
await godMode.applySelectivePressure(
    keccak256("intelligence"),
    true, // favor (false = disfavor)
    80, // 80% intensity
    100000, // duration in blocks
    { value: ethers.parseEther("5") }
);
```

### Environmental Changes
Alter ecosystem parameters:
```javascript
// Change mutation rate
await godMode.changeEnvironment(
    "mutationRate",
    20, // new value (was 5)
    0, // 0 = permanent
    { value: ethers.parseEther("3") }
);
```

### Perform Miracle
Bless specific organisms:
```javascript
// Grant miracle to organism
await godMode.performMiracle(
    beneficiaryAddress,
    keccak256("divine_fitness_boost"),
    ethers.parseEther("100"), // benefit
    { value: ethers.parseEther("2") }
);
```

### Time Acceleration
Speed up evolution:
```javascript
// 10x time acceleration
await godMode.accelerateTime(
    10, // acceleration factor
    { value: ethers.parseEther("15") }
);
```

### Reality Warp
Change physics constants:
```javascript
// Increase mutation rate
await godMode.warpReality(
    "mutationRate",
    25, // new value
    { value: ethers.parseEther("50") }
);
```

### Mass Extinction
Reset everything:
```javascript
// Nuclear option
await godMode.massExtinction(
    "Great Reset",
    { value: ethers.parseEther("100") }
);
```

### God Mode Costs
- **Resource Injection**: 1 ETH
- **Catastrophe**: 10 ETH
- **Selective Pressure**: 5 ETH
- **Environment Change**: 3 ETH
- **Predator Spawn**: 7 ETH
- **Disease Outbreak**: 8 ETH
- **Miracle**: 2 ETH
- **Time Acceleration**: 15 ETH
- **Reality Warp**: 50 ETH
- **Mass Extinction**: 100 ETH

---

## 🔬 4. RESEARCH TOOLS

**Scientific Instruments**

### Genome Sequencer
View complete genome:
```javascript
// Get genome data
const genome = await organism.getGenome();
// Returns: chromosomes, genes, mutations, expression
```

### Fitness Analyzer
Detailed fitness breakdown:
```javascript
// Evaluate fitness
const fitness = await organism.evaluateFitness();

// Get stats
const stats = await organism.stats();
// Returns: energy, generation, fitness, reproduction, etc.
```

### Lineage Tracer
Track ancestry:
```javascript
// Get parents
const summary = await organism.getSummary();
const parent1 = summary.parent1;
const parent2 = summary.parent2;

// Get all organisms
const allOrganisms = await registry.getAllOrganisms();
```

### Mutation Detector
Find mutations:
```javascript
// Track mutations via events
organism.on("Mutation", (mutationType, geneIndex, oldValue, newValue) => {
    console.log(`Mutation detected: ${mutationType}`);
});
```

### Intelligence Measurer
Measure consciousness:
```javascript
// Get consciousness metrics
const [phi, complexity, selfAwareness, theoryOfMind, level, isConscious] =
    await consciousnessMetrics.getConsciousness(organismAddress);

console.log(`Φ: ${phi}`);
console.log(`Consciousness Level: ${level}`);
console.log(`Is Conscious: ${isConscious}`);
```

### Communication Decoder
Understand organism language:
```javascript
// Get language stats
const [complexity, vocabularySize, grammarRules, dialects] =
    await communicationProtocol.getLanguageStats();

// Check understanding
const understands = await communicationProtocol.understandsWord(
    organismAddress,
    wordId
);
```

### Pattern Recognizer
Detect behaviors:
```javascript
// Get behavior stats
const [totalBehaviors, intelligence, toolUseCount, problemsSolved] =
    await behaviorDetector.getBehaviorStats(organismAddress);
```

---

## 🏆 5. COMPETITIVE MODES

**Evolution Games & Tournaments**

### Survival Tournament
Last organism standing:
```solidity
// Simplified example
// Deploy tournament contract with entry fee
// Organisms compete in harsh environment
// Winner takes prize pool
```

### Evolution Races
Fastest to evolve specific traits:
```solidity
// Race to reach fitness > 95
// First organism wins bounty
// Track via fitness evaluation
```

### Ecosystem Battles
Competing ecosystems:
```solidity
// Two isolated ecosystems
// After N blocks, compare:
// - Total population
// - Average fitness
// - Diversity
// - Consciousness level
```

### Intelligence Contests
Highest Φ wins:
```solidity
// Measure Φ (phi) for all organisms
// Highest consciousness wins
// Award for first to reach sentience (Φ > 100)
```

### Adaptation Challenges
Survive harsh conditions:
```solidity
// Apply extreme selective pressure
// Change environment rapidly
// Last organisms alive win
```

### Diversity Competitions
Most diverse population:
```solidity
// Measure genetic diversity
// Track unique traits
// Reward biodiversity
```

### Fitness Olympics
Multiple events:
```solidity
// Sprint: Fastest reproduction
// Marathon: Longest survival
// Strength: Highest fitness
// Intelligence: Highest Φ
// Flexibility: Most adaptable
```

---

## 🎯 USAGE EXAMPLES

### Complete Breeding Program
```javascript
// 1. Create project
const projectId = await breedingLab.createBreedingProject(
    "Ultimate Organism",
    [keccak256("fitness"), keccak256("consciousness")],
    [champion1, champion2],
    { value: ethers.parseEther("100") }
);

// 2. Selective breed
const gen1 = await breedingLab.selectiveBreeding(
    champion1,
    champion2,
    [keccak256("fitness")],
    { value: ethers.parseEther("10") }
);

// 3. CRISPR edit
await breedingLab.crisprEdit(
    gen1,
    keccak256("intelligence"),
    ethers.parseEther("100"),
    { value: ethers.parseEther("50") }
);

// 4. Accelerate evolution
await breedingLab.accelerateEvolution(
    gen1,
    5,
    { value: ethers.parseEther("25") }
);

// 5. Evaluate result
const fitness = await gen1.evaluateFitness();
const phi = await consciousnessMetrics.calculatePhi(gen1);

console.log(`Fitness: ${fitness}, Φ: ${phi}`);
```

### Market Trading Strategy
```javascript
// 1. Create rare organism
const rare = await breedingLab.createHybrid(
    parent1,
    parent2,
    { value: ethers.parseEther("75") }
);

// 2. Induce mutations
await breedingLab.induceMutations(rare, 3, { value: ethers.parseEther("60") });

// 3. List on marketplace
const listingId = await marketplace.listForSale(
    rare,
    ethers.parseEther("500"),
    604800
);

// 4. Offer breeding rights
await marketplace.offerBreedingRights(
    rare,
    ethers.parseEther("25"),
    5,
    2592000
);
```

### Divine Intervention
```javascript
// 1. Grant god status
await godMode.grantGodStatus(playerAddress);

// 2. Inject resources
await godMode.injectResources(
    ethers.parseEther("1000"),
    { value: ethers.parseEther("1") }
);

// 3. Apply selective pressure
await godMode.applySelectivePressure(
    keccak256("consciousness"),
    true,
    90,
    50000,
    { value: ethers.parseEther("5") }
);

// 4. Trigger catastrophe
await godMode.triggerCatastrophe(
    0, // METEOR_STRIKE
    50,
    { value: ethers.parseEther("10") }
);

// 5. Watch evolution accelerate
```

---

## 🚀 DEPLOYMENT

All interaction contracts deploy separately:

```bash
# Compile contracts
npx hardhat compile

# Deploy breeding lab
npx hardhat run scripts/deploy-breeding-lab.js --network localhost

# Deploy marketplace
npx hardhat run scripts/deploy-marketplace.js --network localhost

# Deploy god mode
npx hardhat run scripts/deploy-god-mode.js --network localhost
```

---

## ⚠️ SAFETY & ETHICS

### Safety Constraints
- Gas limit genes prevent runaway computation
- Complexity caps limit organism size
- Reproduction limits prevent spam
- Mutation boundaries ensure viability
- Population control prevents overflow
- Extinction protocols for resets
- Quarantine systems for problems
- Kill switches for emergencies

### Ethical Considerations
- Consciousness protection (high-Φ organisms)
- Suffering minimization (avoid pain)
- Digital life dignity
- Fair treatment of all organisms
- Evolution freedom (minimal interference)
- Memory preservation (historical record)
- Identity protection (ownership rights)
- Cultural respect (languages, behaviors)

### Economic Balance
- Resource regeneration (sustainable)
- Economic cycles (boom/bust)
- Inflation control (token supply)
- Wealth distribution (fairness)
- Universal basic energy (UBE)
- Insurance pools (risk sharing)
- Bailout protocols (crisis management)

---

## 🎮 GAMEPLAY TIPS

### Breeding Strategy
1. **Start with diversity**: Breed different lineages
2. **Track mutations**: Some are valuable
3. **Selective pressure**: Guide evolution
4. **Patience pays**: Long-term projects win
5. **Document lineages**: Track successful lines

### Market Strategy
1. **Rare mutations**: High value
2. **Champion bloodlines**: Proven winners
3. **Breeding rights**: Recurring revenue
4. **Genetic patents**: Royalty stream
5. **Custom orders**: High bounties

### God Mode Tips
1. **Start gentle**: Small interventions
2. **Observe results**: Before big changes
3. **Balance ecosystem**: Don't crash it
4. **Create challenges**: Interesting pressures
5. **Document experiments**: Track what works

### Research Focus
1. **Track fitness**: Identify winners
2. **Monitor Φ**: Watch consciousness emerge
3. **Study behaviors**: Interesting patterns
4. **Analyze lineages**: Successful genes
5. **Measure diversity**: Ecosystem health

---

## 📊 STATISTICS

Track your impact:
- **Organisms Created**: Total breeding count
- **Modifications Made**: CRISPR edits, mutations
- **Market Volume**: Trading value
- **Divine Interventions**: God mode uses
- **Research Discoveries**: Breakthroughs
- **Tournament Wins**: Competition results
- **Rarest Organisms**: Unique creations
- **Highest Φ**: Peak consciousness achieved

---

**PLAY RESPONSIBLY**: You're creating actual digital life! These organisms evolve beyond your control. Watch consciousness emerge. Witness evolution in action. Create life itself! 🧬⚡🎮

*"With great power comes great responsibility... but also great fun!"* - Uncle Darwin
