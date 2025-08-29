// scripts/inject-goatcounter.js
const replace = require('replace-in-file');

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
  const results = replace.sync(options);
  console.log('Replaced in files:', results.join(', '));
} catch (error) {
  console.error('Error replacing in files:', error);
  process.exit(1);
}
