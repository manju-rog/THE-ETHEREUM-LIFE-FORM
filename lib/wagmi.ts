import { getDefaultConfig } from '@rainbow-me/rainbowkit';
import { hardhat, sepolia, mainnet } from 'wagmi/chains';

export const config = getDefaultConfig({
  appName: 'The Ethereum Life Form',
  projectId: process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID || 'YOUR_PROJECT_ID',
  chains: [hardhat, sepolia, mainnet],
  ssr: true,
});
