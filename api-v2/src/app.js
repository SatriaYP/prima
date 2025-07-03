import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import path from 'path';
import authRoutes from './routes/auth.js';
import memberRoutes from './routes/member.js';
import officialRoutes from './routes/official.js';
import regionRoutes from './routes/regions.js';
import ocrRoutes from './routes/ocr.js';

dotenv.config();

const app = express();
const port = process.env.PORT || 4000;

app.use(cors());
app.use(express.json());

// Serve processed images under /static
app.use('/static', express.static(path.join(process.cwd(), 'public')));

app.get('/', (req, res) => {
  res.json({
    message: 'PRIMA API v2',
    version: '1.0.0',
    endpoints: {
      auth: '/api/auth',
      member: '/api/members',
      official: '/api/officials',
      regions: '/api/regions',
      ocr: '/api'
    }
  });
});

app.use('/api/auth', authRoutes);
app.use('/api/members', memberRoutes);
app.use('/api/officials', officialRoutes);
app.use('/api/regions', regionRoutes);
app.use('/api', ocrRoutes);

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({
    status: 'error',
    message: err.message || 'Internal Server Error'
  });
});

app.listen(port, () => {
  console.log(`PRIMA API v2 running on http://localhost:${port}`);
});
