// wttr.in
//---------------------------------------------------
window.fetchCurrentWeather = async function () {
  const city = document.getElementById('city-input').value.trim() || 'London';
  const url = `https://wttr.in/${city}?format=j1`;

  try {
    const response = await fetch(url);
    const data = await response.json();

    const current = data.current_condition[0];
    const temp = current.temp_C;
    const desc = current.weatherDesc[0].value;

    document.getElementById('current-weather').textContent =
      `${city}: ${temp}°C - ${desc}`;
  } catch (error) {
    console.error('Error fetching weather:', error);
    document.getElementById('current-weather').textContent = 'Unable to fetch weather.';
  }
};


// Original
//------------------------------------------------------------------
// const data = require('./data/current.json');
// const forecast = require('./data/forecast.json');

// document.addEventListener('DOMContentLoaded', () => {
//   const currentEl = document.getElementById('current-weather');
//   if (currentEl) {
//     currentEl.textContent = `${data.temperature} - ${data.description}`;
//   }

//   const forecastList = document.getElementById('forecast-list');
//   if (forecastList && forecast.forecast && forecast.forecast.length) {
//     forecast.forecast.forEach(item => {
//       const li = document.createElement('li');
//       li.textContent = item;
//       forecastList.appendChild(li);
//     });
//   }
// });


// openweathermap.org without input
//-----------------------------------------
// window.fetchCurrentWeather = async function () {
//   const city = 'London'; // Change to dynamic input if needed
//   const apiKey = 'API_KEY';
//   const url = `https://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${apiKey}&units=metric`;

//   try {
//     const response = await fetch(url);
//     const data = await response.json();

//     document.getElementById('current-weather').textContent =
//       `${data.name}: ${data.main.temp}°C - ${data.weather[0].description}`;
//   } catch (error) {
//     console.error('Error fetching weather:', error);
//     document.getElementById('current-weather').textContent = 'Unable to fetch weather data.';
//   }
// };


// openweathermap.org with Input
//-----------------------------------------
// window.fetchCurrentWeather = async function () {
//   const city = document.getElementById('city-input').value.trim() || 'London'; // Default to London if empty
//   const apiKey = 'b8589a5a6c2c4a2cdafff90f33572a31';
//   const url = `https://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${apiKey}&units=metric`;

//   try {
//     const response = await fetch(url);
//     const data = await response.json();

//     if (data.cod !== 200) {
//       document.getElementById('current-weather').textContent = `Error: ${data.message}`;
//       return;
//     }

//     document.getElementById('current-weather').textContent =
//       `${data.name}: ${data.main.temp}°C - ${data.weather[0].description}`;
//   } catch (error) {
//     console.error('Error fetching weather:', error);
//     document.getElementById('current-weather').textContent = 'Unable to fetch weather data.';
//   }
// };








