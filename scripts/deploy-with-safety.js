const hre = require("hardhat");
const fs = require("fs");

/**
 * Complete deployment script with error handling and safety features
 */
async function main() {
  console.log("=".repeat(80));
  console.log("🧬 THE ETHEREUM LIFE FORM - SAFE DEPLOYMENT");
  console.log("=".repeat(80));
  console.log("");

  const [deployer] = await hre.ethers.getSigners();
  console.log("📡 Deploying with account:", deployer.address);
  console.log("💰 Account balance:", hre.ethers.formatEther(await hre.ethers.provider.getBalance(deployer.address)), "ETH");
  console.log("");

  const deployedContracts = {};
  const deploymentErrors = [];

  try {
    // ==================== 1. DEPLOY SAFETY & ERROR HANDLING ====================
    console.log("🛡️  Deploying Safety Infrastructure...\n");

    // Deploy ErrorHandler
    console.log("Deploying ErrorHandler...");
    try {
      const ErrorHandler = await hre.ethers.getContractFactory("ErrorHandler");
      const errorHandler = await ErrorHandler.deploy();
      await errorHandler.waitForDeployment();
      deployedContracts.errorHandler = await errorHandler.getAddress();
      console.log("✅ ErrorHandler:", deployedContracts.errorHandler);
    } catch (error) {
      console.error("❌ ErrorHandler deployment failed:", error.message);
      deploymentErrors.push({ contract: "ErrorHandler", error: error.message });
    }

    // Deploy SafetyManager
    console.log("Deploying SafetyManager...");
    try {
      const SafetyManager = await hre.ethers.getContractFactory("SafetyManager");
      const safetyManager = await SafetyManager.deploy();
      await safetyManager.waitForDeployment();
      deployedContracts.safetyManager = await safetyManager.getAddress();
      console.log("✅ SafetyManager:", deployedContracts.safetyManager);
    } catch (error) {
      console.error("❌ SafetyManager deployment failed:", error.message);
      deploymentErrors.push({ contract: "SafetyManager", error: error.message });
    }

    console.log("");

    // ==================== 2. DEPLOY CORE CONTRACTS ====================
    console.log("🧬 Deploying Core Contracts...\n");

    // Deploy Genome
    console.log("Deploying Genome...");
    try {
      const Genome = await hre.ethers.getContractFactory("Genome");
      const genome = await Genome.deploy();
      await genome.waitForDeployment();
      deployedContracts.genome = await genome.getAddress();
      console.log("✅ Genome:", deployedContracts.genome);
    } catch (error) {
      console.error("❌ Genome deployment failed:", error.message);
      deploymentErrors.push({ contract: "Genome", error: error.message });
      throw error; // Critical contract
    }

    // Deploy PopulationRegistry
    console.log("Deploying PopulationRegistry...");
    try {
      const PopulationRegistry = await hre.ethers.getContractFactory("PopulationRegistry");
      const registry = await PopulationRegistry.deploy();
      await registry.waitForDeployment();
      deployedContracts.registry = await registry.getAddress();
      console.log("✅ PopulationRegistry:", deployedContracts.registry);
    } catch (error) {
      console.error("❌ PopulationRegistry deployment failed:", error.message);
      deploymentErrors.push({ contract: "PopulationRegistry", error: error.message });
      throw error; // Critical contract
    }

    // Deploy EvolutionEngine
    console.log("Deploying EvolutionEngine...");
    try {
      const EvolutionEngine = await hre.ethers.getContractFactory("EvolutionEngine");
      const evolutionEngine = await EvolutionEngine.deploy(deployedContracts.registry);
      await evolutionEngine.waitForDeployment();
      deployedContracts.evolutionEngine = await evolutionEngine.getAddress();
      console.log("✅ EvolutionEngine:", deployedContracts.evolutionEngine);
    } catch (error) {
      console.error("❌ EvolutionEngine deployment failed:", error.message);
      deploymentErrors.push({ contract: "EvolutionEngine", error: error.message });
    }

    // Deploy OrganismFactory
    console.log("Deploying OrganismFactory...");
    try {
      const OrganismFactory = await hre.ethers.getContractFactory("OrganismFactory");
      const factory = await OrganismFactory.deploy();
      await factory.waitForDeployment();
      deployedContracts.factory = await factory.getAddress();
      console.log("✅ OrganismFactory:", deployedContracts.factory);
    } catch (error) {
      console.error("❌ OrganismFactory deployment failed:", error.message);
      deploymentErrors.push({ contract: "OrganismFactory", error: error.message });
      throw error; // Critical contract
    }

    console.log("");

    // ==================== 3. DEPLOY INTERACTION CONTRACTS ====================
    console.log("🧪 Deploying Interaction Contracts...\n");

    // Deploy BreedingLaboratory
    console.log("Deploying BreedingLaboratory...");
    try {
      const BreedingLaboratory = await hre.ethers.getContractFactory("BreedingLaboratory");
      const breedingLab = await BreedingLaboratory.deploy(deployedContracts.factory);
      await breedingLab.waitForDeployment();
      deployedContracts.breedingLaboratory = await breedingLab.getAddress();
      console.log("✅ BreedingLaboratory:", deployedContracts.breedingLaboratory);
    } catch (error) {
      console.error("❌ BreedingLaboratory deployment failed:", error.message);
      deploymentErrors.push({ contract: "BreedingLaboratory", error: error.message });
    }

    // Deploy OrganismMarketplace
    console.log("Deploying OrganismMarketplace...");
    try {
      const OrganismMarketplace = await hre.ethers.getContractFactory("OrganismMarketplace");
      const marketplace = await OrganismMarketplace.deploy();
      await marketplace.waitForDeployment();
      deployedContracts.marketplace = await marketplace.getAddress();
      console.log("✅ OrganismMarketplace:", deployedContracts.marketplace);
    } catch (error) {
      console.error("❌ OrganismMarketplace deployment failed:", error.message);
      deploymentErrors.push({ contract: "OrganismMarketplace", error: error.message });
    }

    // Deploy GodMode
    console.log("Deploying GodMode...");
    try {
      const GodMode = await hre.ethers.getContractFactory("GodMode");
      // GodMode needs registry, envPressure, economy - use placeholder for now
      const godMode = await GodMode.deploy(
        deployedContracts.registry,
        hre.ethers.ZeroAddress, // Placeholder for envPressure
        hre.ethers.ZeroAddress  // Placeholder for economy
      );
      await godMode.waitForDeployment();
      deployedContracts.godMode = await godMode.getAddress();
      console.log("✅ GodMode:", deployedContracts.godMode);
    } catch (error) {
      console.error("❌ GodMode deployment failed:", error.message);
      deploymentErrors.push({ contract: "GodMode", error: error.message });
    }

    console.log("");

    // ==================== 4. CONFIGURE SAFETY ====================
    console.log("🛡️  Configuring Safety Features...\n");

    if (deployedContracts.safetyManager) {
      try {
        const safetyManager = await hre.ethers.getContractAt("SafetyManager", deployedContracts.safetyManager);

        // Add deployer as admin
        console.log("Adding deployer as admin...");
        // Already admin from constructor, just log
        console.log("✅ Deployer is admin");

        // Set rate limits
        console.log("Setting rate limits...");
        const breedingSig = hre.ethers.id("selectiveBreeding(address,address,bytes32[])").slice(0, 10);
        await safetyManager.setCooldown(breedingSig, 3600); // 1 hour
        console.log("✅ Breeding cooldown: 1 hour");

        const crisprSig = hre.ethers.id("crisprEdit(address,bytes32,bytes32)").slice(0, 10);
        await safetyManager.setCooldown(crisprSig, 1800); // 30 min
        console.log("✅ CRISPR cooldown: 30 minutes");

        // Set daily spend limit
        await safetyManager.setDailySpendLimit(hre.ethers.parseEther("1000"));
        console.log("✅ Daily spend limit: 1000 ETH");

      } catch (error) {
        console.error("❌ Safety configuration failed:", error.message);
        deploymentErrors.push({ contract: "SafetyManager", error: `Configuration: ${error.message}` });
      }
    }

    console.log("");

    // ==================== 5. CREATE GENESIS ORGANISMS ====================
    console.log("🌱 Creating Genesis Population...\n");

    if (deployedContracts.factory) {
      try {
        const factory = await hre.ethers.getContractAt("OrganismFactory", deployedContracts.factory);

        console.log("Creating 5 genesis organisms...");
        const genesisTx = await factory.createGenesisPopulation(5, {
          value: hre.ethers.parseEther("500")
        });
        await genesisTx.wait();

        const genesisOrganisms = await factory.getGenesisOrganisms();
        deployedContracts.genesisOrganisms = genesisOrganisms;
        console.log("✅ Created", genesisOrganisms.length, "organisms");

        // Log organism addresses
        genesisOrganisms.forEach((addr, i) => {
          console.log(`   Organism ${i + 1}:`, addr);
        });

      } catch (error) {
        console.error("❌ Genesis creation failed:", error.message);
        deploymentErrors.push({ contract: "Factory", error: `Genesis: ${error.message}` });
      }
    }

    console.log("");

    // ==================== 6. SAVE DEPLOYMENT INFO ====================
    console.log("💾 Saving Deployment Information...\n");

    const deploymentInfo = {
      network: hre.network.name,
      chainId: (await hre.ethers.provider.getNetwork()).chainId.toString(),
      deployer: deployer.address,
      timestamp: new Date().toISOString(),
      contracts: deployedContracts,
      errors: deploymentErrors,
      gasUsed: {
        // Would track gas usage in production
      }
    };

    // Save to file
    const filename = `deployment-${hre.network.name}-${Date.now()}.json`;
    fs.writeFileSync(filename, JSON.stringify(deploymentInfo, null, 2));
    console.log("✅ Saved to:", filename);

    // Also save as latest
    fs.writeFileSync("deployment-latest.json", JSON.stringify(deploymentInfo, null, 2));
    console.log("✅ Saved to: deployment-latest.json");

    console.log("");

    // ==================== 7. DEPLOYMENT SUMMARY ====================
    console.log("=".repeat(80));
    console.log("📊 DEPLOYMENT SUMMARY");
    console.log("=".repeat(80));
    console.log("");

    console.log("✅ Successfully Deployed:", Object.keys(deployedContracts).length - (deployedContracts.genesisOrganisms ? 1 : 0), "contracts");

    if (deploymentErrors.length > 0) {
      console.log("❌ Failed Deployments:", deploymentErrors.length);
      console.log("");
      console.log("Errors:");
      deploymentErrors.forEach(err => {
        console.log(`   - ${err.contract}: ${err.error}`);
      });
    }

    console.log("");
    console.log("📋 Contract Addresses:");
    console.log("─".repeat(80));
    for (const [name, address] of Object.entries(deployedContracts)) {
      if (name !== "genesisOrganisms" && address) {
        console.log(`   ${name.padEnd(25)}: ${address}`);
      }
    }
    console.log("─".repeat(80));

    console.log("");
    console.log("🧬 Genesis Organisms:", deployedContracts.genesisOrganisms?.length || 0);

    console.log("");
    console.log("=".repeat(80));
    console.log("✨ DEPLOYMENT COMPLETE!");
    console.log("=".repeat(80));
    console.log("");

    console.log("📖 Next Steps:");
    console.log("   1. Verify contracts on Etherscan (if on testnet/mainnet)");
    console.log("   2. Configure additional parameters");
    console.log("   3. Grant god status to admins");
    console.log("   4. Start visualization frontend");
    console.log("   5. Monitor ecosystem health");
    console.log("");

    console.log("📚 Documentation:");
    console.log("   - HOW_TO_USE.md - Complete usage guide");
    console.log("   - INTERACTION_GUIDE.md - Interaction examples");
    console.log("   - ECOSYSTEM.md - Ecosystem features");
    console.log("   - CONSCIOUSNESS.md - Consciousness tracking");
    console.log("");

    return deploymentInfo;

  } catch (error) {
    console.error("");
    console.error("=".repeat(80));
    console.error("❌ DEPLOYMENT FAILED");
    console.error("=".repeat(80));
    console.error("");
    console.error("Error:", error.message);
    console.error("");
    console.error("Stack trace:");
    console.error(error.stack);
    console.error("");

    // Save error info
    const errorInfo = {
      network: hre.network.name,
      deployer: deployer.address,
      timestamp: new Date().toISOString(),
      error: error.message,
      stack: error.stack,
      partialDeployment: deployedContracts,
      errors: deploymentErrors
    };

    fs.writeFileSync(
      `deployment-error-${Date.now()}.json`,
      JSON.stringify(errorInfo, null, 2)
    );

    console.error("💾 Error info saved to deployment-error-*.json");
    console.error("");

    process.exit(1);
  }
}

// Run deployment
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
