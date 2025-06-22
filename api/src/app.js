const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

// Import routes (akan dibuat nanti)
const wilayahRoutes = require('./routes/wilayah');

// Initialize Express app
const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/wilayah', wilayahRoutes);

// Root route
app.get('/', (req, res) => {
  res.json({
    message: 'PRIMA API - Wilayah Indonesia',
    version: '1.0.0',
    endpoints: {
      provinces: '/api/wilayah/provinsi',
      regencies: '/api/wilayah/provinsi/{id}/kabupaten',
      districts: '/api/wilayah/kabupaten/{id}/kecamatan',
      villages: '/api/wilayah/kecamatan/{id}/kelurahan',
    }
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    status: 'error',
    message: 'Internal Server Error',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// Start server
app.listen(port, () => {
  console.log(`PRIMA API running on http://localhost:${port}`);
});

module.exports = app;
