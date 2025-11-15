import React, { useRef, useMemo, useState } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { OrbitControls, Text, Html } from '@react-three/drei';
import * as THREE from 'three';
import styled from 'styled-components';

const Container = styled.div`
  width: 100%;
  height: 100%;
  position: relative;
`;

const Controls = styled.div`
  position: absolute;
  top: 100px;
  left: 20px;
  z-index: 100;
  background: rgba(0, 0, 0, 0.7);
  padding: 20px;
  border-radius: 10px;
  border: 1px solid rgba(0, 255, 255, 0.3);
  backdrop-filter: blur(10px);
  max-width: 300px;

  h3 {
    margin: 0 0 15px 0;
    color: #00ffff;
    font-size: 16px;
  }

  label {
    display: block;
    margin: 10px 0;
    color: #888;
    font-size: 12px;
  }

  select, input {
    width: 100%;
    padding: 8px;
    background: rgba(0, 0, 0, 0.5);
    border: 1px solid rgba(0, 255, 255, 0.3);
    color: #00ffff;
    border-radius: 5px;
    margin-top: 5px;

    &:focus {
      outline: none;
      border-color: #00ffff;
      box-shadow: 0 0 10px rgba(0, 255, 255, 0.3);
    }
  }
`;

const GeneInfo = styled.div`
  position: absolute;
  top: 100px;
  right: 20px;
  z-index: 100;
  background: rgba(0, 0, 0, 0.8);
  padding: 20px;
  border-radius: 10px;
  border: 1px solid rgba(0, 255, 255, 0.5);
  backdrop-filter: blur(10px);
  max-width: 250px;

  h3 {
    margin: 0 0 15px 0;
    color: #00ffff;
    font-size: 18px;
    text-shadow: 0 0 10px rgba(0, 255, 255, 0.8);
  }

  .stat {
    margin: 8px 0;
    color: #888;
    font-size: 14px;

    span {
      color: #00ffff;
      font-weight: bold;
    }
  }

  .gene-visual {
    margin-top: 15px;
    padding: 10px;
    background: rgba(0, 255, 255, 0.1);
    border-radius: 5px;
    border: 1px solid rgba(0, 255, 255, 0.3);
    font-family: monospace;
    font-size: 12px;
    color: #00ffff;
    word-break: break-all;
  }
`;

