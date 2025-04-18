const fetch = require('node-fetch'); // Add this line at the top

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
    { day: 'Monday', condition: 'Sunny' },
    { day: 'Tuesday', condition: 'Rain' },
    { day: 'Wednesday', condition: 'Cloudy' }
  ];
}

module.exports = { getWeather, getForecast };
