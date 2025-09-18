// scripts/inject-goatcounter.js
const { replaceInFileSync } = require('replace-in-file');

// Read secrets from environment
const GOATCOUNTER_URL = process.env.GOATCOUNTER_URL;
const PINGDOM_ID = process.env.PINGDOM_ID;

// Ensure required secrets are set
if (!GOATCOUNTER_URL) {
  console.error('Error: GOATCOUNTER_URL not set');
  process.exit(1);
}

if (!PINGDOM_ID) {
  console.error('Error: PINGDOM_ID not set');
  process.exit(1);
}

// Replace GoatCounter URL placeholder
try {
  const goatResults = replaceInFileSync({
    files: 'public/index.html',
    from: /{{GOATCOUNTER_URL}}/g,
    to: GOATCOUNTER_URL,
  });
  console.log('Replaced GOATCOUNTER_URL in files:', goatResults.join(', '));
} catch (error) {
  console.error('Error replacing GOATCOUNTER_URL:', error);
  process.exit(1);
}

// Replace Pingdom ID placeholder
try {
  const pingResults = replaceInFileSync({
    files: 'public/index.html',
    from: /{{PINGDOM_ID}}/g,
    to: PINGDOM_ID,
  });
  console.log('Replaced PINGDOM_ID in files:', pingResults.join(', '));
} catch (error) {
  console.error('Error replacing PINGDOM_ID:', error);
  process.exit(1);
}

