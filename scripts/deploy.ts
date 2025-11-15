import { ethers } from "hardhat";

async function main() {
  console.log("🧬 Deploying The Ethereum Life Form contracts...\n");

  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);
  console.log(
    "Account balance:",
    ethers.formatEther(await ethers.provider.getBalance(deployer.address)),
    "ETH\n"
  );

  // Deploy OrganismFactory
  console.log("📦 Deploying OrganismFactory...");
  const OrganismFactory = await ethers.getContractFactory("OrganismFactory");
  const factory = await OrganismFactory.deploy(deployer.address);
  await factory.waitForDeployment();
  const factoryAddress = await factory.getAddress();
  console.log("✅ OrganismFactory deployed to:", factoryAddress);

  // Deploy Ecosystem
  console.log("\n🌍 Deploying Ecosystem...");
  const Ecosystem = await ethers.getContractFactory("Ecosystem");
  const ecosystem = await Ecosystem.deploy(factoryAddress, deployer.address);
  await ecosystem.waitForDeployment();
  const ecosystemAddress = await ecosystem.getAddress();
  console.log("✅ Ecosystem deployed to:", ecosystemAddress);

  // Set ecosystem in factory
  console.log("\n🔗 Linking Factory to Ecosystem...");
  const tx = await factory.setEcosystem(ecosystemAddress);
  await tx.wait();
  console.log("✅ Ecosystem linked to Factory");

  // Get organism implementation address
  const implementationAddress = await factory.organismImplementation();
  console.log("\n📄 DigitalOrganism implementation:", implementationAddress);

  console.log("\n" + "=".repeat(60));
  console.log("🎉 Deployment Complete!");
  console.log("=".repeat(60));
  console.log("\nContract Addresses:");
  console.log("-------------------");
  console.log("OrganismFactory:", factoryAddress);
  console.log("Ecosystem:", ecosystemAddress);
  console.log("DigitalOrganism Implementation:", implementationAddress);
  console.log("\n" + "=".repeat(60));

  console.log("\n📝 Add these to your .env file:");
  console.log(`NEXT_PUBLIC_ORGANISM_FACTORY_ADDRESS=${factoryAddress}`);
  console.log(`NEXT_PUBLIC_ECOSYSTEM_ADDRESS=${ecosystemAddress}`);

  // Create a genesis organism as a test
  console.log("\n🌱 Creating test genesis organism...");
  const createTx = await factory.createGenesisOrganism(deployer.address);
  const receipt = await createTx.wait();

  // Find the OrganismCreated event
  const event = receipt?.logs.find((log: any) => {
    try {
      const parsed = factory.interface.parseLog(log);
      return parsed?.name === "OrganismCreated";
    } catch {
      return false;
    }
  });

  if (event) {
    const parsed = factory.interface.parseLog(event);
    console.log("✅ Test organism created at:", parsed?.args[0]);
    console.log("   DNA Hash:", parsed?.args[3]);
  }

  console.log("\n🧬 The Ethereum Life Form is ready to evolve!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
