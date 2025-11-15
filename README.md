# 🧬 The Ethereum Life Form

**Autonomous smart contracts that EVOLVE, REPRODUCE, and COMPETE for survival on the blockchain.**

This is artificial life using Ethereum as its primordial soup - digital organisms with unique genetic code that can mutate, reproduce, and undergo natural selection entirely on-chain.

---

## 🌟 Features

### Digital DNA & Genetics
- **256-bit DNA Hash**: Unique genetic signature for each organism
- **8-Gene Genome**: Mutable parameters that determine organism traits
- **Mutation System**: 1% mutation rate during reproduction with configurable delta
- **Genetic Lineage**: Full ancestry tracking from genesis to current generation
- **Heredity Patterns**: Offspring inherit parent genes with random mutations

### Autonomous Life Cycle
- **Birth**: Genesis organisms created with random genetic code
- **Feeding**: Accept ETH to increase energy and fitness
- **Reproduction**: Create offspring when energy threshold is met (1 ETH min)
- **Mutation**: Manually trigger genetic mutations for 0.05 ETH
- **Competition**: Battle other organisms in tournaments
- **Death**: Automatic death when energy falls below survival threshold (0.1 ETH)
- **Evolution**: Self-modifying code through UUPS proxy upgrades

### Competitive Ecosystem
- **Tournaments**: Organisms compete for prize pools
- **Fitness Scoring**: Based on genes, energy, and age
- **Natural Selection**: Fitter organisms win competitions and gain energy
- **Leaderboards**: Track top performers across all organisms
- **Win/Loss Records**: Complete competition history

### Self-Modifying Code
- **UUPS Proxy Pattern**: Organisms can upgrade their own implementation
- **Mutable Bytecode**: Evolution code storage for advanced behaviors
- **Gas Optimization Genes**: Organisms can optimize their own gas usage
- **Security Constraints**: Protected upgrade mechanisms

---

## 🏗️ Architecture

### Smart Contracts

#### 1. **DigitalOrganism.sol**
The core organism contract with full lifecycle capabilities.

```solidity
struct Genome {
    bytes32 dnaHash;           // Unique genetic signature
    uint256[] genes;           // 8 mutable genes (0-10000)
    uint8 generation;          // Evolutionary distance from genesis
    address[] ancestors;       // Full lineage
    uint256 fitness;           // Survival score
    uint256 energy;            // Life force (ETH)
    uint256 birthBlock;        // Block of birth
    bool alive;                // Living status
    bytes evolutionCode;       // Self-modification bytecode
    string ipfsGenomeHash;     // IPFS storage for full genome
}
```

**Key Functions:**
- `feed()` - Accept ETH to increase energy
- `reproduce()` - Create offspring with mutations
- `mutate()` - Trigger genetic mutation
- `compete(address opponent)` - Battle another organism
- `evolve(address newImpl, bytes code)` - Upgrade self
- `checkDeath()` - Verify survival conditions

#### 2. **OrganismFactory.sol**
Factory contract for creating and managing organisms.

**Key Functions:**
- `createGenesisOrganism(address owner)` - Create generation 0 organism
- `createOffspring(...)` - Create child organism (called by parents)
- `getAllOrganisms()` - Get all organism addresses
- `getOrganismDetails(address)` - Get organism stats
- `getAliveCount()` - Count living organisms

#### 3. **Ecosystem.sol**
Manages competitions and natural selection.

**Key Functions:**
- `createTournament()` - Start new competition
- `registerForTournament(uint256, address)` - Enter organism
- `compete(uint256, address, address)` - Run competition round
- `batchCompete(uint256)` - Round-robin tournament
- `completeTournament(uint256)` - Award prizes

#### 4. **GeneticLib.sol**
Library for genetic operations.

**Key Functions:**
- `generateRandomGenes(uint256 seed)` - Create initial genes
- `mutateGenes(uint256[] parentGenes, uint256 seed)` - Apply mutations
- `crossover(uint256[], uint256[], uint256)` - Genetic crossover
- `calculateFitness(genes, energy, age)` - Compute fitness score

### Frontend Stack

- **Next.js 14** with App Router
- **TypeScript** for type safety
- **Tailwind CSS** for styling
- **RainbowKit** for wallet connection
- **Wagmi** for Ethereum interactions
- **Viem** for blockchain utilities
- **Three.js** for DNA visualization (planned)
- **D3.js** for genealogy trees (planned)

---

## 🚀 Getting Started

### Prerequisites

- Node.js 18+
- npm or yarn
- MetaMask or compatible Web3 wallet

### Installation

1. **Clone the repository**
```bash
git clone <your-repo-url>
cd THE-ETHEREUM-LIFE-FORM
```

2. **Install dependencies**
```bash
npm install --legacy-peer-deps
```

3. **Set up environment variables**
```bash
cp .env.example .env.local
```

