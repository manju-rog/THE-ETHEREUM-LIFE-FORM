import React from 'react';
import styled from 'styled-components';

const Container = styled.div`
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #00ffff;
  font-size: 24px;
`;

function GenealogyTree() {
  return (
    <Container>
      🌳 Genealogy Tree Visualization
      <div style={{ fontSize: '14px', marginTop: '20px', textAlign: 'center' }}>
        Coming Soon: D3.js force-directed family trees with branching evolution
      </div>
    </Container>
  );
}

export default GenealogyTree;
