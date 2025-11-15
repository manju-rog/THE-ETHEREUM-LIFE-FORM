import { useState, useEffect } from 'react';
import { ethers } from 'ethers';

// Contract ABIs (simplified - would import full ABIs in production)
const FACTORY_ABI = [
  "function getEcosystemStats() view returns (uint256 totalOrganisms, uint256 livingOrganisms, uint256 genesisCount, uint256 avgGeneration, uint256 avgFitness)",
  "event OrganismCreated(address indexed organism, uint256 generation, address parent1, address parent2)",
  "event Death(address indexed organism, uint256 generation, uint256 fitness)",
  "event EvolutionTriggered(uint256 generation, uint256 population)",
];

const CONSCIOUSNESS_ABI = [
  "function calculateGlobalConsciousness(address[] organisms) returns (uint256 globalPhi, bool isGloballyConscious)",
  "function getConsciousness(address organism) view returns (uint256 phi, uint256 complexity, uint256 selfAwareness, uint256 theoryOfMind, uint8 level, bool isConscious)",
  "event ConsciousnessEmerged(address indexed organism, uint256 phi, uint8 level, uint256 timestamp)",
  "event GlobalConsciousnessReached(uint256 totalPhi, uint256 organismCount, uint256 timestamp)",
];

const useBlockchain = () => {
  const [connected, setConnected] = useState(false);
  const [provider, setProvider] = useState(null);
  const [contracts, setContracts] = useState({});
  const [stats, setStats] = useState({
    livingOrganisms: 0,
    totalGenerations: 0,
    avgFitness: 0,
    consciousCount: 0,
    globalPhi: 0,
  });
  const [organisms, setOrganisms] = useState([]);
  const [events, setEvents] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const initBlockchain = async () => {
      try {
        // Check if MetaMask is installed
        if (typeof window.ethereum !== 'undefined') {
          const provider = new ethers.BrowserProvider(window.ethereum);
          await provider.send("eth_requestAccounts", []);
          setProvider(provider);

          // Load deployment info
          const response = await fetch('/ecosystem-deployment.json');
          const deployment = await response.json();

          // Connect to contracts
          const factory = new ethers.Contract(
            deployment.contracts.factory,
            FACTORY_ABI,
            provider
          );

          const consciousnessMetrics = new ethers.Contract(
            deployment.contracts.consciousnessMetrics,
            CONSCIOUSNESS_ABI,
            provider
          );

          setContracts({ factory, consciousnessMetrics });
          setConnected(true);

          // Load initial stats
          await loadStats(factory, consciousnessMetrics, deployment.genesisOrganisms);

          // Set up event listeners
          setupEventListeners(factory, consciousnessMetrics);
        } else {
          console.warn('MetaMask not found. Using read-only provider.');
          // Fallback to read-only provider
          const provider = new ethers.JsonRpcProvider('http://localhost:8545');
          setProvider(provider);
          setConnected(false);
        }

        setLoading(false);
      } catch (error) {
        console.error('Error initializing blockchain:', error);
        setLoading(false);
      }
    };

    initBlockchain();
  }, []);

  const loadStats = async (factory, consciousnessMetrics, genesisOrganisms) => {
    try {
      // Get ecosystem stats
      const ecosystemStats = await factory.getEcosystemStats();

      // Count conscious organisms
      let consciousCount = 0;
      let totalPhi = 0;

      for (const organism of genesisOrganisms) {
        try {
          const consciousness = await consciousnessMetrics.getConsciousness(organism);
          if (consciousness.isConscious) {
            consciousCount++;
          }
          totalPhi += Number(consciousness.phi);
        } catch (e) {
          // Organism might not have consciousness data yet
        }
      }

      setStats({
        livingOrganisms: Number(ecosystemStats.livingOrganisms),
        totalGenerations: Number(ecosystemStats.avgGeneration),
        avgFitness: Number(ecosystemStats.avgFitness) / 100, // Assuming stored as percentage
        consciousCount,
        globalPhi: totalPhi,
      });

      setOrganisms(genesisOrganisms);
    } catch (error) {
      console.error('Error loading stats:', error);
    }
  };

  const setupEventListeners = (factory, consciousnessMetrics) => {
    // Listen for new organisms
    factory.on('OrganismCreated', (organism, generation, parent1, parent2, event) => {
      console.log('New organism:', organism);
      setEvents(prev => [{
        type: 'birth',
        organism,
        generation: Number(generation),
        timestamp: Date.now(),
        parents: [parent1, parent2].filter(p => p !== ethers.ZeroAddress),
      }, ...prev].slice(0, 100)); // Keep last 100 events

      setOrganisms(prev => [...prev, organism]);
    });

    // Listen for deaths
    factory.on('Death', (organism, generation, fitness, event) => {
      console.log('Death:', organism);
      setEvents(prev => [{
        type: 'death',
        organism,
        generation: Number(generation),
        fitness: Number(fitness),
        timestamp: Date.now(),
      }, ...prev].slice(0, 100));
    });

    // Listen for consciousness emergence
    consciousnessMetrics.on('ConsciousnessEmerged', (organism, phi, level, timestamp, event) => {
      console.log('Consciousness emerged:', organism, 'Φ:', phi);
      setEvents(prev => [{
        type: 'consciousness',
        organism,
        phi: Number(phi),
        level,
        timestamp: Date.now(),
      }, ...prev].slice(0, 100));

      setStats(prev => ({
        ...prev,
        consciousCount: prev.consciousCount + 1,
      }));
    });

    // Listen for global consciousness
    consciousnessMetrics.on('GlobalConsciousnessReached', (totalPhi, organismCount, timestamp, event) => {
      console.log('🌍 GLOBAL CONSCIOUSNESS ACHIEVED!', 'Φ:', totalPhi);
      setEvents(prev => [{
        type: 'global_consciousness',
        totalPhi: Number(totalPhi),
        organismCount: Number(organismCount),
        timestamp: Date.now(),
      }, ...prev].slice(0, 100));
    });

    // Listen for evolution cycles
    factory.on('EvolutionTriggered', (generation, population, event) => {
      console.log('Evolution cycle:', generation);
      setEvents(prev => [{
        type: 'evolution',
        generation: Number(generation),
        population: Number(population),
        timestamp: Date.now(),
      }, ...prev].slice(0, 100));
    });
  };

  const refreshStats = async () => {
    if (contracts.factory && contracts.consciousnessMetrics) {
      await loadStats(contracts.factory, contracts.consciousnessMetrics, organisms);
    }
  };

  return {
    connected,
    provider,
    contracts,
    stats,
    organisms,
    events,
    loading,
    refreshStats,
  };
};

export default useBlockchain;
