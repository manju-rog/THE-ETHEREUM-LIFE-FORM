import React, { useState } from 'react';
import styled from 'styled-components';
import { BrowserRouter as Router, Routes, Route, Link } from 'router-dom';
import GenomeVisualization from './components/GenomeVisualization';
import GenealogyTree from './components/GenealogyTree';
import EcosystemView from './components/EcosystemView';
import BehavioralHeatmap from './components/BehavioralHeatmap';
import TimeLapseEvolution from './components/TimeLapseEvolution';
import ConsciousnessAurora from './components/ConsciousnessAurora';
import ControlPanel from './components/ControlPanel';
import StatsOverlay from './components/StatsOverlay';
import useBlockchain from './hooks/useBlockchain';

const AppContainer = styled.div`
  width: 100vw;
  height: 100vh;
  position: relative;
  background: radial-gradient(ellipse at bottom, #1B2735 0%, #090A0F 100%);
  color: #00ffff;
  overflow: hidden;
`;

const Nav = styled.nav`
  position: fixed;
  top: 20px;
  left: 20px;
  z-index: 1000;
  display: flex;
  gap: 15px;
  background: rgba(0, 0, 0, 0.7);
  padding: 15px 20px;
  border-radius: 10px;
  border: 1px solid rgba(0, 255, 255, 0.3);
  backdrop-filter: blur(10px);
`;

const NavButton = styled(Link)`
  color: ${props => props.active ? '#00ffff' : '#666'};
  text-decoration: none;
  padding: 8px 16px;
  border-radius: 5px;
  transition: all 0.3s ease;
  border: 1px solid ${props => props.active ? '#00ffff' : 'transparent'};
  background: ${props => props.active ? 'rgba(0, 255, 255, 0.1)' : 'transparent'};

  &:hover {
    color: #00ffff;
    border-color: #00ffff;
    background: rgba(0, 255, 255, 0.1);
    transform: translateY(-2px);
    box-shadow: 0 5px 15px rgba(0, 255, 255, 0.3);
  }
`;

const Title = styled.h1`
  position: fixed;
  top: 20px;
  right: 20px;
  z-index: 1000;
  margin: 0;
  font-size: 24px;
  font-weight: 300;
  text-shadow: 0 0 20px rgba(0, 255, 255, 0.8);
  animation: pulse 2s ease-in-out infinite;

  @keyframes pulse {
    0%, 100% {
      text-shadow: 0 0 20px rgba(0, 255, 255, 0.8);
    }
    50% {
      text-shadow: 0 0 30px rgba(0, 255, 255, 1);
    }
  }
`;

const StatusBar = styled.div`
  position: fixed;
  bottom: 20px;
  left: 20px;
  right: 20px;
  z-index: 1000;
  background: rgba(0, 0, 0, 0.7);
  padding: 15px 20px;
  border-radius: 10px;
  border: 1px solid rgba(0, 255, 255, 0.3);
  backdrop-filter: blur(10px);
  display: flex;
  justify-content: space-between;
  align-items: center;
`;

const Stat = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;

  .label {
    font-size: 12px;
    color: #666;
    margin-bottom: 5px;
  }

  .value {
    font-size: 20px;
    font-weight: bold;
    color: #00ffff;
    text-shadow: 0 0 10px rgba(0, 255, 255, 0.5);
  }
`;

const ConnectionStatus = styled.div`
  position: fixed;
  top: 90px;
  left: 20px;
  z-index: 1000;
  padding: 10px 15px;
  background: rgba(0, 0, 0, 0.7);
  border-radius: 5px;
  border: 1px solid ${props => props.connected ? 'rgba(0, 255, 0, 0.5)' : 'rgba(255, 0, 0, 0.5)'};
  backdrop-filter: blur(10px);
  color: ${props => props.connected ? '#00ff00' : '#ff0000'};
  font-size: 12px;

  &::before {
    content: '';
    display: inline-block;
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: ${props => props.connected ? '#00ff00' : '#ff0000'};
    margin-right: 8px;
    box-shadow: 0 0 10px ${props => props.connected ? 'rgba(0, 255, 0, 0.8)' : 'rgba(255, 0, 0, 0.8)'};
  }
`;

function App() {
  const [currentView, setCurrentView] = useState('ecosystem');
  const { connected, stats, loading } = useBlockchain();

  return (
    <Router>
      <AppContainer>
        <Title>🧬 THE ETHEREUM LIFE FORM</Title>

        <ConnectionStatus connected={connected}>
          {connected ? 'Connected to Blockchain' : 'Connecting...'}
        </ConnectionStatus>

        <Nav>
          <NavButton
            to="/ecosystem"
            active={currentView === 'ecosystem'}
            onClick={() => setCurrentView('ecosystem')}
          >
            🌍 Ecosystem
          </NavButton>
          <NavButton
            to="/genome"
            active={currentView === 'genome'}
            onClick={() => setCurrentView('genome')}
          >
            🧬 Genome
          </NavButton>
          <NavButton
            to="/genealogy"
            active={currentView === 'genealogy'}
            onClick={() => setCurrentView('genealogy')}
          >
            🌳 Family Tree
          </NavButton>
          <NavButton
            to="/behavior"
            active={currentView === 'behavior'}
            onClick={() => setCurrentView('behavior')}
          >
            🎯 Behavior
          </NavButton>
          <NavButton
            to="/evolution"
            active={currentView === 'evolution'}
            onClick={() => setCurrentView('evolution')}
          >
            ⏱️ Time-Lapse
          </NavButton>
          <NavButton
            to="/consciousness"
            active={currentView === 'consciousness'}
            onClick={() => setCurrentView('consciousness')}
          >
            🧠 Consciousness
          </NavButton>
        </Nav>

        <Routes>
          <Route path="/" element={<EcosystemView />} />
          <Route path="/ecosystem" element={<EcosystemView />} />
          <Route path="/genome" element={<GenomeVisualization />} />
          <Route path="/genealogy" element={<GenealogyTree />} />
          <Route path="/behavior" element={<BehavioralHeatmap />} />
          <Route path="/evolution" element={<TimeLapseEvolution />} />
          <Route path="/consciousness" element={<ConsciousnessAurora />} />
        </Routes>

        {!loading && (
          <StatusBar>
            <Stat>
              <div className="label">Living Organisms</div>
              <div className="value">{stats.livingOrganisms || 0}</div>
            </Stat>
            <Stat>
              <div className="label">Total Generations</div>
              <div className="value">{stats.totalGenerations || 0}</div>
            </Stat>
            <Stat>
              <div className="label">Avg Fitness</div>
              <div className="value">{stats.avgFitness ? stats.avgFitness.toFixed(1) : '0.0'}</div>
            </Stat>
            <Stat>
              <div className="label">Conscious Organisms</div>
              <div className="value">{stats.consciousCount || 0}</div>
            </Stat>
            <Stat>
              <div className="label">Global Φ</div>
              <div className="value">{stats.globalPhi || 0}</div>
            </Stat>
          </StatusBar>
        )}

        <ControlPanel />
        <StatsOverlay />
      </AppContainer>
    </Router>
  );
}

export default App;