// DNA Helix component
function DNAHelix({ genomeData, showMutations, highlightActive }) {
  const helixRef = useRef();
  const baseCount = 32; // Number of base pairs per chromosome

  useFrame((state) => {
    if (helixRef.current) {
      helixRef.current.rotation.y += 0.001;
    }
  });

  const chromosomes = useMemo(() => {
    return genomeData.chromosomes.map((chromosome, chromIndex) => {
      const helixHeight = 10;
      const radius = 2;
      const turns = 2;

      const basePairs = [];

      for (let i = 0; i < baseCount; i++) {
        const t = i / baseCount;
        const angle = t * Math.PI * 2 * turns;
        const y = t * helixHeight - helixHeight / 2;

        const gene = chromosome.genes[i % chromosome.genes.length];

        // Strand 1 position
        const x1 = Math.cos(angle + chromIndex * Math.PI / 2) * radius;
        const z1 = Math.sin(angle + chromIndex * Math.PI / 2) * radius;

        // Strand 2 position (opposite side)
        const x2 = Math.cos(angle + Math.PI + chromIndex * Math.PI / 2) * radius;
        const z2 = Math.sin(angle + Math.PI + chromIndex * Math.PI / 2) * radius;

        // Color based on gene properties
        let color = new THREE.Color();
        if (gene.mutated && showMutations) {
          color.setHSL(0, 1, 0.5); // Red for mutations
        } else if (gene.expressed && highlightActive) {
          color.setHSL(0.6, 1, 0.6); // Blue for active
        } else {
          color.setHSL(gene.dominance / 255, 0.8, 0.5); // Rainbow based on dominance
        }

        basePairs.push({
          pos1: [x1, y, z1],
          pos2: [x2, y, z2],
          color,
          glowing: gene.expressed && highlightActive,
          mutated: gene.mutated && showMutations,
          value: gene.value,
        });
      }

      return {
        basePairs,
        offset: chromIndex * 6,
      };
    });
  }, [genomeData, showMutations, highlightActive]);

  return (
    <group ref={helixRef}>
      {chromosomes.map((chromosome, chromIndex) => (
        <group key={chromIndex} position={[chromosome.offset, 0, 0]}>
          {/* Chromosome label */}
          <Text
            position={[0, 6, 0]}
            fontSize={0.5}
            color="#00ffff"
            anchorX="center"
            anchorY="middle"
          >
            Chr {chromIndex + 1}
          </Text>

          {chromosome.basePairs.map((pair, pairIndex) => (
            <group key={pairIndex}>
              {/* Base pair spheres */}
              <mesh position={pair.pos1}>
                <sphereGeometry args={[0.1, 8, 8]} />
                <meshStandardMaterial
                  color={pair.color}
                  emissive={pair.glowing ? pair.color : new THREE.Color(0, 0, 0)}
                  emissiveIntensity={pair.glowing ? 0.5 : 0}
                />
              </mesh>

              <mesh position={pair.pos2}>
                <sphereGeometry args={[0.1, 8, 8]} />
                <meshStandardMaterial
                  color={pair.color}
                  emissive={pair.glowing ? pair.color : new THREE.Color(0, 0, 0)}
                  emissiveIntensity={pair.glowing ? 0.5 : 0}
                />
              </mesh>

              {/* Connection line */}
              <line>
                <bufferGeometry attach="geometry">
                  <bufferAttribute
                    attach="attributes-position"
                    array={new Float32Array([
                      ...pair.pos1,
                      ...pair.pos2,
                    ])}
                    count={2}
                    itemSize={3}
                  />
                </bufferGeometry>
                <lineBasicMaterial
                  attach="material"
                  color={pair.mutated ? 0xff0000 : 0x00ffff}
                  linewidth={pair.mutated ? 3 : 1}
                  opacity={0.6}
                  transparent
                />
              </line>

              {/* Mutation indicator */}
              {pair.mutated && (
                <mesh position={[(pair.pos1[0] + pair.pos2[0]) / 2, pair.pos1[1], (pair.pos1[2] + pair.pos2[2]) / 2]}>
                  <octahedronGeometry args={[0.15]} />
                  <meshStandardMaterial
                    color={0xff0000}
                    emissive={0xff0000}
                    emissiveIntensity={0.8}
                  />
                </mesh>
              )}
            </group>
          ))}

          {/* Backbone tube */}
          <TubeHelix
            basePairs={chromosome.basePairs.map(bp => bp.pos1)}
            color="#00ffff"
            opacity={0.3}
          />
          <TubeHelix
            basePairs={chromosome.basePairs.map(bp => bp.pos2)}
            color="#00ffff"
            opacity={0.3}
          />
        </group>
      ))}
    </group>
  );
}

// Tube connecting backbone
function TubeHelix({ basePairs, color, opacity }) {
  const points = useMemo(() => {
    return basePairs.map(pos => new THREE.Vector3(...pos));
  }, [basePairs]);

  const curve = useMemo(() => {
    return new THREE.CatmullRomCurve3(points);
  }, [points]);

  return (
    <mesh>
      <tubeGeometry args={[curve, 64, 0.05, 8, false]} />
      <meshStandardMaterial
        color={color}
        transparent
        opacity={opacity}
        emissive={color}
        emissiveIntensity={0.2}
      />
    </mesh>
  );
}

