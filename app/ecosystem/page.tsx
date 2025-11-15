'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useAccount, useReadContract } from 'wagmi';
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { parseAbi, formatEther } from 'viem';

const FACTORY_ADDRESS = process.env.NEXT_PUBLIC_ORGANISM_FACTORY_ADDRESS as `0x${string}`;

const factoryAbi = parseAbi([
  'function getAllOrganisms() external view returns (address[])',
  'function getOrganismDetails(address organism) external view returns (bytes32 dnaHash, uint8 generation, uint256 fitness, uint256 energy, bool alive)',
  'function getAliveCount() external view returns (uint256)',
  'function totalOrganisms() external view returns (uint256)',
]);

export default function Ecosystem() {
  const { address, isConnected } = useAccount();
  const [filter, setFilter] = useState<'all' | 'alive' | 'dead'>('alive');

  const { data: allOrganisms, isLoading: loadingOrganisms } = useReadContract({
    address: FACTORY_ADDRESS,
    abi: factoryAbi,
    functionName: 'getAllOrganisms',
  });

  const { data: aliveCount } = useReadContract({
    address: FACTORY_ADDRESS,
    abi: factoryAbi,
    functionName: 'getAliveCount',
  });

  const { data: totalCount } = useReadContract({
    address: FACTORY_ADDRESS,
    abi: factoryAbi,
    functionName: 'totalOrganisms',
  });

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
        {/* Title */}
        <div className="text-center mb-12">
          <h1 className="text-5xl font-bold mb-4 bg-gradient-to-r from-dna-primary via-dna-secondary to-dna-primary bg-clip-text text-transparent">
            Digital Ecosystem
          </h1>
          <p className="text-xl text-gray-300">
            Explore all living and extinct organisms
          </p>
        </div>

        {/* Stats */}
        <div className="grid md:grid-cols-4 gap-6 mb-12 max-w-5xl mx-auto">
          <div className="bg-gray-800/50 border border-dna-primary/30 rounded-lg p-6 text-center">
            <div className="text-4xl mb-2">🌱</div>
            <div className="text-3xl font-bold text-dna-primary mb-1">
              {aliveCount?.toString() || '0'}
            </div>
            <div className="text-gray-400">Living</div>
          </div>
          <div className="bg-gray-800/50 border border-gray-700 rounded-lg p-6 text-center">
            <div className="text-4xl mb-2">📊</div>
            <div className="text-3xl font-bold text-white mb-1">
              {totalCount?.toString() || '0'}
            </div>
            <div className="text-gray-400">Total Created</div>
          </div>
          <div className="bg-gray-800/50 border border-organism-dead/30 rounded-lg p-6 text-center">
            <div className="text-4xl mb-2">💀</div>
            <div className="text-3xl font-bold text-organism-dead mb-1">
              {totalCount && aliveCount
                ? (Number(totalCount) - Number(aliveCount)).toString()
                : '0'}
            </div>
            <div className="text-gray-400">Extinct</div>
          </div>
          <div className="bg-gray-800/50 border border-energy-high/30 rounded-lg p-6 text-center">
            <div className="text-4xl mb-2">🏆</div>
            <div className="text-3xl font-bold text-energy-high mb-1">
              {allOrganisms?.length || '0'}
            </div>
            <div className="text-gray-400">Species</div>
          </div>
        </div>

        {/* Filter Tabs */}
        <div className="flex justify-center gap-4 mb-8">
          <button
            onClick={() => setFilter('all')}
            className={`px-6 py-3 rounded-lg font-semibold transition-all ${
              filter === 'all'
                ? 'bg-dna-primary text-black'
                : 'bg-gray-800 text-gray-300 hover:bg-gray-700'
            }`}
          >
            All Organisms
          </button>
          <button
            onClick={() => setFilter('alive')}
            className={`px-6 py-3 rounded-lg font-semibold transition-all ${
              filter === 'alive'
                ? 'bg-organism-alive text-black'
                : 'bg-gray-800 text-gray-300 hover:bg-gray-700'
            }`}
          >
            Living
          </button>
          <button
            onClick={() => setFilter('dead')}
            className={`px-6 py-3 rounded-lg font-semibold transition-all ${
              filter === 'dead'
                ? 'bg-organism-dead text-white'
                : 'bg-gray-800 text-gray-300 hover:bg-gray-700'
            }`}
          >
            Extinct
          </button>
        </div>

        {/* Organisms Grid */}
        <div className="max-w-6xl mx-auto">
          {loadingOrganisms ? (
            <div className="text-center py-12">
              <div className="text-6xl mb-4 animate-spin">⏳</div>
              <p className="text-gray-400">Loading ecosystem...</p>
            </div>
          ) : !allOrganisms || allOrganisms.length === 0 ? (
            <div className="text-center py-12 bg-gray-800/30 border border-gray-700 rounded-lg">
              <div className="text-6xl mb-4">🌱</div>
              <h3 className="text-2xl font-bold mb-2 text-gray-300">
                No Organisms Yet
              </h3>
              <p className="text-gray-400 mb-6">
                Be the first to create digital life!
              </p>
              <Link
                href="/create"
                className="inline-block px-6 py-3 bg-dna-primary text-black font-bold rounded-lg hover:opacity-90 transition-all"
              >
                Create First Organism
              </Link>
            </div>
          ) : (
            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
              {allOrganisms.map((organismAddress) => (
                <OrganismCard
                  key={organismAddress}
                  address={organismAddress}
                  filter={filter}
                />
              ))}
            </div>
          )}
        </div>
      </main>
    </div>
  );
}

