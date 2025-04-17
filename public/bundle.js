(function(){function r(e,n,t){function o(i,f){if(!n[i]){if(!e[i]){var c="function"==typeof require&&require;if(!f&&c)return c(i,!0);if(u)return u(i,!0);var a=new Error("Cannot find module '"+i+"'");throw a.code="MODULE_NOT_FOUND",a}var p=n[i]={exports:{}};e[i][0].call(p.exports,function(r){var n=e[i][1][r];return o(n||r)},p,p.exports,r,e,n,t)}return n[i].exports}for(var u="function"==typeof require&&require,i=0;i<t.length;i++)o(t[i]);return o}return r})()({1:[function(require,module,exports){
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


// open weather without input
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


// open weather with Input
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


// // OLD Grettings - no useful as such
// //--------------------------------------------------
// window.getGreeting = async function () {
//   try {
//     const response = await fetch('/api/greet');
//     const data = await response.json();
//     document.getElementById('result').textContent = data.message;
//   } catch (err) {
//     console.error(err);
//     document.getElementById('result').textContent = 'Error fetching greeting.';
//   }
// };

// window.getTime = async function () {
//   try {
//     const response = await fetch('/api/time');
//     const data = await response.json();
//     document.getElementById('result').textContent = `Server time: ${data.time}`;
//   } catch (err) {
//     console.error(err);
//     document.getElementById('result').textContent = 'Error fetching time.';
//   }
// };





},{}]},{},[1]);
