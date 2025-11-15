import { expect } from "chai";
import { ethers } from "hardhat";
import { DigitalOrganism, OrganismFactory, Ecosystem } from "../typechain-types";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";

describe("Digital Organism Life Cycle", function () {
  let factory: OrganismFactory;
  let ecosystem: Ecosystem;
  let owner: HardhatEthersSigner;
  let user1: HardhatEthersSigner;
  let user2: HardhatEthersSigner;

  beforeEach(async function () {
    [owner, user1, user2] = await ethers.getSigners();

    // Deploy Factory
    const OrganismFactory = await ethers.getContractFactory("OrganismFactory");
    factory = await OrganismFactory.deploy(owner.address);
    await factory.waitForDeployment();

    // Deploy Ecosystem
    const Ecosystem = await ethers.getContractFactory("Ecosystem");
    ecosystem = await Ecosystem.deploy(
      await factory.getAddress(),
      owner.address
    );
    await ecosystem.waitForDeployment();

    // Link ecosystem to factory
    await factory.setEcosystem(await ecosystem.getAddress());
  });

  describe("Genesis Creation", function () {
    it("Should create a genesis organism", async function () {
      const tx = await factory.createGenesisOrganism(user1.address);
      const receipt = await tx.wait();

      expect(receipt).to.not.be.null;

      const organisms = await factory.getOrganismsByOwner(user1.address);
      expect(organisms.length).to.equal(1);

      const organismAddress = organisms[0];
      const organism = await ethers.getContractAt(
        "DigitalOrganism",
        organismAddress
      );

      expect(await organism.isAlive()).to.be.true;
      expect(await organism.getGeneration()).to.equal(0);
      expect(await organism.owner()).to.equal(user1.address);
    });

    it("Should generate unique DNA for each organism", async function () {
      await factory.createGenesisOrganism(user1.address);
      await factory.createGenesisOrganism(user2.address);

      const organisms1 = await factory.getOrganismsByOwner(user1.address);
      const organisms2 = await factory.getOrganismsByOwner(user2.address);

      const org1 = await ethers.getContractAt(
        "DigitalOrganism",
        organisms1[0]
      );
      const org2 = await ethers.getContractAt(
        "DigitalOrganism",
        organisms2[0]
      );

      const dna1 = await org1.getDNAHash();
      const dna2 = await org2.getDNAHash();

      expect(dna1).to.not.equal(dna2);
    });
  });

  describe("Feeding and Energy", function () {
    it("Should accept ETH and increase energy", async function () {
      await factory.createGenesisOrganism(user1.address);
      const organisms = await factory.getOrganismsByOwner(user1.address);
      const organism = await ethers.getContractAt(
        "DigitalOrganism",
        organisms[0]
      );

      const energyBefore = await organism.getEnergy();

      await organism.connect(user1).feed({ value: ethers.parseEther("1") });

      const energyAfter = await organism.getEnergy();
      expect(energyAfter).to.be.gt(energyBefore);
      expect(energyAfter).to.equal(ethers.parseEther("1"));
    });

    it("Should update fitness when fed", async function () {
      await factory.createGenesisOrganism(user1.address);
      const organisms = await factory.getOrganismsByOwner(user1.address);
      const organism = await ethers.getContractAt(
        "DigitalOrganism",
        organisms[0]
      );

      const fitnessBefore = await organism.getFitness();

      await organism.connect(user1).feed({ value: ethers.parseEther("2") });

      const fitnessAfter = await organism.getFitness();
      expect(fitnessAfter).to.be.gt(fitnessBefore);
    });
  });

  describe("Reproduction and Evolution", function () {
    it("Should reproduce when energy is sufficient", async function () {
      await factory.createGenesisOrganism(user1.address);
      const organisms = await factory.getOrganismsByOwner(user1.address);
      const parentOrg = await ethers.getContractAt(
        "DigitalOrganism",
        organisms[0]
      );

      // Feed organism enough energy to reproduce
      await parentOrg.connect(user1).feed({ value: ethers.parseEther("2") });

      // Reproduce
      await parentOrg.connect(user1).reproduce();

      const allOrganisms = await factory.getOrganismsByOwner(user1.address);
      expect(allOrganisms.length).to.equal(2);

      const childOrg = await ethers.getContractAt(
        "DigitalOrganism",
        allOrganisms[1]
      );

      expect(await childOrg.getGeneration()).to.equal(1);
      expect(await childOrg.isAlive()).to.be.true;
    });

    it("Should fail reproduction with insufficient energy", async function () {
      await factory.createGenesisOrganism(user1.address);
      const organisms = await factory.getOrganismsByOwner(user1.address);
      const organism = await ethers.getContractAt(
        "DigitalOrganism",
        organisms[0]
      );

      await expect(organism.connect(user1).reproduce()).to.be.revertedWith(
        "DigitalOrganism: Insufficient energy to reproduce"
      );
    });

    it("Should mutate genes when mutate() is called", async function () {
      await factory.createGenesisOrganism(user1.address);
      const organisms = await factory.getOrganismsByOwner(user1.address);
      const organism = await ethers.getContractAt(
        "DigitalOrganism",
        organisms[0]
      );

      // Feed organism
      await organism.connect(user1).feed({ value: ethers.parseEther("1") });

      const dnaBeforeMutation = await organism.getDNAHash();
      const genesBeforeMutation = await organism.getGenes();

      // Mutate
      await organism.connect(user1).mutate();

      const dnaAfterMutation = await organism.getDNAHash();
      const genesAfterMutation = await organism.getGenes();

      expect(dnaAfterMutation).to.not.equal(dnaBeforeMutation);

      // At least one gene should be different (probabilistically)
      let differentGeneFound = false;
      for (let i = 0; i < genesBeforeMutation.length; i++) {
        if (genesBeforeMutation[i] !== genesAfterMutation[i]) {
          differentGeneFound = true;
          break;
        }
      }
      expect(differentGeneFound).to.be.true;
    });
  });

  describe("Competition and Tournaments", function () {
    it("Should create a tournament", async function () {
      const tx = await ecosystem.createTournament({
        value: ethers.parseEther("1"),
      });
      await tx.wait();

      expect(await ecosystem.tournamentCount()).to.equal(1);
    });

    it("Should register organisms for tournament", async function () {
      // Create tournament
      await ecosystem.createTournament({ value: ethers.parseEther("1") });

      // Create two organisms
      await factory.createGenesisOrganism(user1.address);
      await factory.createGenesisOrganism(user2.address);

      const org1 = (await factory.getOrganismsByOwner(user1.address))[0];
      const org2 = (await factory.getOrganismsByOwner(user2.address))[0];

      // Feed them
      const organism1 = await ethers.getContractAt("DigitalOrganism", org1);
      const organism2 = await ethers.getContractAt("DigitalOrganism", org2);

      await organism1.connect(user1).feed({ value: ethers.parseEther("1") });
      await organism2.connect(user2).feed({ value: ethers.parseEther("1") });

      // Register for tournament
      await ecosystem.connect(user1).registerForTournament(0, org1, {
        value: ethers.parseEther("0.01"),
      });
      await ecosystem.connect(user2).registerForTournament(0, org2, {
        value: ethers.parseEther("0.01"),
      });

      const participants = await ecosystem.getTournamentParticipants(0);
      expect(participants.length).to.equal(2);
    });

    it("Should compete organisms and determine winner", async function () {
      // Create tournament
      await ecosystem.createTournament({ value: ethers.parseEther("1") });

      // Create two organisms
      await factory.createGenesisOrganism(user1.address);
      await factory.createGenesisOrganism(user2.address);

      const org1 = (await factory.getOrganismsByOwner(user1.address))[0];
      const org2 = (await factory.getOrganismsByOwner(user2.address))[0];

      const organism1 = await ethers.getContractAt("DigitalOrganism", org1);
      const organism2 = await ethers.getContractAt("DigitalOrganism", org2);

      // Feed organism1 more to make it fitter
      await organism1.connect(user1).feed({ value: ethers.parseEther("5") });
      await organism2.connect(user2).feed({ value: ethers.parseEther("1") });

      // Register for tournament
      await ecosystem.connect(user1).registerForTournament(0, org1, {
        value: ethers.parseEther("0.01"),
      });
      await ecosystem.connect(user2).registerForTournament(0, org2, {
        value: ethers.parseEther("0.01"),
      });

      // Compete
      await ecosystem.compete(0, org1, org2);

      const [wins1] = await ecosystem.getRecord(org1);
      const [wins2] = await ecosystem.getRecord(org2);

      // organism1 should have won
      expect(wins1).to.be.gt(wins2);
    });
  });
});
