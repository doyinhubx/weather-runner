const express = require('express');
const app = express();
const path = require('path');
require('dotenv').config();

// Serve static files from the 'public' folder
app.use(express.static('public'));
//app.use(express.static(path.join(__dirname, 'public')));

// Sample API endpoints
app.get('/api/greet', (req, res) => {
  res.json({ message: 'Hello from the backend!' });
});

app.get('/api/time', (req, res) => {
  res.json({ time: new Date().toISOString() });
  //res.json({ time: new Date().toLocaleString() });
});

// Start the server
const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});


