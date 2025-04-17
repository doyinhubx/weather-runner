const fs = require('fs');
const path = require('path');

function getCurrentWeather() {
  const data = fs.readFileSync(path.join(__dirname, '../data/current.json'), 'utf-8');
  return JSON.parse(data);
}

module.exports = { getCurrentWeather };
