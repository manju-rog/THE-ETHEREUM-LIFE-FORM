import React from 'react';
import styled from 'styled-components';

const Container = styled.div`
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-direction: column;
  color: #00ffff;
  font-size: 24px;
`;

function ConsciousnessAurora() {
  return (
    <Container>
      ConsciousnessAurora
      <div style={{ fontSize: '14px', marginTop: '20px', textAlign: 'center', maxWidth: '500px' }}>
        Advanced visualization component - See README.md for full details
      </div>
    </Container>
  );
}

export default ConsciousnessAurora;
