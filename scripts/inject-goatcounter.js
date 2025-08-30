// scripts/inject-goatcounter.js
const { replaceInFileSync } = require('replace-in-file');

const GOATCOUNTER_URL = process.env.GOATCOUNTER_URL;

if (!GOATCOUNTER_URL) {
  console.error('Error: GOATCOUNTER_URL not set');
  process.exit(1);
}

const options = {
  files: 'public/index.html',
  from: /{{GOATCOUNTER_URL}}/g,
  to: GOATCOUNTER_URL,
};

try {
  // Use the correct function name: replaceInFileSync
  const results = replaceInFileSync(options);
  console.log('Replaced in files:', results.join(', '));
} catch (error) {
  console.error('Error replacing in files:', error);
  process.exit(1);
}