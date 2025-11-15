import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        background: "var(--background)",
        foreground: "var(--foreground)",
        'dna-primary': '#00ff88',
        'dna-secondary': '#0088ff',
        'organism-alive': '#00ff00',
        'organism-dead': '#ff0000',
        'energy-high': '#ffff00',
        'energy-low': '#ff6600',
      },
      animation: {
        'pulse-dna': 'pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'evolve': 'evolve 3s ease-in-out infinite',
      },
      keyframes: {
        evolve: {
          '0%, 100%': { transform: 'scale(1) rotate(0deg)' },
          '50%': { transform: 'scale(1.05) rotate(180deg)' },
        },
      },
    },
  },
  plugins: [],
};

export default config;
