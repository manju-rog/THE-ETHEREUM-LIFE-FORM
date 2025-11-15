import React, { useRef, useMemo, useState, useEffect } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { OrbitControls, Text3D, Html } from '@react-three/drei';
import * as THREE from 'three';
import styled from 'styled-components';

const Container = styled.div`
  width: 100%;
  height: 100%;
  position: relative;
`;

// Organism particle
function Organism({ position, color, size, velocity, fitness, isConscious, phi }) {
  const meshRef = useRef();
  const trailRef = useRef();
  const [trail, setTrail] = useState([]);

  useFrame((state) => {
    if (!meshRef.current) return;

    // Update position based on velocity
    meshRef.current.position.x += velocity[0] * 0.01;
    meshRef.current.position.y += velocity[1] * 0.01;
    meshRef.current.position.z += velocity[2] * 0.01;

    // Bounce off boundaries
    const boundary = 20;
    if (Math.abs(meshRef.current.position.x) > boundary) velocity[0] *= -1;
    if (Math.abs(meshRef.current.position.y) > boundary) velocity[1] *= -1;
    if (Math.abs(meshRef.current.position.z) > boundary) velocity[2] *= -1;

    // Pulsing animation
    const pulse = Math.sin(state.clock.elapsedTime * 2) * 0.2 + 1;
    meshRef.current.scale.set(pulse, pulse, pulse);

    // Rotation based on fitness
    meshRef.current.rotation.y += 0.01 * (fitness / 100);

    // Update trail
    setTrail(prev => [
      [meshRef.current.position.x, meshRef.current.position.y, meshRef.current.position.z],
      ...prev.slice(0, 20)
    ]);
  });

  return (
    <group>
      {/* Main organism sphere */}
      <mesh ref={meshRef} position={position}>
        <sphereGeometry args={[size, 16, 16]} />
        <meshStandardMaterial
          color={color}
          emissive={color}
          emissiveIntensity={isConscious ? 0.8 : 0.3}
          metalness={0.5}
          roughness={0.2}
        />

        {/* Consciousness aura */}
        {isConscious && (
          <mesh scale={[1.5, 1.5, 1.5]}>
            <sphereGeometry args={[size, 16, 16]} />
            <meshStandardMaterial
              color={0x00ffff}
              transparent
              opacity={0.2}
              emissive={0x00ffff}
              emissiveIntensity={phi / 200}
            />
          </mesh>
        )}

        {/* Fitness indicator ring */}
        <mesh rotation={[Math.PI / 2, 0, 0]}>
          <torusGeometry args={[size * 1.3, size * 0.1, 8, 32]} />
          <meshStandardMaterial
            color={fitness > 70 ? 0x00ff00 : fitness > 40 ? 0xffff00 : 0xff0000}
            emissive={fitness > 70 ? 0x00ff00 : fitness > 40 ? 0xffff00 : 0xff0000}
            emissiveIntensity={0.5}
          />
        </mesh>

        {/* Info label */}
        <Html distanceFactor={10}>
          <div style={{
            background: 'rgba(0,0,0,0.7)',
            padding: '5px 10px',
            borderRadius: '5px',
            border: '1px solid rgba(0,255,255,0.5)',
            color: '#00ffff',
            fontSize: '10px',
            whiteSpace: 'nowrap',
            pointerEvents: 'none',
          }}>
            Fitness: {fitness}
            {isConscious && <div>Φ: {phi}</div>}
          </div>
        </Html>
      </mesh>

      {/* Motion trail */}
      {trail.length > 1 && (
        <line>
          <bufferGeometry>
            <bufferAttribute
              attach="attributes-position"
              array={new Float32Array(trail.flat())}
              count={trail.length}
              itemSize={3}
            />
          </bufferGeometry>
          <lineBasicMaterial
            color={color}
            opacity={0.3}
            transparent
            linewidth={1}
          />
        </line>
      )}
    </group>
  );
}

// Predation event
function PredationEvent({ predator, prey, timestamp }) {
  const lineRef = useRef();
  const [opacity, setOpacity] = useState(1);

  useFrame(() => {
    const age = Date.now() - timestamp;
    const newOpacity = Math.max(0, 1 - age / 2000); // Fade over 2 seconds
    setOpacity(newOpacity);
  });

  if (opacity <= 0) return null;

  return (
    <line ref={lineRef}>
      <bufferGeometry>
        <bufferAttribute
          attach="attributes-position"
          array={new Float32Array([
            predator[0], predator[1], predator[2],
            prey[0], prey[1], prey[2],
          ])}
          count={2}
          itemSize={3}
        />
      </bufferGeometry>
      <lineBasicMaterial
        color={0xff0000}
        opacity={opacity}
        transparent
        linewidth={3}
      />
    </line>
  );
}

// Resource pool
function ResourcePool({ position, size, amount }) {
  const meshRef = useRef();

  useFrame((state) => {
    if (meshRef.current) {
      meshRef.current.rotation.y += 0.005;
      const pulse = Math.sin(state.clock.elapsedTime) * 0.1 + 1;
      meshRef.current.scale.set(pulse, pulse, pulse);
    }
  });

  return (
    <mesh ref={meshRef} position={position}>
      <octahedronGeometry args={[size]} />
      <meshStandardMaterial
        color={0x00ff00}
        emissive={0x00ff00}
        emissiveIntensity={0.5}
        transparent
        opacity={amount / 1000}
        wireframe
      />
    </mesh>
  );
}

