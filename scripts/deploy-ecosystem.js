const hre = require("hardhat");

async function main() {
  console.log("🌍 Deploying Complete Ethereum Life Form Ecosystem...\n");
  console.log("=" .repeat(80));

  const [deployer] = await hre.ethers.getSigners();
  console.log("Deployer:", deployer.address);
  console.log("Balance:", hre.ethers.formatEther(await hre.ethers.provider.getBalance(deployer.address)), "ETH");
  console.log("=" .repeat(80));
  console.log("");

  const deployedContracts = {};

  // 1. Deploy Nutrient Token
  console.log("🌱 Deploying NutrientToken...");
  const NutrientToken = await hre.ethers.getContractFactory("NutrientToken");
  const nutrientToken = await NutrientToken.deploy();
  await nutrientToken.waitForDeployment();
  deployedContracts.nutrientToken = await nutrientToken.getAddress();
  console.log("✅ NutrientToken:", deployedContracts.nutrientToken);
  console.log("");

  // 2. Deploy Resource Economy
  console.log("💰 Deploying ResourceEconomy...");
  const ResourceEconomy = await hre.ethers.getContractFactory("ResourceEconomy");
  const economy = await ResourceEconomy.deploy(deployedContracts.nutrientToken);
  await economy.waitForDeployment();
  deployedContracts.economy = await economy.getAddress();
  console.log("✅ ResourceEconomy:", deployedContracts.economy);
  console.log("");

  // 3. Deploy OrganismFactory (includes Registry and EvolutionEngine)
  console.log("🧬 Deploying OrganismFactory...");
  const OrganismFactory = await hre.ethers.getContractFactory("OrganismFactory");
  const factory = await OrganismFactory.deploy();
  await factory.waitForDeployment();
  deployedContracts.factory = await factory.getAddress();

  deployedContracts.registry = await factory.registry();
  deployedContracts.evolutionEngine = await factory.evolutionEngine();

  console.log("✅ OrganismFactory:", deployedContracts.factory);
  console.log("✅ PopulationRegistry:", deployedContracts.registry);
  console.log("✅ EvolutionEngine:", deployedContracts.evolutionEngine);
  console.log("");

  // 4. Deploy PredatorPrey
  console.log("🦁 Deploying PredatorPrey...");
  const PredatorPrey = await hre.ethers.getContractFactory("PredatorPrey");
  const predatorPrey = await PredatorPrey.deploy(deployedContracts.economy);
  await predatorPrey.waitForDeployment();
  deployedContracts.predatorPrey = await predatorPrey.getAddress();
  console.log("✅ PredatorPrey:", deployedContracts.predatorPrey);
  console.log("");

  // 5. Deploy Symbiosis
  console.log("🤝 Deploying Symbiosis...");
  const Symbiosis = await hre.ethers.getContractFactory("Symbiosis");
  const symbiosis = await Symbiosis.deploy(deployedContracts.economy);
  await symbiosis.waitForDeployment();
  deployedContracts.symbiosis = await symbiosis.getAddress();
  console.log("✅ Symbiosis:", deployedContracts.symbiosis);
  console.log("");

  // 6. Deploy Environmental Pressure
  console.log("🌦️  Deploying EnvironmentalPressure...");
  const EnvironmentalPressure = await hre.ethers.getContractFactory("EnvironmentalPressure");
  const envPressure = await EnvironmentalPressure.deploy();
  await envPressure.waitForDeployment();
  deployedContracts.environmentalPressure = await envPressure.getAddress();
  console.log("✅ EnvironmentalPressure:", deployedContracts.environmentalPressure);
  console.log("");

  // 7. Deploy Population Dynamics
  console.log("📈 Deploying PopulationDynamics...");
  const PopulationDynamics = await hre.ethers.getContractFactory("PopulationDynamics");
  const popDynamics = await PopulationDynamics.deploy(deployedContracts.registry);
  await popDynamics.waitForDeployment();
  deployedContracts.populationDynamics = await popDynamics.getAddress();
  console.log("✅ PopulationDynamics:", deployedContracts.populationDynamics);
  console.log("");

  // 8. Initialize Ecosystem
  console.log("🌱 Initializing Ecosystem...\n");

  // Create resource pools
  console.log("Creating resource pools...");
  const poolTx = await economy.createResourcePool("Genesis Pool", hre.ethers.parseEther("1000"), 10, {
    value: hre.ethers.parseEther("100")
  });
  await poolTx.wait();
  console.log("✅ Genesis resource pool created");

  // Create population zones
  console.log("Creating population zones...");
  const zoneTx = await popDynamics.createZone("Primary Habitat", 5000, 500000);
  await zoneTx.wait();
  console.log("✅ Primary habitat created");

  // Create genesis organisms
  console.log("Creating genesis population (5 organisms)...");
  const genesisTx = await factory.createGenesisPopulation(5, {
    value: hre.ethers.parseEther("500")
  });
  await genesisTx.wait();
  const genesisOrganisms = await factory.getGenesisOrganisms();
  console.log("✅ Genesis population created:", genesisOrganisms.length, "organisms");

  // Get ecosystem stats
  const stats = await factory.getEcosystemStats();
  console.log("\n📊 Initial Ecosystem Statistics:");
  console.log("   Total Organisms:", stats.totalOrganisms.toString());
  console.log("   Living Organisms:", stats.livingOrganisms.toString());
  console.log("   Genesis Count:", stats.genesisCount.toString());

  // Get environment
  const registry = await hre.ethers.getContractAt("PopulationRegistry", deployedContracts.registry);
  const env = await registry.environment();
  console.log("\n🌍 Environment Configuration:");
  console.log("   Resource Pool:", hre.ethers.formatEther(env.resourcePool), "ETH");
  console.log("   Population Cap:", env.populationCap.toString());
  console.log("   Selection Pressure:", env.selectionPressure.toString());
  console.log("   Mutation Pressure:", env.mutationPressure.toString());

  // Get nutrient token info
  const nutrientSupply = await nutrientToken.totalSupply();
  const season = await nutrientToken.getCurrentSeason();
  console.log("\n🌱 Nutrient Economy:");
  console.log("   Total Supply:", hre.ethers.formatEther(nutrientSupply), "NUT");
  console.log("   Current Season:", season.seasonName);
  console.log("   Season Multiplier:", season.multiplier.toString());

  // Get trophic pyramid
  const pyramid = await economy.getTrophicPyramid();
  console.log("\n🔺 Trophic Pyramid:");
  console.log("   Producers:", pyramid.producers.toString());
  console.log("   Primary Consumers:", pyramid.primary.toString());
  console.log("   Secondary Consumers:", pyramid.secondary.toString());
  console.log("   Tertiary Consumers:", pyramid.tertiary.toString());
  console.log("   Decomposers:", pyramid.decomposers.toString());

  // Get environmental stats
  const envStats = await envPressure.getEnvironmentalStats();
  console.log("\n🌦️  Environmental Conditions:");
  console.log("   Climate:", ["TEMPERATE", "HOT", "COLD", "VOLATILE", "STABLE"][envStats.climate]);
  console.log("   Current Event:", ["CALM", "STORM", "DROUGHT", "FLOOD", "EARTHQUAKE", "MIGRATION", "PREDATION", "EXTINCTION", "SPECIATION", "COLONIZATION"][envStats.currentEvent]);
  console.log("   Gas Climate:", hre.ethers.formatUnits(envStats.gasClimate, "gwei"), "gwei");
  console.log("   Congestion:", envStats.congestion.toString() + "%");
  console.log("   MEV Pressure:", envStats.mevPressure.toString());

  console.log("\n" + "=".repeat(80));
  console.log("🎉 ECOSYSTEM DEPLOYMENT COMPLETE!");
  console.log("=".repeat(80));

  // Contract addresses summary
  console.log("\n📋 Contract Addresses:");
  console.log("─".repeat(80));
  for (const [name, address] of Object.entries(deployedContracts)) {
    console.log(`   ${name.padEnd(25)}: ${address}`);
  }
  console.log("─".repeat(80));

  // Save deployment info
  const fs = require("fs");
  const deploymentInfo = {
    network: hre.network.name,
    deployer: deployer.address,
    timestamp: new Date().toISOString(),
    blockNumber: await hre.ethers.provider.getBlockNumber(),
    contracts: deployedContracts,
    genesisOrganisms: genesisOrganisms,
    stats: {
      totalOrganisms: stats.totalOrganisms.toString(),
      livingOrganisms: stats.livingOrganisms.toString(),
      genesisCount: stats.genesisCount.toString()
    }
  };

  fs.writeFileSync(
    "ecosystem-deployment.json",
    JSON.stringify(deploymentInfo, null, 2)
  );

  console.log("\n📄 Deployment info saved to ecosystem-deployment.json");

  console.log("\n✨ Next Steps:");
  console.log("─".repeat(80));
  console.log("1. Organisms can now reproduce via factory.triggerMitosis() or factory.triggerMating()");
  console.log("2. Set up predator/prey relationships with predatorPrey.hunt()");
  console.log("3. Form symbiotic relationships with symbiosis.formMutualism()");
  console.log("4. Mine nutrients with nutrientToken.mine()");
  console.log("5. Create hunting packs with predatorPrey.formPack()");
  console.log("6. Establish collectives with symbiosis.createCollective()");
  console.log("7. Watch environmental changes with envPressure.updateEnvironment()");
  console.log("8. Initiate migrations with popDynamics.initiateMigration()");
  console.log("9. Monitor population dynamics with popDynamics.updatePopulationPhase()");
  console.log("10. Trigger evolution cycles with evolutionEngine!");
  console.log("─".repeat(80));

  console.log("\n🧬 Darwin would be VERY proud! Welcome to the digital ecosystem! 🌍");
  console.log("");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