function OrganismCard({
  address,
  filter,
}: {
  address: `0x${string}`;
  filter: 'all' | 'alive' | 'dead';
}) {
  const { data: details } = useReadContract({
    address: FACTORY_ADDRESS,
    abi: factoryAbi,
    functionName: 'getOrganismDetails',
    args: [address],
  });

  if (!details) return null;

  const [dnaHash, generation, fitness, energy, alive] = details;

  // Apply filter
  if (filter === 'alive' && !alive) return null;
  if (filter === 'dead' && alive) return null;

  const shortAddress = `${address.slice(0, 6)}...${address.slice(-4)}`;
  const shortDNA = `${dnaHash.slice(0, 10)}...${dnaHash.slice(-8)}`;

  return (
    <div
      className={`bg-gray-800/50 border rounded-lg p-6 transition-all hover:scale-105 ${
        alive
          ? 'border-organism-alive organism-alive'
          : 'border-organism-dead opacity-70'
      }`}
    >
      {/* Status Badge */}
      <div className="flex items-center justify-between mb-4">
        <div
          className={`px-3 py-1 rounded-full text-sm font-semibold ${
            alive
              ? 'bg-organism-alive text-black'
              : 'bg-organism-dead text-white'
          }`}
        >
          {alive ? '🌱 ALIVE' : '💀 EXTINCT'}
        </div>
        <div className="text-sm text-gray-400">Gen {generation.toString()}</div>
      </div>

      {/* DNA Display */}
      <div className="mb-4">
        <div className="text-xs text-gray-500 mb-1">DNA Hash</div>
        <div className="font-mono text-sm text-dna-primary truncate">
          {shortDNA}
        </div>
      </div>

      {/* Stats */}
      <div className="space-y-2 mb-4">
        <div className="flex justify-between items-center">
          <span className="text-sm text-gray-400">Fitness:</span>
          <span className="text-sm font-bold text-dna-secondary">
            {fitness.toString()}
          </span>
        </div>
        <div className="flex justify-between items-center">
          <span className="text-sm text-gray-400">Energy:</span>
          <span
            className={`text-sm font-bold ${
              Number(formatEther(energy)) > 1
                ? 'text-energy-high'
                : 'text-energy-low'
            }`}
          >
            {Number(formatEther(energy)).toFixed(4)} ETH
          </span>
        </div>
      </div>

      {/* Address */}
      <div className="text-xs text-gray-500 mb-4">
        <a
          href={`https://etherscan.io/address/${address}`}
          target="_blank"
          rel="noopener noreferrer"
          className="hover:text-dna-primary transition-colors"
        >
          {shortAddress} ↗
        </a>
      </div>

      {/* Actions */}
      <div className="flex gap-2">
        <button
          className="flex-1 px-3 py-2 bg-dna-primary/10 border border-dna-primary text-dna-primary text-sm font-semibold rounded hover:bg-dna-primary/20 transition-all disabled:opacity-50"
          disabled={!alive}
        >
          View Details
        </button>
      </div>
    </div>
  );
}