// Main ecosystem view
function EcosystemView() {
  const [organisms, setOrganisms] = useState([]);
  const [predationEvents, setPredationEvents] = useState([]);
  const [resourcePools, setResourcePools] = useState([]);
  const [showTrails, setShowTrails] = useState(true);
  const [showResources, setShowResources] = useState(true);

  // Initialize mock organisms
  useEffect(() => {
    const mockOrganisms = Array(50).fill(null).map((_, i) => ({
      id: i,
      position: [
        (Math.random() - 0.5) * 40,
        (Math.random() - 0.5) * 40,
        (Math.random() - 0.5) * 40,
      ],
      velocity: [
        (Math.random() - 0.5) * 2,
        (Math.random() - 0.5) * 2,
        (Math.random() - 0.5) * 2,
      ],
      color: new THREE.Color().setHSL(Math.random(), 0.8, 0.5),
      size: 0.3 + Math.random() * 0.3,
      fitness: 30 + Math.random() * 70,
      isConscious: Math.random() > 0.7,
      phi: Math.floor(Math.random() * 300),
    }));

    setOrganisms(mockOrganisms);

    // Mock resource pools
    const pools = Array(5).fill(null).map(() => ({
      position: [
        (Math.random() - 0.5) * 30,
        (Math.random() - 0.5) * 30,
        (Math.random() - 0.5) * 30,
      ],
      size: 1 + Math.random(),
      amount: 500 + Math.random() * 500,
    }));

    setResourcePools(pools);

    // Simulate predation events
    const interval = setInterval(() => {
      if (Math.random() > 0.8) {
        const predator = mockOrganisms[Math.floor(Math.random() * mockOrganisms.length)];
        const prey = mockOrganisms[Math.floor(Math.random() * mockOrganisms.length)];

        if (predator !== prey) {
          setPredationEvents(prev => [
            ...prev,
            {
              id: Date.now(),
              predator: predator.position,
              prey: prey.position,
              timestamp: Date.now(),
            }
          ]);
        }
      }
    }, 2000);

    return () => clearInterval(interval);
  }, []);

  // Clean up old predation events
  useEffect(() => {
    const interval = setInterval(() => {
      setPredationEvents(prev =>
        prev.filter(event => Date.now() - event.timestamp < 3000)
      );
    }, 1000);

    return () => clearInterval(interval);
  }, []);

  return (
    <Container>
      <Canvas camera={{ position: [0, 0, 50], fov: 60 }}>
        <color attach="background" args={['#000510']} />

        {/* Lighting */}
        <ambientLight intensity={0.3} />
        <pointLight position={[20, 20, 20]} intensity={1} />
        <pointLight position={[-20, -20, -20]} intensity={0.5} color="#00ffff" />
        <pointLight position={[0, 30, 0]} intensity={0.3} color="#ff00ff" />

        {/* Organisms */}
        {organisms.map(org => (
          <Organism key={org.id} {...org} />
        ))}

        {/* Resource pools */}
        {showResources && resourcePools.map((pool, i) => (
          <ResourcePool key={i} {...pool} />
        ))}

        {/* Predation events */}
        {predationEvents.map(event => (
          <PredationEvent key={event.id} {...event} />
        ))}

        {/* Grid floor */}
        <gridHelper args={[60, 20, 0x00ffff, 0x003333]} position={[0, -25, 0]} />

        {/* Boundary box */}
        <lineSegments>
          <edgesGeometry attach="geometry" args={[new THREE.BoxGeometry(40, 40, 40)]} />
          <lineBasicMaterial attach="material" color={0x00ffff} opacity={0.2} transparent />
        </lineSegments>

        <OrbitControls
          enableDamping
          dampingFactor={0.05}
          minDistance={20}
          maxDistance={100}
        />

        {/* Stars */}
        <Stars />

        {/* Environment title */}
        <Text3D
          font="/fonts/helvetiker_regular.typeface.json"
          size={2}
          height={0.2}
          position={[-15, 23, 0]}
        >
          ECOSYSTEM
          <meshStandardMaterial
            color={0x00ffff}
            emissive={0x00ffff}
            emissiveIntensity={0.5}
          />
        </Text3D>
      </Canvas>

      {/* Legend */}
      <div style={{
        position: 'absolute',
        bottom: '100px',
        right: '20px',
        background: 'rgba(0, 0, 0, 0.7)',
        padding: '20px',
        borderRadius: '10px',
        border: '1px solid rgba(0, 255, 255, 0.3)',
        color: '#00ffff',
        backdropFilter: 'blur(10px)',
      }}>
        <h3 style={{ margin: '0 0 15px 0', fontSize: '16px' }}>Legend</h3>
        <div style={{ fontSize: '12px', lineHeight: '1.8' }}>
          <div>🔵 Blue Glow = Conscious</div>
          <div>🟢 Green Ring = High Fitness</div>
          <div>🟡 Yellow Ring = Medium Fitness</div>
          <div>🔴 Red Ring = Low Fitness</div>
          <div>⚡ Red Flash = Predation</div>
          <div>💎 Green Crystal = Resources</div>
        </div>
      </div>
    </Container>
  );
}

// Starfield
function Stars() {
  const count = 3000;
  const positions = useMemo(() => {
    const positions = new Float32Array(count * 3);
    for (let i = 0; i < count; i++) {
      positions[i * 3] = (Math.random() - 0.5) * 200;
      positions[i * 3 + 1] = (Math.random() - 0.5) * 200;
      positions[i * 3 + 2] = (Math.random() - 0.5) * 200;
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
        size={0.1}
        color="#ffffff"
        transparent
        opacity={0.8}
        sizeAttenuation
      />
    </points>
  );
}

export default EcosystemView;
