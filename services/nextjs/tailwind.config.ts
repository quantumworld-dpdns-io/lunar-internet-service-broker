import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './src/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        lunar: {
          50: '#f0f5ff',
          100: '#e0ebff',
          200: '#c2d6ff',
          300: '#94b8ff',
          400: '#6090ff',
          500: '#3b6bff',
          600: '#1a45f5',
          700: '#1234e1',
          800: '#152cb6',
          900: '#17298f',
          950: '#0f1a57',
        },
      },
    },
  },
  plugins: [],
}

export default config
