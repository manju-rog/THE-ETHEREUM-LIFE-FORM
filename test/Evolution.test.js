const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Ethereum Life Form - Evolutionary Algorithm", function () {
  let factory;
  let registry;
  let evolutionEngine;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    // Deploy factory (which deploys registry and evolution engine)
    const OrganismFactory = await ethers.getContractFactory("OrganismFactory");
    factory = await OrganismFactory.deploy();
    await factory.waitForDeployment();

    // Get deployed contracts
    const registryAddress = await factory.registry();
    const engineAddress = await factory.evolutionEngine();

    registry = await ethers.getContractAt("PopulationRegistry", registryAddress);
    evolutionEngine = await ethers.getContractAt("EvolutionEngine", engineAddress);
  });

  describe("Deployment", function () {
    it("Should deploy all contracts successfully", async function () {
      expect(await factory.getAddress()).to.be.properAddress;
      expect(await registry.getAddress()).to.be.properAddress;
      expect(await evolutionEngine.getAddress()).to.be.properAddress;
    });

    it("Should initialize environment correctly", async function () {
      const env = await registry.environment();
      expect(env.populationCap).to.equal(10000);
      expect(env.selectionPressure).to.equal(50);
    });
  });

  describe("Genesis Creation", function () {
    it("Should create a genesis organism", async function () {
      const energy = ethers.parseEther("100");
      const tx = await factory.createGenesisOrganism({ value: energy });
      const receipt = await tx.wait();

      // Check for OrganismCreated event
      const event = receipt.logs.find(
        log => log.fragment && log.fragment.name === "OrganismCreated"
      );
      expect(event).to.not.be.undefined;

      // Check organism was created
      const genesisOrganisms = await factory.getGenesisOrganisms();
      expect(genesisOrganisms.length).to.equal(1);
    });

    it("Should create multiple genesis organisms", async function () {
      const count = 5;
      const energy = ethers.parseEther("500");
      await factory.createGenesisPopulation(count, { value: energy });

      const genesisOrganisms = await factory.getGenesisOrganisms();
      expect(genesisOrganisms.length).to.equal(count);
    });

    it("Should fail with insufficient energy", async function () {
      const energy = ethers.parseEther("50"); // Less than minimum
      await expect(
        factory.createGenesisOrganism({ value: energy })
      ).to.be.revertedWith("Insufficient energy");
    });
  });

  describe("Asexual Reproduction (Mitosis)", function () {
    let organism;

    beforeEach(async function () {
      const energy = ethers.parseEther("200");
      const tx = await factory.createGenesisOrganism({ value: energy });
      await tx.wait();

      const genesisOrganisms = await factory.getGenesisOrganisms();
      organism = await ethers.getContractAt("Organism", genesisOrganisms[0]);
    });

    it("Should perform mitosis successfully", async function () {
      // Advance state to adult
      await organism.updateState();

      // Mine blocks to age the organism
      for (let i = 0; i < 1000; i++) {
        await ethers.provider.send("evm_mine");
      }

      await organism.updateState();

      const stateBefore = await organism.state();
      console.log("State before mitosis:", stateBefore);

      // Perform mitosis
      const tx = await organism.mitosis();
      const receipt = await tx.wait();

      // Check for Mitosis event
      const event = receipt.logs.find(
        log => log.fragment && log.fragment.name === "Mitosis"
      );
      expect(event).to.not.be.undefined;

      // Check population increased
      const stats = await registry.getPopulationStats();
      expect(stats.living).to.equal(2);
    });

    it("Should split energy between parent and offspring", async function () {
      // Mine blocks to age
      for (let i = 0; i < 1000; i++) {
        await ethers.provider.send("evm_mine");
      }
      await organism.updateState();

      const energyBefore = (await organism.stats()).energy;

      await organism.mitosis();

      const energyAfter = (await organism.stats()).energy;
      expect(energyAfter).to.be.lt(energyBefore);
    });
  });

  describe("Sexual Reproduction (Mating)", function () {
    let organism1;
    let organism2;

    beforeEach(async function () {
      const energy = ethers.parseEther("500");
      await factory.createGenesisPopulation(2, { value: energy });

      const genesisOrganisms = await factory.getGenesisOrganisms();
      organism1 = await ethers.getContractAt("Organism", genesisOrganisms[0]);
      organism2 = await ethers.getContractAt("Organism", genesisOrganisms[1]);

      // Age both organisms
      for (let i = 0; i < 1000; i++) {
        await ethers.provider.send("evm_mine");
      }
      await organism1.updateState();
      await organism2.updateState();
    });

    it("Should mate successfully with compatible organism", async function () {
      const organism2Address = await organism2.getAddress();

      const tx = await organism1.mate(organism2Address);
      const receipt = await tx.wait();

      // Check for Mating event
      const event = receipt.logs.find(
        log => log.fragment && log.fragment.name === "Mating"
      );
      expect(event).to.not.be.undefined;

      // Check population increased
      const stats = await registry.getPopulationStats();
      expect(stats.living).to.equal(3);
    });

    it("Should produce offspring with higher generation", async function () {
      const organism2Address = await organism2.getAddress();
      await organism1.mate(organism2Address);

      const stats = await registry.getPopulationStats();
      expect(stats.averageGeneration).to.be.gt(0);
    });
  });

  describe("Fitness Evaluation", function () {
    let organism;

    beforeEach(async function () {
      const energy = ethers.parseEther("200");
      const tx = await factory.createGenesisOrganism({ value: energy });
      await tx.wait();

      const genesisOrganisms = await factory.getGenesisOrganisms();
      organism = await ethers.getContractAt("Organism", genesisOrganisms[0]);
    });

    it("Should evaluate fitness", async function () {
      const fitness = await organism.evaluateFitness();
      expect(fitness).to.be.gte(0);
      expect(fitness).to.be.lte(100);
    });

    it("Should update fitness in registry", async function () {
      await organism.evaluateFitness();

      const organismAddress = await organism.getAddress();
      const info = await registry.organisms(organismAddress);
      expect(info.fitnessScore).to.be.gt(0);
    });

    it("Should emit FitnessEvaluated event", async function () {
      const tx = await organism.evaluateFitness();
      const receipt = await tx.wait();

      const event = receipt.logs.find(
        log => log.fragment && log.fragment.name === "FitnessEvaluated"
      );
      expect(event).to.not.be.undefined;
    });
  });

  describe("Natural Selection", function () {
    beforeEach(async function () {
      // Create population
      const energy = ethers.parseEther("1000");
      await factory.createGenesisPopulation(10, { value: energy });
    });

    it("Should track population statistics", async function () {
      const stats = await registry.getPopulationStats();
      expect(stats.total).to.equal(10);
      expect(stats.living).to.equal(10);
    });

    it("Should handle extinction events", async function () {
      const statsBefore = await registry.getPopulationStats();
      const livingBefore = statsBefore.living;

      // Trigger extinction with 50% survival rate
      await factory.triggerExtinction("Testing", 50);

      const statsAfter = await registry.getPopulationStats();
      expect(statsAfter.living).to.be.lt(livingBefore);
    });

    it("Should distribute resources", async function () {
      const tx = await registry.distributeResources();
      const receipt = await tx.wait();

      const event = receipt.logs.find(
        log => log.fragment && log.fragment.name === "ResourceDistribution"
      );
      expect(event).to.not.be.undefined;
    });
  });

  describe("Evolution Triggers", function () {
    beforeEach(async function () {
      const energy = ethers.parseEther("1000");
      await factory.createGenesisPopulation(5, { value: energy });
    });

    it("Should check evolution triggers", async function () {
      const [shouldTrigger, triggerType] = await evolutionEngine.checkEvolutionTrigger();
      expect(typeof shouldTrigger).to.equal("boolean");
      expect(typeof triggerType).to.equal("string");
    });

    it("Should trigger time-based evolution", async function () {
      // Mine enough blocks to trigger
      for (let i = 0; i < 1001; i++) {
        await ethers.provider.send("evm_mine");
      }

      const [shouldTrigger] = await evolutionEngine.checkEvolutionTrigger();
      if (shouldTrigger) {
        const tx = await factory.runEvolutionCycle();
        const receipt = await tx.wait();
        expect(receipt).to.not.be.undefined;
      }
    });

    it("Should update environmental pressures", async function () {
      await factory.updateEnvironment("TEMPERATURE", 75);

      const env = await evolutionEngine.getEnvironment();
      expect(env.temp).to.equal(75);
    });
  });

  describe("Competition", function () {
    let organism1;
    let organism2;

    beforeEach(async function () {
      const energy = ethers.parseEther("500");
      await factory.createGenesisPopulation(2, { value: energy });

      const genesisOrganisms = await factory.getGenesisOrganisms();
      organism1 = await ethers.getContractAt("Organism", genesisOrganisms[0]);
      organism2 = await ethers.getContractAt("Organism", genesisOrganisms[1]);
    });

    it("Should compete and determine winner", async function () {
      const organism2Address = await organism2.getAddress();
      const won = await organism1.compete(organism2Address);
      expect(typeof won).to.equal("boolean");
    });

    it("Should run competition tournament", async function () {
      const genesisOrganisms = await factory.getGenesisOrganisms();
      const winner = await factory.runCompetitionTournament(genesisOrganisms);
      expect(winner).to.be.properAddress;
    });
  });

  describe("User Interactions", function () {
    let organism;

    beforeEach(async function () {
      const energy = ethers.parseEther("200");
      const tx = await factory.createGenesisOrganism({ value: energy });
      await tx.wait();

      const genesisOrganisms = await factory.getGenesisOrganisms();
      organism = await ethers.getContractAt("Organism", genesisOrganisms[0]);
    });

    it("Should allow feeding organism", async function () {
      const feedEnergy = ethers.parseEther("50");
      const statsBefore = await organism.stats();

      await organism.feed({ value: feedEnergy });

      const statsAfter = await organism.stats();
      expect(statsAfter.energy).to.be.gt(statsBefore.energy);
      expect(statsAfter.userInteractions).to.be.gt(statsBefore.userInteractions);
    });

    it("Should track user interactions in fitness", async function () {
      const feedEnergy = ethers.parseEther("50");
      await organism.feed({ value: feedEnergy });

      const fitness = await organism.evaluateFitness();
      expect(fitness).to.be.gte(0);
    });
  });

  describe("Lifecycle and State Transitions", function () {
    let organism;

    beforeEach(async function () {
      const energy = ethers.parseEther("200");
      const tx = await factory.createGenesisOrganism({ value: energy });
      await tx.wait();

      const genesisOrganisms = await factory.getGenesisOrganisms();
      organism = await ethers.getContractAt("Organism", genesisOrganisms[0]);
    });

    it("Should start as EMBRYO", async function () {
      const state = await organism.state();
      expect(state).to.equal(0); // EMBRYO
    });

    it("Should transition through life stages", async function () {
      // EMBRYO -> JUVENILE
      for (let i = 0; i < 100; i++) {
        await ethers.provider.send("evm_mine");
      }
      await organism.updateState();
      expect(await organism.state()).to.equal(1); // JUVENILE

      // JUVENILE -> ADULT
      for (let i = 0; i < 900; i++) {
        await ethers.provider.send("evm_mine");
      }
      await organism.updateState();
      expect(await organism.state()).to.equal(2); // ADULT
    });

    it("Should get organism summary", async function () {
      const summary = await organism.getSummary();
      expect(summary.currentState).to.be.gte(0);
      expect(summary.age).to.be.gte(0);
      expect(summary.energy).to.be.gt(0);
    });
  });

  describe("Factory Functions", function () {
    it("Should get ecosystem stats", async function () {
      const energy = ethers.parseEther("500");
      await factory.createGenesisPopulation(5, { value: energy });

      const stats = await factory.getEcosystemStats();
      expect(stats.totalOrganisms).to.equal(5);
      expect(stats.livingOrganisms).to.equal(5);
      expect(stats.genesisCount).to.equal(5);
    });

    it("Should get top performers", async function () {
      const energy = ethers.parseEther("500");
      await factory.createGenesisPopulation(5, { value: energy });

      const [topOrganisms, fitnessScores] = await factory.getTopPerformers(3);
      expect(topOrganisms.length).to.equal(3);
      expect(fitnessScores.length).to.equal(3);
    });

    it("Should batch evaluate fitness", async function () {
      const energy = ethers.parseEther("500");
      await factory.createGenesisPopulation(3, { value: energy });

      const organisms = await factory.getGenesisOrganisms();
      const scores = await factory.batchEvaluateFitness(organisms);
      expect(scores.length).to.equal(3);
    });
  });

  describe("Gas Efficiency", function () {
    it("Should track gas usage in organisms", async function () {
      const energy = ethers.parseEther("200");
      await factory.createGenesisOrganism({ value: energy });

      const genesisOrganisms = await factory.getGenesisOrganisms();
      const organism = await ethers.getContractAt("Organism", genesisOrganisms[0]);

      const stats = await organism.stats();
      expect(stats.gasEfficiency).to.be.gt(0);
    });
  });
});
