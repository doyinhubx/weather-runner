const fs = require('fs');
const path = require('path');

function getForecast() {
  const data = fs.readFileSync(path.join(__dirname, '../data/forecast.json'), 'utf-8');
  return JSON.parse(data).forecast;
}

module.exports = { getForecast };
