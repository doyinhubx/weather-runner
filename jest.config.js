module.exports = {
  testEnvironment: 'node',
  testMatch: ['**/__tests__/**/*.test.js'],
  coverageThreshold: {
    global: {
      branches: 0,
      functions: 80,
      lines: 80,
      statements: 80
    }
  }
};