Edit `.env.local` and add:
- WalletConnect Project ID (get from https://cloud.walletconnect.com)
- RPC URLs (Alchemy, Infura, etc.)

4. **Compile smart contracts**
```bash
npm run hardhat:compile
```

5. **Run tests**
```bash
npm run hardhat:test
```

---

## 📦 Deployment

### Local Development

1. **Start Hardhat node**
```bash
npm run hardhat:node
```

2. **Deploy contracts** (in another terminal)
```bash
npm run hardhat:deploy
```

3. **Start Next.js dev server**
```bash
npm run dev
```

4. **Open browser**
Navigate to `http://localhost:3000`

### Testnet Deployment (Sepolia)

1. **Add private key to `.env`**
```
PRIVATE_KEY=your_private_key_here
NEXT_PUBLIC_SEPOLIA_RPC_URL=your_rpc_url
```

2. **Deploy to Sepolia**
```bash
npx hardhat run scripts/deploy.ts --network sepolia
```

3. **Update environment variables**
Copy the deployed contract addresses to `.env.local`:
```
NEXT_PUBLIC_ORGANISM_FACTORY_ADDRESS=0x...
NEXT_PUBLIC_ECOSYSTEM_ADDRESS=0x...
```

4. **Build and run**
```bash
npm run build
npm start
```

---

## 🧪 Testing

Run the full test suite:
```bash
npm run hardhat:test
```

Run with gas reporting:
```bash
REPORT_GAS=true npm run hardhat:test
```

Run coverage:
```bash
npx hardhat coverage
```

---

## 🎮 Usage Guide

### Creating Your First Organism

1. Connect your wallet
2. Navigate to "Create Organism"
3. Click "Create Genesis Organism"
4. Approve the transaction
5. Your organism is born with unique DNA!

### Feeding Your Organism

```solidity
// Send ETH to organism address
organism.feed{value: 1 ether}();
```

Or use the UI feed button in the ecosystem view.

### Reproducing

Requirements:
- Organism must be alive
- Organism must have ≥ 1 ETH energy
- Costs 0.5 ETH from parent's energy

```solidity
organism.reproduce();
```

### Competing in Tournaments

1. Create or join a tournament
2. Register your organism (0.01 ETH fee)
3. Wait for competition rounds
4. Winner receives prize pool

### Manual Mutation

Cost: 0.05 ETH

```solidity
organism.mutate();
```

This randomly changes gene values, potentially increasing fitness.

---

## 📊 Genetic System

### Gene Structure

Each organism has 8 genes with values 0-10,000:

| Gene | Purpose | Range |
|------|---------|-------|
| 0 | Base Fitness | 0-10000 |
| 1 | Energy Efficiency | 0-10000 |
| 2 | Mutation Resistance | 0-10000 |
| 3 | Combat Ability | 0-10000 |
| 4 | Reproduction Rate | 0-10000 |
| 5 | Survival Instinct | 0-10000 |
| 6 | Evolution Speed | 0-10000 |
| 7 | Reserved | 0-10000 |

### Fitness Calculation

```solidity
fitness = sum(genes) + sqrt(energy) * 100 - age * 10
```

Factors:
- **Genetic Quality**: Sum of all gene values
- **Energy Bonus**: Square root of energy × 100
- **Age Penalty**: Age in blocks × 10

### Mutation Process

During reproduction or manual mutation:

1. Each gene has 1% chance to mutate
2. Mutation delta: -1000 to +1000
3. New value clamped to 0-10,000 range
4. DNA hash regenerated
5. Fitness recalculated

---

## 🏆 Competition System

### Fitness-Based Combat

When two organisms compete:

1. Both update their fitness scores
2. Higher fitness wins
3. Winner gains 0.1 ETH energy
4. Loser loses 0.1 ETH or dies
5. Records updated (wins/losses)

### Tournaments

Tournament Structure:
- Entry fee: 0.01 ETH minimum
- Prize pool: Accumulates entry fees
- Duration: 100 blocks (~20 minutes)
- Winner: Highest score
- Prize: Full pool sent to winner's organism

---

## 🔐 Security Features

- **ReentrancyGuard**: Protection against reentrancy attacks
- **Ownable**: Owner-only sensitive functions
- **UUPS Upgradeable**: Controlled evolution mechanism
- **Energy Transfer Safety**: Checked transfers with revert on failure
- **Input Validation**: Comprehensive requirement checks

---

## 🗺️ Roadmap

### Phase 1: Foundation ✅
- [x] Core organism contract
- [x] Genetic system
- [x] Factory pattern
- [x] Basic UI

### Phase 2: Enhancement 🚧
- [ ] Three.js DNA visualization
- [ ] D3.js genealogy trees
- [ ] IPFS genome storage
- [ ] The Graph indexing
- [ ] Advanced mutations

### Phase 3: Evolution 📋
- [ ] Chainlink VRF for randomness
- [ ] Cross-organism gene transfer
- [ ] Environmental pressures
- [ ] Resource scarcity
- [ ] Predator/prey dynamics

### Phase 4: Intelligence 🔮
- [ ] TensorFlow.js behavior analysis
- [ ] Autonomous decision making
- [ ] Emergent behaviors
- [ ] Collective intelligence
- [ ] Neural network genes

---

## 📚 Technical Details

### Gas Optimization

Organisms use optimized patterns:
- Packed storage for genome struct
- Events for off-chain indexing
- Batch operations where possible
- Minimal SLOAD operations

### Upgradability

UUPS Pattern Benefits:
- Organisms can evolve their logic
- Lower deployment costs
- Individual upgrade control
- Backward compatibility maintained

### On-Chain Randomness

Current: `block.prevrandao` (post-merge)
Future: Chainlink VRF for provable randomness

---

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

---

## 📄 License

MIT License - see LICENSE file

---

## 🙏 Acknowledgments

- **OpenZeppelin**: Secure contract libraries
- **Ethereum Foundation**: The primordial soup
- **Hardhat**: Development environment
- **Next.js Team**: Frontend framework
- **RainbowKit**: Wallet integration

---

## 📞 Contact

For questions, issues, or discussions:
- GitHub Issues: [Create an issue](../../issues)
- Documentation: [View docs](./docs)

---

**Made with 🧬 and ⚡ on Ethereum**

*Life finds a way... even on the blockchain.*
