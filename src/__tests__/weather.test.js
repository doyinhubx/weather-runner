//const { getWeather, getForecast } = require('../src/weather');
const { getWeather, getForecast } = require('../weather');

const fetch = require('node-fetch');

// Use this to mock fetch in getWeather
jest.mock('node-fetch');

describe('Weather Functions', () => {
  test('getForecast returns 3 items', () => {
    const forecast = getForecast();
    expect(Array.isArray(forecast)).toBe(true);
    expect(forecast).toHaveLength(3);
  });

  test('getWeather fetches weather data for a city', async () => {
    const mockData = {
      current_condition: [
        {
          temp_C: "18",
          weatherDesc: [{ value: "Partly cloudy" }]
        }
      ]
    };

    fetch.mockResolvedValue({
      json: async () => mockData
    });

    const result = await getWeather('TestCity');
    expect(result).toEqual({
      city: 'TestCity',
      temp: "18",
      condition: "Partly cloudy"
    });
  });
});
