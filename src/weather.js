const fetch = require('node-fetch');

async function getWeather(city = 'London') {
  const response = await fetch(`https://wttr.in/${city}?format=j1`);
  const data = await response.json();
  return {
    city,
    temp: data.current_condition[0].temp_C,
    condition: data.current_condition[0].weatherDesc[0].value
  };
}

function getForecast() {
  return [
    { day: 'Monday', high: 22, low: 15 },
    { day: 'Tuesday', high: 24, low: 16 },
    { day: 'Wednesday', high: 20, low: 14 }
  ];
}

module.exports = { getWeather, getForecast };
