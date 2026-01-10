/** @type {import('jest').Config} */
module.exports = {
  transform: {
    '^.+\\.(js|jsx|ts|tsx)$': 'babel-jest',
  },
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json', 'node'],
  testMatch: ['**/__tests__/**/*.test.js', '**/__tests__/**/*.test.ts'],
  testEnvironment: 'node',
};