// Main component
function GenomeVisualization() {
  const [selectedOrganism, setSelectedOrganism] = useState(null);
  const [showMutations, setShowMutations] = useState(true);
  const [highlightActive, setHighlightActive] = useState(true);
  const [rotationSpeed, setRotationSpeed] = useState(1);

  // Mock genome data - would fetch from blockchain
  const genomeData = useMemo(() => ({
    chromosomes: Array(4).fill(null).map((_, i) => ({
      id: i,
      genes: Array(8).fill(null).map((_, j) => ({
        value: Math.floor(Math.random() * 1000),
        dominance: Math.floor(Math.random() * 256),
        expressed: Math.random() > 0.5,
        mutated: Math.random() > 0.9,
        methylation: Math.random(),
      })),
    })),
    mutations: 3,
    activeGenes: 24,
    totalGenes: 32,
  }), []);

  return (
    <Container>
      <Canvas camera={{ position: [0, 0, 20], fov: 60 }}>
        <color attach="background" args={['#000000']} />

        {/* Lighting */}
        <ambientLight intensity={0.5} />
        <pointLight position={[10, 10, 10]} intensity={1} />
        <pointLight position={[-10, -10, -10]} intensity={0.5} color="#00ffff" />
        <pointLight position={[0, 15, 0]} intensity={0.3} color="#ff00ff" />

        {/* DNA Visualization */}
        <DNAHelix
          genomeData={genomeData}
          showMutations={showMutations}
          highlightActive={highlightActive}
        />

        {/* Controls */}
        <OrbitControls
          enableDamping
          dampingFactor={0.05}
          rotateSpeed={0.5}
          minDistance={10}
          maxDistance={40}
        />

        {/* Starfield background */}
        <Stars />
      </Canvas>

      <Controls>
        <h3>🧬 Genome Controls</h3>

        <label>
          Organism
          <select
            value={selectedOrganism || ''}
            onChange={(e) => setSelectedOrganism(e.target.value)}
          >
            <option value="">Select organism...</option>
            <option value="0x1">Organism #1</option>
            <option value="0x2">Organism #2</option>
            <option value="0x3">Organism #3</option>
          </select>
        </label>

        <label>
          <input
            type="checkbox"
            checked={showMutations}
            onChange={(e) => setShowMutations(e.target.checked)}
          />
          {' '}Show Mutations
        </label>

        <label>
          <input
            type="checkbox"
            checked={highlightActive}
            onChange={(e) => setHighlightActive(e.target.checked)}
          />
          {' '}Highlight Active Genes
        </label>

        <label>
          Rotation Speed
          <input
            type="range"
            min="0"
            max="5"
            step="0.1"
            value={rotationSpeed}
            onChange={(e) => setRotationSpeed(parseFloat(e.target.value))}
          />
        </label>
      </Controls>

      <GeneInfo>
        <h3>📊 Genome Stats</h3>
        <div className="stat">
          Chromosomes: <span>{genomeData.chromosomes.length}</span>
        </div>
        <div className="stat">
          Total Genes: <span>{genomeData.totalGenes}</span>
        </div>
        <div className="stat">
          Active Genes: <span>{genomeData.activeGenes}</span>
        </div>
        <div className="stat">
          Mutations: <span style={{ color: '#ff0000' }}>{genomeData.mutations}</span>
        </div>
        <div className="stat">
          Expression: <span>{((genomeData.activeGenes / genomeData.totalGenes) * 100).toFixed(1)}%</span>
        </div>

        <div className="gene-visual">
          {genomeData.chromosomes[0].genes.slice(0, 4).map((gene, i) => (
            <div key={i} style={{ marginBottom: '5px' }}>
              Gene {i + 1}: {gene.expressed ? '✓' : '✗'} {gene.mutated ? '⚠' : ''}
            </div>
          ))}
        </div>
      </GeneInfo>
    </Container>
  );
}

// Starfield background
function Stars() {
  const count = 5000;
  const positions = useMemo(() => {
    const positions = new Float32Array(count * 3);
    for (let i = 0; i < count; i++) {
      positions[i * 3] = (Math.random() - 0.5) * 100;
      positions[i * 3 + 1] = (Math.random() - 0.5) * 100;
      positions[i * 3 + 2] = (Math.random() - 0.5) * 100;
    }
    return positions;
  }, []);

  return (
    <points>
      <bufferGeometry>
        <bufferAttribute
          attach="attributes-position"
          array={positions}
          count={count}
          itemSize={3}
        />
      </bufferGeometry>
      <pointsMaterial
        size={0.05}
        color="#ffffff"
        transparent
        opacity={0.6}
        sizeAttenuation
      />
    </points>
  );
}

export default GenomeVisualization;
