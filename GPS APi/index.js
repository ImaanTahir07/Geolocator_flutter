const express = require('express');
const bodyParser = require('body-parser');
const mongoose = require('mongoose');

// Connect to MongoDB
mongoose.connect('mongodb+srv://mailetkhan:JmRvO4hRGxWCv18E@cluster0.6j1ugil.mongodb.net/?retryWrites=true&w=majority', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// Create a MongoDB schema and model
const gpsSchema = new mongoose.Schema({
  latitude: { type: String, required: true },
  longitude: { type: String, required: true },
});
const GPS = mongoose.model('GPS', gpsSchema);

// Create Express.js app
const app = express();
app.use(bodyParser.json());

// API endpoint to receive GPS data and update MongoDB
app.post('/gps', async(req, res) => {
  const { latitude, longitude } = req.query;

  // Validate GPS data
  if (!latitude || !longitude) {
    return res.status(400).json({ error: 'Invalid GPS data' });
  }

  // Create a new GPS document
  const gpsData = await new GPS({ latitude, longitude });

  // Save the GPS data to MongoDB using promises
  gpsData
    .save()
    .then(() => {
      return res.status(200).json({ message: 'GPS data saved successfully' });
    })
    .catch((error) => {
      return res.status(500).json({ error: 'Failed to save GPS data' });
    });
});

// Start the server
const port = 3000;
app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
