const hre = require("hardhat");

async function main() {
  console.log("🧬 Deploying Ethereum Life Form - Evolutionary Algorithm...\n");

  // Get deployer account
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);
  console.log("Account balance:", (await hre.ethers.provider.getBalance(deployer.address)).toString());
  console.log("");

  // Deploy OrganismFactory (which deploys Registry and EvolutionEngine)
  console.log("📦 Deploying OrganismFactory...");
  const OrganismFactory = await hre.ethers.getContractFactory("OrganismFactory");
  const factory = await OrganismFactory.deploy();
  await factory.waitForDeployment();

  const factoryAddress = await factory.getAddress();
  console.log("✅ OrganismFactory deployed to:", factoryAddress);
  console.log("");

  // Get deployed contract addresses
  const registryAddress = await factory.registry();
  const evolutionEngineAddress = await factory.evolutionEngine();

  console.log("📊 PopulationRegistry deployed to:", registryAddress);
  console.log("🧬 EvolutionEngine deployed to:", evolutionEngineAddress);
  console.log("");

  // Create initial genesis population
  console.log("🌱 Creating genesis population...");
  const genesisCount = 5;
  const energyPerOrganism = hre.ethers.parseEther("100");
  const totalEnergy = energyPerOrganism * BigInt(genesisCount);

  const tx = await factory.createGenesisPopulation(genesisCount, { value: totalEnergy });
  await tx.wait();

  const genesisOrganisms = await factory.getGenesisOrganisms();
  console.log("✅ Created", genesisCount, "genesis organisms");
  console.log("");

  // Display genesis organisms
  console.log("🦠 Genesis Organisms:");
  for (let i = 0; i < genesisOrganisms.length; i++) {
    console.log(`   ${i + 1}. ${genesisOrganisms[i]}`);
  }
  console.log("");

  // Get ecosystem stats
  const stats = await factory.getEcosystemStats();
  console.log("📈 Ecosystem Statistics:");
  console.log("   Total Organisms:", stats.totalOrganisms.toString());
  console.log("   Living Organisms:", stats.livingOrganisms.toString());
  console.log("   Average Generation:", stats.avgGeneration.toString());
  console.log("   Genesis Count:", stats.genesisCount.toString());
  console.log("");

  // Get environment info
  const registry = await hre.ethers.getContractAt("PopulationRegistry", registryAddress);
  const environment = await registry.environment();
  console.log("🌍 Environment Configuration:");
  console.log("   Resource Pool:", hre.ethers.formatEther(environment.resourcePool), "ETH");
  console.log("   Population Cap:", environment.populationCap.toString());
  console.log("   Selection Pressure:", environment.selectionPressure.toString());
  console.log("   Mutation Pressure:", environment.mutationPressure.toString());
  console.log("   Cosmic Ray Frequency:", environment.cosmicRayFrequency.toString());
  console.log("");

  // Get evolution config
  const evolutionEngine = await hre.ethers.getContractAt("EvolutionEngine", evolutionEngineAddress);
  const config = await evolutionEngine.config();
  console.log("⚙️  Evolution Configuration:");
  console.log("   Block Interval:", config.blockInterval.toString());
  console.log("   Resource Threshold:", hre.ethers.formatEther(config.resourceThreshold), "ETH");
  console.log("   Population Threshold:", config.populationThreshold.toString());
  console.log("   Time-Based Evolution:", config.timeBasedEnabled);
  console.log("   Resource-Based Evolution:", config.resourceBasedEnabled);
  console.log("   Competition-Based Evolution:", config.competitionBasedEnabled);
  console.log("   Random Cosmic Rays:", config.randomEnabled);
  console.log("");

  // Summary
  console.log("=" .repeat(60));
  console.log("🎉 DEPLOYMENT COMPLETE!");
  console.log("=" .repeat(60));
  console.log("");
  console.log("Contract Addresses:");
  console.log("-------------------");
  console.log("OrganismFactory:", factoryAddress);
  console.log("PopulationRegistry:", registryAddress);
  console.log("EvolutionEngine:", evolutionEngineAddress);
  console.log("");
  console.log("Next Steps:");
  console.log("-----------");
  console.log("1. Interact with organisms using the factory");
  console.log("2. Trigger mitosis or mating for reproduction");
  console.log("3. Monitor fitness evolution over time");
  console.log("4. Trigger evolution cycles manually or wait for automatic triggers");
  console.log("5. Watch the population evolve and adapt!");
  console.log("");
  console.log("Darwin would be proud! 🧬🌱");
  console.log("");

  // Save deployment info
  const deploymentInfo = {
    network: hre.network.name,
    deployer: deployer.address,
    timestamp: new Date().toISOString(),
    contracts: {
      factory: factoryAddress,
      registry: registryAddress,
      evolutionEngine: evolutionEngineAddress,
    },
    genesisOrganisms: genesisOrganisms,
  };

  const fs = require("fs");
  fs.writeFileSync(
    "deployment.json",
    JSON.stringify(deploymentInfo, null, 2)
  );
  console.log("📄 Deployment info saved to deployment.json");
  console.log("");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
