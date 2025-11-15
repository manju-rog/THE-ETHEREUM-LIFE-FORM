'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useAccount, useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { parseAbi } from 'viem';

const FACTORY_ADDRESS = process.env.NEXT_PUBLIC_ORGANISM_FACTORY_ADDRESS as `0x${string}`;

const factoryAbi = parseAbi([
  'function createGenesisOrganism(address owner) external returns (address)',
  'event OrganismCreated(address indexed organism, address indexed owner, uint8 generation, bytes32 dnaHash)',
]);

export default function CreateOrganism() {
  const { address, isConnected } = useAccount();
  const [isCreating, setIsCreating] = useState(false);
  const [createdOrganism, setCreatedOrganism] = useState<string | null>(null);

  const { data: hash, writeContract, error } = useWriteContract();

  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  });

  const handleCreateOrganism = async () => {
    if (!address || !FACTORY_ADDRESS) return;

    setIsCreating(true);
    setCreatedOrganism(null);

    try {
      writeContract({
        address: FACTORY_ADDRESS,
        abi: factoryAbi,
        functionName: 'createGenesisOrganism',
        args: [address],
      });
    } catch (err) {
      console.error('Error creating organism:', err);
      setIsCreating(false);
    }
  };

  // Reset creating state when transaction is complete
  if (isConfirming && isCreating) {
    setIsCreating(true);
  }

  if (isSuccess && isCreating) {
    setIsCreating(false);
  }

  return (
    <div className="min-h-screen bg-gradient-to-b from-black via-gray-900 to-black">
      {/* Header */}
      <header className="fixed top-0 w-full z-50 bg-black/50 backdrop-blur-md border-b border-dna-primary/20">
        <div className="container mx-auto px-4 py-4 flex justify-between items-center">
          <Link href="/" className="text-2xl font-bold text-dna-primary">
            🧬 THE ETHEREUM LIFE FORM
          </Link>
          <ConnectButton />
        </div>
      </header>

      <main className="container mx-auto px-4 pt-32 pb-16">
        <div className="max-w-3xl mx-auto">
          {/* Title */}
          <div className="text-center mb-12">
            <h1 className="text-5xl font-bold mb-4 bg-gradient-to-r from-dna-primary via-dna-secondary to-dna-primary bg-clip-text text-transparent">
              Create Digital Life
            </h1>
            <p className="text-xl text-gray-300">
              Deploy a new genesis organism with unique genetic code
            </p>
          </div>

          {/* Creation Card */}
          <div className="bg-gray-800/50 border border-dna-primary/30 rounded-2xl p-8 mb-8">
            {!isConnected ? (
              <div className="text-center py-12">
                <div className="text-6xl mb-6">🔌</div>
                <h2 className="text-2xl font-bold mb-4 text-gray-300">
                  Connect Your Wallet
                </h2>
                <p className="text-gray-400 mb-6">
                  Connect your wallet to create your first digital organism
                </p>
                <ConnectButton />
              </div>
            ) : (
              <div>
                <h2 className="text-2xl font-bold mb-6 text-dna-primary">
                  Genesis Organism Configuration
                </h2>

                <div className="space-y-6 mb-8">
                  <div className="bg-gray-900/50 rounded-lg p-6 border border-gray-700">
                    <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
                      <span>🧬</span> Genetic Properties
                    </h3>
                    <div className="space-y-3 text-gray-300">
                      <div className="flex justify-between">
                        <span>Generation:</span>
                        <span className="text-dna-primary font-bold">0 (Genesis)</span>
                      </div>
                      <div className="flex justify-between">
                        <span>DNA Genes:</span>
                        <span className="text-dna-primary font-bold">8 Random Genes</span>
                      </div>
                      <div className="flex justify-between">
                        <span>Initial Energy:</span>
                        <span className="text-energy-low font-bold">0 ETH</span>
                      </div>
                      <div className="flex justify-between">
                        <span>Mutation Rate:</span>
                        <span className="text-dna-secondary font-bold">1%</span>
                      </div>
                    </div>
                  </div>

                  <div className="bg-gray-900/50 rounded-lg p-6 border border-gray-700">
                    <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
                      <span>⚙️</span> Capabilities
                    </h3>
                    <ul className="space-y-2 text-gray-300">
                      <li className="flex items-start gap-2">
                        <span className="text-green-400">✓</span>
                        <span>Can accept energy (ETH) to increase fitness</span>
                      </li>
                      <li className="flex items-start gap-2">
                        <span className="text-green-400">✓</span>
                        <span>Can reproduce to create offspring with mutations</span>
                      </li>
                      <li className="flex items-start gap-2">
                        <span className="text-green-400">✓</span>
                        <span>Can compete in tournaments for prizes</span>
                      </li>
                      <li className="flex items-start gap-2">
                        <span className="text-green-400">✓</span>
                        <span>Can evolve through self-modifying code</span>
                      </li>
                      <li className="flex items-start gap-2">
                        <span className="text-green-400">✓</span>
                        <span>Dies if energy depletes below survival threshold</span>
                      </li>
                    </ul>
                  </div>

                  <div className="bg-gray-900/50 rounded-lg p-6 border border-yellow-600/30">
                    <h3 className="text-lg font-semibold mb-4 flex items-center gap-2 text-yellow-400">
                      <span>⚠️</span> Important Notes
                    </h3>
                    <ul className="space-y-2 text-gray-300 text-sm">
                      <li>• Your organism will have a unique DNA hash generated on-chain</li>
                      <li>• Feed it regularly to keep it alive and competitive</li>
                      <li>• Higher energy = higher fitness = better competition results</li>
                      <li>• Reproduction costs 0.5 ETH minimum</li>
                      <li>• Organism automatically dies if energy {'<'} 0.1 ETH</li>
                    </ul>
                  </div>
                </div>

                {/* Create Button */}
                <button
                  onClick={handleCreateOrganism}
                  disabled={isCreating || isConfirming || !FACTORY_ADDRESS}
                  className="w-full py-4 px-6 bg-gradient-to-r from-dna-primary to-dna-secondary text-black font-bold text-lg rounded-lg hover:opacity-90 transition-all transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none"
                >
                  {isCreating || isConfirming ? (
                    <span className="flex items-center justify-center gap-2">
                      <span className="animate-spin">⏳</span>
                      {isConfirming ? 'Creating Organism...' : 'Confirm in Wallet...'}
                    </span>
                  ) : (
                    '🌱 Create Genesis Organism'
                  )}
                </button>

                {error && (
                  <div className="mt-4 p-4 bg-red-900/30 border border-red-600 rounded-lg">
                    <p className="text-red-400 text-sm">
                      Error: {error.message}
                    </p>
                  </div>
                )}

                {isSuccess && (
                  <div className="mt-4 p-4 bg-green-900/30 border border-green-600 rounded-lg">
                    <p className="text-green-400 font-semibold mb-2">
                      🎉 Organism Created Successfully!
                    </p>
                    <p className="text-gray-300 text-sm mb-3">
                      Your digital organism has been born on the blockchain.
                    </p>
                    <div className="flex gap-3">
                      <Link
                        href="/ecosystem"
                        className="px-4 py-2 bg-dna-primary text-black font-semibold rounded-lg hover:opacity-90 transition-all"
                      >
                        View Ecosystem
                      </Link>
                      <Link
                        href="/genealogy"
                        className="px-4 py-2 bg-gray-700 text-white font-semibold rounded-lg hover:bg-gray-600 transition-all"
                      >
                        View Genealogy
                      </Link>
                    </div>
                  </div>
                )}
              </div>
            )}
          </div>

          {/* Info Section */}
          <div className="grid md:grid-cols-3 gap-4">
            <div className="bg-gray-800/30 border border-gray-700 rounded-lg p-4 text-center">
              <div className="text-3xl mb-2">🧬</div>
              <div className="text-sm text-gray-400">Unique DNA</div>
              <div className="text-lg font-bold text-dna-primary">256-bit Hash</div>
            </div>
            <div className="bg-gray-800/30 border border-gray-700 rounded-lg p-4 text-center">
              <div className="text-3xl mb-2">⚡</div>
              <div className="text-sm text-gray-400">Evolution</div>
              <div className="text-lg font-bold text-dna-secondary">Self-Modifying</div>
            </div>
            <div className="bg-gray-800/30 border border-gray-700 rounded-lg p-4 text-center">
              <div className="text-3xl mb-2">🏆</div>
              <div className="text-sm text-gray-400">Competition</div>
              <div className="text-lg font-bold text-energy-high">Natural Selection</div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
