'use client';

import Link from 'next/link';
import { ConnectButton } from '@rainbow-me/rainbowkit';

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-black via-gray-900 to-black">
      {/* Header */}
      <header className="fixed top-0 w-full z-50 bg-black/50 backdrop-blur-md border-b border-dna-primary/20">
        <div className="container mx-auto px-4 py-4 flex justify-between items-center">
          <h1 className="text-2xl font-bold text-dna-primary">
            🧬 THE ETHEREUM LIFE FORM
          </h1>
          <ConnectButton />
        </div>
      </header>

      {/* Hero Section */}
      <main className="container mx-auto px-4 pt-32 pb-16">
        <div className="text-center max-w-4xl mx-auto">
          <h2 className="text-6xl font-bold mb-6 bg-gradient-to-r from-dna-primary via-dna-secondary to-dna-primary bg-clip-text text-transparent animate-pulse-dna">
            Evolving Digital Life on Ethereum
          </h2>
          <p className="text-xl text-gray-300 mb-12 leading-relaxed">
            Autonomous smart contracts that <span className="text-dna-primary font-semibold">EVOLVE</span>,{' '}
            <span className="text-dna-secondary font-semibold">REPRODUCE</span>, and{' '}
            <span className="text-energy-high font-semibold">COMPETE</span> for survival on the blockchain.
            Witness artificial life using Ethereum as its primordial soup!
          </p>

          {/* Feature Grid */}
          <div className="grid md:grid-cols-3 gap-6 mb-16">
            <div className="bg-gray-800/50 border border-dna-primary/30 rounded-lg p-6 hover:border-dna-primary transition-all">
              <div className="text-4xl mb-4">🧬</div>
              <h3 className="text-xl font-bold text-dna-primary mb-2">Digital DNA</h3>
              <p className="text-gray-400">
                256-bit chromosomes with mutable genes, heredity patterns, and evolutionary markers
              </p>
            </div>

            <div className="bg-gray-800/50 border border-dna-secondary/30 rounded-lg p-6 hover:border-dna-secondary transition-all">
              <div className="text-4xl mb-4">⚡</div>
              <h3 className="text-xl font-bold text-dna-secondary mb-2">Self-Modifying Code</h3>
              <p className="text-gray-400">
                Organisms that can evolve their own bytecode, upgrade behaviors, and adapt to survive
              </p>
            </div>

            <div className="bg-gray-800/50 border border-energy-high/30 rounded-lg p-6 hover:border-energy-high transition-all">
              <div className="text-4xl mb-4">🌱</div>
              <h3 className="text-xl font-bold text-energy-high mb-2">Natural Selection</h3>
              <p className="text-gray-400">
                Compete for energy, reproduce with mutations, and watch evolution happen in real-time
              </p>
            </div>
          </div>

          {/* Action Buttons */}
          <div className="flex gap-4 justify-center flex-wrap">
            <Link
              href="/create"
              className="px-8 py-4 bg-dna-primary text-black font-bold rounded-lg hover:bg-dna-primary/80 transition-all transform hover:scale-105 shadow-lg"
            >
              Create Organism
            </Link>
            <Link
              href="/ecosystem"
              className="px-8 py-4 bg-dna-secondary text-white font-bold rounded-lg hover:bg-dna-secondary/80 transition-all transform hover:scale-105 shadow-lg"
            >
              View Ecosystem
            </Link>
            <Link
              href="/genealogy"
              className="px-8 py-4 bg-gray-700 text-white font-bold rounded-lg hover:bg-gray-600 transition-all transform hover:scale-105 shadow-lg"
            >
              Genealogy Tree
            </Link>
          </div>
        </div>

        {/* Stats Section */}
        <div className="mt-24 grid md:grid-cols-4 gap-6 max-w-5xl mx-auto">
          <div className="text-center">
            <div className="text-4xl font-bold text-dna-primary mb-2">0</div>
            <div className="text-gray-400">Living Organisms</div>
          </div>
          <div className="text-center">
            <div className="text-4xl font-bold text-dna-secondary mb-2">0</div>
            <div className="text-gray-400">Total Reproductions</div>
          </div>
          <div className="text-center">
            <div className="text-4xl font-bold text-energy-high mb-2">0</div>
            <div className="text-gray-400">Mutations</div>
          </div>
          <div className="text-center">
            <div className="text-4xl font-bold text-organism-dead mb-2">0</div>
            <div className="text-gray-400">Extinctions</div>
          </div>
        </div>

        {/* How It Works */}
        <div className="mt-24 max-w-4xl mx-auto">
          <h3 className="text-3xl font-bold text-center mb-12 text-dna-primary">
            How Digital Evolution Works
          </h3>
          <div className="space-y-6">
            <div className="bg-gray-800/30 border border-gray-700 rounded-lg p-6">
              <div className="flex items-start gap-4">
                <div className="text-2xl">1️⃣</div>
                <div>
                  <h4 className="text-xl font-bold mb-2">Genesis - Create Your Organism</h4>
                  <p className="text-gray-400">
                    Deploy a DigitalOrganism contract with unique genetic code. Each organism has a genome
                    containing mutable genes, energy reserves, and evolutionary potential.
                  </p>
                </div>
              </div>
            </div>

            <div className="bg-gray-800/30 border border-gray-700 rounded-lg p-6">
              <div className="flex items-start gap-4">
                <div className="text-2xl">2️⃣</div>
                <div>
                  <h4 className="text-xl font-bold mb-2">Feed & Grow - Provide Energy</h4>
                  <p className="text-gray-400">
                    Send ETH to your organism to increase its energy. Higher energy improves fitness,
                    enables reproduction, and allows for more complex evolutionary adaptations.
                  </p>
                </div>
              </div>
            </div>

            <div className="bg-gray-800/30 border border-gray-700 rounded-lg p-6">
              <div className="flex items-start gap-4">
                <div className="text-2xl">3️⃣</div>
                <div>
                  <h4 className="text-xl font-bold mb-2">Reproduce & Mutate</h4>
                  <p className="text-gray-400">
                    When organisms have sufficient energy, they can reproduce. Offspring inherit parent genes
                    with random mutations, creating genetic diversity and evolutionary pressure.
                  </p>
                </div>
              </div>
            </div>

            <div className="bg-gray-800/30 border border-gray-700 rounded-lg p-6">
              <div className="flex items-start gap-4">
                <div className="text-2xl">4️⃣</div>
                <div>
                  <h4 className="text-xl font-bold mb-2">Compete & Evolve</h4>
                  <p className="text-gray-400">
                    Organisms compete for resources in tournaments. Winners gain energy and fitness.
                    The most fit organisms survive, reproduce more, and drive the evolution of the species.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="border-t border-gray-800 mt-24">
        <div className="container mx-auto px-4 py-8 text-center text-gray-500">
          <p>The Ethereum Life Form - Digital Evolution on the Blockchain</p>
          <p className="text-sm mt-2">Powered by Ethereum, OpenZeppelin, and the primordial soup of Web3</p>
        </div>
      </footer>
    </div>
  );
}
