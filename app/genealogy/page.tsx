'use client';

import Link from 'next/link';
import { ConnectButton } from '@rainbow-me/rainbowkit';

export default function Genealogy() {
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
        <div className="text-center max-w-4xl mx-auto">
          <h1 className="text-5xl font-bold mb-4 bg-gradient-to-r from-dna-primary via-dna-secondary to-dna-primary bg-clip-text text-transparent">
            Genealogy Tree
          </h1>
          <p className="text-xl text-gray-300 mb-12">
            Trace the evolutionary lineage of digital organisms
          </p>

          <div className="bg-gray-800/50 border border-dna-primary/30 rounded-2xl p-12">
            <div className="text-8xl mb-6">🌳</div>
            <h2 className="text-3xl font-bold mb-4 text-gray-300">
              Coming Soon
            </h2>
            <p className="text-gray-400 mb-8">
              The genealogy tree visualization is under development.
              This will show the complete evolutionary history and family trees
              of all organisms in the ecosystem.
            </p>

            <div className="space-y-4 text-left max-w-2xl mx-auto">
              <h3 className="text-xl font-bold text-dna-primary mb-3">
                Planned Features:
              </h3>
              <div className="space-y-3 text-gray-300">
                <div className="flex items-start gap-3">
                  <span className="text-dna-primary">•</span>
                  <span>Interactive D3.js tree visualization</span>
                </div>
                <div className="flex items-start gap-3">
                  <span className="text-dna-primary">•</span>
                  <span>Trace ancestry back to genesis organisms</span>
                </div>
                <div className="flex items-start gap-3">
                  <span className="text-dna-primary">•</span>
                  <span>View mutation history across generations</span>
                </div>
                <div className="flex items-start gap-3">
                  <span className="text-dna-primary">•</span>
                  <span>Analyze fitness trends over time</span>
                </div>
                <div className="flex items-start gap-3">
                  <span className="text-dna-primary">•</span>
                  <span>Identify successful genetic lineages</span>
                </div>
                <div className="flex items-start gap-3">
                  <span className="text-dna-primary">•</span>
                  <span>Export family tree data to IPFS</span>
                </div>
              </div>
            </div>

            <div className="mt-12">
              <Link
                href="/ecosystem"
                className="inline-block px-8 py-4 bg-dna-primary text-black font-bold rounded-lg hover:opacity-90 transition-all"
              >
                View Ecosystem Instead
              </Link>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
