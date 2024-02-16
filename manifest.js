const baseManifest = require('@dazn/kopytko-unit-testing-framework/manifest');

module.exports = {
  ...baseManifest,
  bs_const: {
    ...baseManifest.bs_const,
    enableKopytkoComponentDidCatch: false,
  },
}
