# 🚀 HOW TO USE - Complete Setup & Usage Guide

**THE ETHEREUM LIFE FORM - Complete deployment and usage instructions**

---

## 📋 TABLE OF CONTENTS

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Deployment](#deployment)
4. [Configuration](#configuration)
5. [Usage Examples](#usage-examples)
6. [Error Handling](#error-handling)
7. [Safety & Security](#safety--security)
8. [Troubleshooting](#troubleshooting)
9. [Advanced Features](#advanced-features)
10. [API Reference](#api-reference)

---

## 1. PREREQUISITES

### Required Software
```bash
# Node.js (v18 or higher)
node --version  # Should be >= v18.0.0

# npm or yarn
npm --version   # Should be >= 8.0.0

# Git
git --version

# MetaMask browser extension
# Download from: https://metamask.io
```

### Required Knowledge
- Basic Solidity understanding
- Ethereum/blockchain concepts
- JavaScript/TypeScript
- Command line basics

### System Requirements
- **RAM**: 8GB minimum, 16GB recommended
- **Disk Space**: 5GB free
- **Network**: Stable internet connection
- **OS**: Windows 10+, macOS 10.15+, or Linux

---

## 2. INSTALLATION

### Step 1: Clone Repository
```bash
git clone https://github.com/your-username/THE-ETHEREUM-LIFE-FORM.git
cd THE-ETHEREUM-LIFE-FORM
```

### Step 2: Install Dependencies
```bash
# Install Hardhat dependencies
npm install

# Install visualization dependencies
cd visualization
npm install
cd ..
```

### Step 3: Configure Environment
```bash
# Create .env file
cp .env.example .env

# Edit .env with your settings
```

**`.env` Template:**
```env
# Network Configuration
NETWORK=localhost
RPC_URL=http://localhost:8545

# Deployment Account
PRIVATE_KEY=your_private_key_here
DEPLOYER_ADDRESS=your_address_here

# API Keys (optional)
ETHERSCAN_API_KEY=your_etherscan_key
ALCHEMY_API_KEY=your_alchemy_key

# Contract Addresses (filled after deployment)
FACTORY_ADDRESS=
REGISTRY_ADDRESS=
BREEDING_LAB_ADDRESS=
MARKETPLACE_ADDRESS=
GOD_MODE_ADDRESS=
CONSCIOUSNESS_METRICS_ADDRESS=

# Configuration
INITIAL_ORGANISMS=5
GENESIS_ENERGY=100
MUTATION_RATE=5
POPULATION_CAP=1000
```

### Step 4: Verify Installation
```bash
# Compile contracts
npx hardhat compile

# Run tests
npx hardhat test

# Check everything is working
npx hardhat --version
```

---

## 3. DEPLOYMENT

### Local Deployment (Development)

#### Step 1: Start Local Node
```bash
# Terminal 1: Start Hardhat node
npx hardhat node

# Keep this terminal running
# You should see 20 test accounts with 10000 ETH each
```

#### Step 2: Deploy Contracts
```bash
# Terminal 2: Deploy all contracts
npx hardhat run scripts/deploy-ecosystem.js --network localhost

# Or deploy individually
npx hardhat run scripts/deploy-core.js --network localhost
npx hardhat run scripts/deploy-ecosystem-contracts.js --network localhost
npx hardhat run scripts/deploy-consciousness.js --network localhost
npx hardhat run scripts/deploy-interaction.js --network localhost
```

#### Step 3: Verify Deployment
```bash
# Check deployment file was created
cat ecosystem-deployment.json

# Should contain all contract addresses
```

**Expected Output:**
```json
{
  "network": "localhost",
  "chainId": 31337,
  "deployer": "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
  "timestamp": "2024-01-15T12:00:00.000Z",
  "contracts": {
    "factory": "0x5FbDB2315678afecb367f032d93F642f64180aa3",
    "registry": "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512",
    "genome": "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0",
    ...
  },
  "genesisOrganisms": [
    "0x...",
    "0x...",
    ...
  ],
  "stats": {
    "totalOrganisms": 5,
    "livingOrganisms": 5,
    "avgGeneration": 0,
    "avgFitness": 50
  }
}
```

### Testnet Deployment (Sepolia)

#### Step 1: Get Testnet ETH
```bash
# Get Sepolia ETH from faucets:
# https://sepoliafaucet.com
# https://www.alchemy.com/faucets/ethereum-sepolia
```

#### Step 2: Update .env
```env
NETWORK=sepolia
RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_KEY
PRIVATE_KEY=your_sepolia_private_key
```

#### Step 3: Deploy
```bash
npx hardhat run scripts/deploy-ecosystem.js --network sepolia

# Wait for confirmations (3-5 minutes)
```

#### Step 4: Verify on Etherscan
```bash
npx hardhat verify --network sepolia CONTRACT_ADDRESS "constructor_args"

# Example:
npx hardhat verify --network sepolia 0x123... 0x456...
```

### Mainnet Deployment (Production)

⚠️ **WARNING**: Mainnet deployment costs real money!

#### Pre-Deployment Checklist
- [ ] All tests passing
- [ ] Security audit completed
- [ ] Sufficient ETH for deployment (~5-10 ETH)
- [ ] Contract addresses documented
- [ ] Emergency contacts ready
- [ ] Backup private keys stored securely

#### Deployment Steps
```bash
# 1. Final test on mainnet fork
npx hardhat node --fork https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY

# 2. Deploy to fork first
npx hardhat run scripts/deploy-ecosystem.js --network localhost

# 3. If successful, deploy to mainnet
npx hardhat run scripts/deploy-ecosystem.js --network mainnet

# 4. Verify all contracts
npx hardhat run scripts/verify-all.js --network mainnet
```

---

## 4. CONFIGURATION

### Initial Setup

#### Step 1: Configure MetaMask
```javascript
// Add local network to MetaMask
Network Name: Hardhat Local
RPC URL: http://localhost:8545
Chain ID: 31337
Currency Symbol: ETH

// Import test account
Private Key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
// This is Account #0 from Hardhat with 10000 ETH
```

#### Step 2: Set Admin Roles
```javascript
const { ethers } = require("hardhat");

async function setupRoles() {
    // Get contracts
    const godMode = await ethers.getContractAt("GodMode", GOD_MODE_ADDRESS);
    const breedingLab = await ethers.getContractAt("BreedingLaboratory", BREEDING_LAB_ADDRESS);

    // Grant god status
    await godMode.grantGodStatus("0xYourAdminAddress");
    console.log("God status granted");

    // Add more admins as needed
}

setupRoles();
```

#### Step 3: Set Parameters
```javascript
async function configureSystem() {
    const registry = await ethers.getContractAt("PopulationRegistry", REGISTRY_ADDRESS);

    // Set population cap
    await registry.updateEnvironment("populationCap", 10000);

    // Set mutation rate (5%)
    await registry.updateEnvironment("mutationPressure", 5);

    // Set resource pool
    await registry.addResources({ value: ethers.parseEther("1000") });

    console.log("System configured");
}

configureSystem();
```

### Safety Configuration

#### Enable Pause Functionality
```javascript
// In case of emergency
const safetyManager = await ethers.getContractAt("SafetyManager", SAFETY_MANAGER_ADDRESS);

// Pause all operations
await safetyManager.pause("Scheduled maintenance");

// Unpause when ready
await safetyManager.unpause();
```

#### Set Rate Limits
```javascript
// Prevent spam/abuse
const breedingLabSig = ethers.id("selectiveBreeding(address,address,bytes32[])").slice(0, 10);

// 1 hour cooldown between breeding calls
await safetyManager.setCooldown(breedingLabSig, 3600);

// Set daily spend limit (1000 ETH)
await safetyManager.setDailySpendLimit(ethers.parseEther("1000"));
```

---

## 5. USAGE EXAMPLES

### Example 1: Create Your First Organism

```javascript
const { ethers } = require("ethers");

// Connect to network
const provider = new ethers.JsonRpcProvider("http://localhost:8545");
const wallet = new ethers.Wallet("YOUR_PRIVATE_KEY", provider);

// Get factory contract
const factory = new ethers.Contract(
    FACTORY_ADDRESS,
    ["function createGenesisOrganism() payable returns (address)"],
    wallet
);

// Create organism
const tx = await factory.createGenesisOrganism({
    value: ethers.parseEther("100") // 100 ETH initial energy
});

console.log("Transaction:", tx.hash);

// Wait for confirmation
const receipt = await tx.wait();
console.log("Organism created!");

// Get organism address from events
const organismAddress = receipt.logs[0].args[0];
console.log("Organism address:", organismAddress);
```

### Example 2: Breed Two Organisms

```javascript
// Get breeding lab contract
const breedingLab = new ethers.Contract(
    BREEDING_LAB_ADDRESS,
    [
        "function selectiveBreeding(address,address,bytes32[]) payable returns (address)"
    ],
    wallet
);

// Define desired traits
const desiredTraits = [
    ethers.keccak256(ethers.toUtf8Bytes("fitness")),
    ethers.keccak256(ethers.toUtf8Bytes("intelligence"))
];

// Perform breeding
const breedTx = await breedingLab.selectiveBreeding(
    parent1Address,
    parent2Address,
    desiredTraits,
    { value: ethers.parseEther("10") } // 10 ETH cost
);

console.log("Breeding transaction:", breedTx.hash);

const breedReceipt = await breedTx.wait();
console.log("Offspring created!");

// Offspring address from event
const offspring = breedReceipt.logs[0].args.organism;
console.log("Offspring:", offspring);
```

### Example 3: List Organism on Marketplace

```javascript
// Get marketplace contract
const marketplace = new ethers.Contract(
    MARKETPLACE_ADDRESS,
    [
        "function listForSale(address,uint256,uint256) returns (bytes32)"
    ],
    wallet
);

// List for 50 ETH, 7 days
const listTx = await marketplace.listForSale(
    organismAddress,
    ethers.parseEther("50"),
    7 * 24 * 60 * 60 // 7 days in seconds
);

const listReceipt = await listTx.wait();
const listingId = listReceipt.logs[0].args.listingId;

console.log("Listed! Listing ID:", listingId);
```

### Example 4: Buy Organism from Marketplace

```javascript
// Buy organism
const buyTx = await marketplace.buyOrganism(listingId, {
    value: ethers.parseEther("50")
});

await buyTx.wait();
console.log("Organism purchased!");
```

### Example 5: Use God Mode Powers

```javascript
// Get god mode contract
const godMode = new ethers.Contract(
    GOD_MODE_ADDRESS,
    [
        "function triggerCatastrophe(uint8,uint256) payable returns (bytes32)"
    ],
    wallet
);

// Trigger meteor strike with 30% casualties
const catTx = await godMode.triggerCatastrophe(
    0, // METEOR_STRIKE
    30, // 30% severity
    { value: ethers.parseEther("10") } // 10 ETH cost
);

await catTx.wait();
console.log("Catastrophe triggered!");
```

### Example 6: Monitor Events

```javascript
// Listen for organism births
factory.on("OrganismCreated", (organism, generation, parent1, parent2, event) => {
    console.log("New organism born!");
    console.log("Address:", organism);
    console.log("Generation:", generation.toString());
    console.log("Parents:", parent1, parent2);
});

// Listen for consciousness emergence
const consciousnessMetrics = new ethers.Contract(
    CONSCIOUSNESS_METRICS_ADDRESS,
    ["event ConsciousnessEmerged(address indexed,uint256,uint8,uint256)"],
    provider
);

consciousnessMetrics.on("ConsciousnessEmerged", (organism, phi, level, timestamp) => {
    console.log("🧠 CONSCIOUSNESS EMERGED!");
    console.log("Organism:", organism);
    console.log("Φ (phi):", phi.toString());
    console.log("Level:", level);
});

// Keep script running to listen for events
console.log("Listening for events...");
```

---

## 6. ERROR HANDLING

### Common Errors & Solutions

#### Error: "Insufficient payment"
```javascript
// Problem: Not sending enough ETH
await breedingLab.cloneOrganism(organism, {
    value: ethers.parseEther("10") // ❌ Too low
});

// Solution: Send correct amount
await breedingLab.cloneOrganism(organism, {
    value: ethers.parseEther("100") // ✅ Correct (100 ETH for cloning)
});
```

#### Error: "Contract paused"
```javascript
// Problem: Contract is paused
// Check pause status
const paused = await safetyManager.paused();

if (paused) {
    console.log("Contract is paused. Please wait or contact admin.");
}

// Solution: Wait for unpause or contact admin
```

#### Error: "Not a god"
```javascript
// Problem: Trying to use god mode without permission
// Check god status
const isGod = await godMode.isGod(wallet.address);

if (!isGod) {
    console.log("You need god status to use this function");
    // Contact admin to grant god status
}
```

#### Error: "Listing not found"
```javascript
// Problem: Invalid listing ID
// Get active listings first
const activeListings = await marketplace.getActiveListings();
console.log("Active listings:", activeListings);

// Use valid listing ID
const validListingId = activeListings[0];
await marketplace.buyOrganism(validListingId, { value: ethers.parseEther("50") });
```

### Error Logging

#### Enable Error Logging
```javascript
// Listen for error events
const errorHandler = new ethers.Contract(
    ERROR_HANDLER_ADDRESS,
    [
        "event ErrorLogged(string,address indexed,bytes32 indexed,string,uint256)",
        "event OperationFailed(string,address indexed,bytes32 indexed,string,uint256)"
    ],
    provider
);

// Log all errors
errorHandler.on("ErrorLogged", (errorType, caller, identifier, message, timestamp) => {
    console.error("Error:", errorType);
    console.error("Caller:", caller);
    console.error("Message:", message);
    console.error("Time:", new Date(Number(timestamp) * 1000));
});

// Log operation failures
errorHandler.on("OperationFailed", (operation, target, identifier, reason, timestamp) => {
    console.error("Operation failed:", operation);
    console.error("Target:", target);
    console.error("Reason:", reason);
});
```

### Try-Catch Pattern
```javascript
async function safeBreeding(parent1, parent2) {
    try {
        // Attempt breeding
        const tx = await breedingLab.selectiveBreeding(
            parent1,
            parent2,
            desiredTraits,
            { value: ethers.parseEther("10") }
        );

        const receipt = await tx.wait();
        console.log("✅ Breeding successful!");
        return receipt;

    } catch (error) {
        // Handle specific errors
        if (error.message.includes("Insufficient payment")) {
            console.error("❌ Not enough ETH sent");
        } else if (error.message.includes("Incompatible genetics")) {
            console.error("❌ Parents are incompatible");
        } else if (error.message.includes("paused")) {
            console.error("❌ Contract is paused");
        } else {
            console.error("❌ Unknown error:", error.message);
        }

        throw error; // Re-throw if needed
    }
}
```

---

## 7. SAFETY & SECURITY

### Security Best Practices

#### 1. Private Key Management
```bash
# ❌ NEVER DO THIS:
PRIVATE_KEY=0xac0974bec...  # Don't commit to git

# ✅ DO THIS:
# Use .env file (git ignored)
echo ".env" >> .gitignore

# Use hardware wallet for mainnet
# Use environment variables in production
export PRIVATE_KEY="0x..."
```

#### 2. Access Control
```javascript
// Only grant god status to trusted addresses
const trustedAddresses = [
    "0xTrustedAdmin1...",
    "0xTrustedAdmin2..."
];

for (const addr of trustedAddresses) {
    await godMode.grantGodStatus(addr);
}

// Remove compromised addresses immediately
await godMode.revokeGodStatus("0xCompromisedAddress...");
```

#### 3. Rate Limiting
```javascript
// Prevent spam attacks
const functionsToLimit = [
    { sig: "selectiveBreeding(address,address,bytes32[])", cooldown: 3600 }, // 1 hour
    { sig: "crisprEdit(address,bytes32,bytes32)", cooldown: 1800 }, // 30 min
    { sig: "cloneOrganism(address)", cooldown: 7200 } // 2 hours
];

for (const func of functionsToLimit) {
    const funcSig = ethers.id(func.sig).slice(0, 10);
    await safetyManager.setCooldown(funcSig, func.cooldown);
}
```

#### 4. Emergency Procedures
```javascript
// Emergency stop procedure
async function emergencyShutdown() {
    console.log("🚨 INITIATING EMERGENCY SHUTDOWN");

    // 1. Activate emergency stop
    await safetyManager.activateEmergencyStop("Security incident");

    // 2. Pause all contracts
    await safetyManager.pause("Emergency");

    // 3. Notify admins
    console.log("📧 Admins notified");

    // 4. Log incident
    console.log("📝 Incident logged");

    console.log("✅ Emergency shutdown complete");
}
```

### Monitoring & Alerts

#### Set Up Monitoring
```javascript
// Monitor important metrics
async function monitorSystem() {
    const stats = await factory.getEcosystemStats();

    console.log("📊 System Status:");
    console.log("Living organisms:", stats.livingOrganisms.toString());
    console.log("Average fitness:", stats.avgFitness.toString());

    // Alert if population too low
    if (stats.livingOrganisms < 10) {
        console.log("⚠️ WARNING: Low population!");
    }

    // Alert if average fitness declining
    if (stats.avgFitness < 30) {
        console.log("⚠️ WARNING: Low fitness!");
    }
}

// Run every hour
setInterval(monitorSystem, 3600000);
```

---

## 8. TROUBLESHOOTING

### Common Issues

#### Issue: Transaction Fails
```javascript
// Debug transaction
const tx = await factory.createGenesisOrganism({ value: ethers.parseEther("100") });

try {
    const receipt = await tx.wait();
    console.log("Success!");
} catch (error) {
    console.error("Transaction failed");
    console.error("Error:", error.message);

    // Check transaction status
    const txInfo = await provider.getTransaction(tx.hash);
    console.log("Transaction info:", txInfo);

    // Check if it was reverted
    if (error.message.includes("reverted")) {
        console.log("Transaction was reverted");
    }
}
```

#### Issue: Gas Estimation Fails
```javascript
// Manually set gas limit
const tx = await factory.createGenesisOrganism({
    value: ethers.parseEther("100"),
    gasLimit: 1000000 // Manual gas limit
});
```

#### Issue: Contract Not Deployed
```bash
# Check if contract exists
npx hardhat console --network localhost

# In console:
const code = await ethers.provider.getCode("0xContractAddress");
console.log("Code:", code);

# If "0x", contract not deployed
# Redeploy contracts
```

---

## 9. ADVANCED FEATURES

### Batch Operations
```javascript
// Create multiple organisms in one transaction
async function batchCreate(count) {
    const tx = await factory.createGenesisPopulation(count, {
        value: ethers.parseEther((100 * count).toString())
    });

    await tx.wait();
    console.log(`Created ${count} organisms`);
}

await batchCreate(10); // Create 10 organisms
```

### Custom Breeding Programs
```javascript
// Long-term breeding project
async function breedingProgram() {
    // Step 1: Create project
    const projectTx = await breedingLab.createBreedingProject(
        "Super Intelligence",
        [ethers.keccak256(ethers.toUtf8Bytes("intelligence"))],
        [champion1, champion2],
        { value: ethers.parseEther("100") }
    );

    const projectReceipt = await projectTx.wait();
    const projectId = projectReceipt.logs[0].args.projectId;

    // Step 2: Selective breeding rounds
    for (let i = 0; i < 5; i++) {
        const offspring = await breedingLab.selectiveBreeding(
            champion1,
            champion2,
            [ethers.keccak256(ethers.toUtf8Bytes("intelligence"))],
            { value: ethers.parseEther("10") }
        );

        console.log(`Round ${i + 1} complete. Offspring:`, offspring);
    }
}
```

### Automated Evolution
```javascript
// Auto-trigger evolution cycles
async function autoEvolution() {
    const evolutionEngine = await ethers.getContractAt("EvolutionEngine", EVOLUTION_ENGINE_ADDRESS);

    setInterval(async () => {
        const [shouldTrigger, triggerType] = await evolutionEngine.checkEvolutionTrigger();

        if (shouldTrigger) {
            console.log("Triggering evolution...");
            await factory.runEvolutionCycle();
            console.log("Evolution complete!");
        }
    }, 60000); // Check every minute
}
```

---

## 10. API REFERENCE

### Core Contracts

#### OrganismFactory
```solidity
// Create single organism
function createGenesisOrganism() payable returns (address)

// Create multiple organisms
function createGenesisPopulation(uint256 count) payable returns (address[])

// Trigger reproduction
function triggerMitosis(address payable parent) payable returns (address)
function triggerMating(address payable parent1, address payable parent2) payable returns (address)

// Evolution
function runEvolutionCycle() returns (uint256)

// Stats
function getEcosystemStats() view returns (...)
```

#### BreedingLaboratory
```solidity
// Breeding techniques
function selectiveBreeding(address,address,bytes32[]) payable returns (address)
function crisprEdit(address,bytes32,bytes32) payable returns (bool)
function cloneOrganism(address) payable returns (address)
function createHybrid(address,address) payable returns (address)
function induceMutations(address,uint256) payable returns (bool)
function accelerateEvolution(address,uint256) payable returns (bool)

// Projects
function createBreedingProject(string,bytes32[],address[]) payable returns (bytes32)
function createDesignerSpec(string,bytes32[],uint256[],uint256,uint256) payable returns (bytes32)
```

#### OrganismMarketplace
```solidity
// Listings
function listForSale(address,uint256,uint256) returns (bytes32)
function buyOrganism(bytes32) payable

// Auctions
function createAuction(address,uint256,uint256) returns (bytes32)
function placeBid(bytes32) payable
function endAuction(bytes32)

// Breeding rights
function offerBreedingRights(address,uint256,uint256,uint256) returns (bytes32)
function purchaseBreedingRights(bytes32) payable

// Patents
function registerPatent(bytes32,string,uint256,uint256,uint256) returns (bytes32)

// Custom orders
function placeCustomOrder(bytes32[],uint256[],uint256) payable returns (bytes32)
function fulfillCustomOrder(bytes32,address)
```

#### GodMode
```solidity
// Divine powers
function injectResources(uint256) payable returns (bytes32)
function triggerCatastrophe(uint8,uint256) payable returns (bytes32)
function applySelectivePressure(bytes32,bool,uint256,uint256) payable returns (bytes32)
function changeEnvironment(string,uint256,uint256) payable returns (bytes32)
function performMiracle(address,bytes32,uint256) payable returns (bytes32)
function accelerateTime(uint256) payable returns (bytes32)
function warpReality(string,uint256) payable returns (bytes32)
function massExtinction(string) payable returns (bytes32)

// Access control
function grantGodStatus(address)
```

---

## 📞 SUPPORT

### Getting Help

- **Documentation**: Read this guide and other .md files
- **GitHub Issues**: https://github.com/your-repo/issues
- **Discord**: https://discord.gg/your-server
- **Email**: support@ethereumlifeform.com

### Reporting Bugs

```markdown
**Bug Report Template:**
- Description:
- Steps to reproduce:
- Expected behavior:
- Actual behavior:
- Error messages:
- Contract addresses:
- Transaction hash:
- Network:
```

---

## ✅ CHECKLIST

### Pre-Deployment
- [ ] All tests passing
- [ ] Contracts compiled successfully
- [ ] .env configured correctly
- [ ] Sufficient ETH in deployer account
- [ ] Network configuration correct
- [ ] MetaMask connected to correct network

### Post-Deployment
- [ ] All contracts deployed successfully
- [ ] Contract addresses saved
- [ ] Roles configured (owner, admin, gods)
- [ ] Parameters set (population cap, mutation rate, etc.)
- [ ] Safety measures enabled (pause, rate limits)
- [ ] Monitoring set up
- [ ] Genesis organisms created
- [ ] System tested end-to-end

### Production Readiness
- [ ] Security audit completed
- [ ] Emergency procedures documented
- [ ] Admin contacts established
- [ ] Backup systems in place
- [ ] Monitoring & alerting active
- [ ] Documentation complete
- [ ] User support ready

---

**🧬 READY TO CREATE DIGITAL LIFE! 🧬**

Follow this guide step-by-step and you'll have a fully functional evolutionary ecosystem running on Ethereum! 🚀✨
