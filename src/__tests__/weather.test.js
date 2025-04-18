const fetch = require('node-fetch');
jest.mock('node-fetch'); // No need to use __esModule

const { getWeather, getForecast } = require('../weather');

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

    // Properly mock the resolved value
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
