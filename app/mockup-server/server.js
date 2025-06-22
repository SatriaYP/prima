const jsonServer = require('json-server');
const jwt = require('jsonwebtoken');
const cors = require('cors');
const server = jsonServer.create();
const router = jsonServer.router('./db.json');
const middlewares = jsonServer.defaults();

// Secret key for JWT signing (only for mockup purposes)
const JWT_SECRET = 'prima-id-secret-key';

// Enable CORS for all origins
server.use(cors());

// Set default middlewares (logger, static, cors and no-cache)
server.use(middlewares);

// Parse JSON request body
server.use(jsonServer.bodyParser);

// Custom routes for authentication
server.post('/login', (req, res) => {
  const { username, password } = req.body;
  
  // In a real app, you would check the password against a hashed version
  // For mockup purposes, we'll accept any password
  
  const db = router.db;
  const user = db.get('users').find({ username }).value();
  
  if (!user) {
    return res.status(401).json({ error: 'Invalid username or password' });
  }
  
  // Create a JWT token
  const token = jwt.sign(
    { 
      id: user.id, 
      role: user.role, 
      level: user.level, 
      region_code: user.region_code 
    }, 
    JWT_SECRET, 
    { expiresIn: '1h' }
  );
  
  return res.json({ 
    token,
    user: {
      id: user.id,
      username: user.username,
      email: user.email,
      role: user.role,
      level: user.level,
      region_code: user.region_code,
      is_active: user.is_active || true // Include is_active field with a default value
    }
  });
});

// Endpoint for self-registration
server.post('/register', (req, res) => {
  const { name, email, phone, nik, password } = req.body;
  
  // Validate required fields
  if (!name || !email || !phone || !nik || !password) {
    return res.status(400).json({ error: 'All fields are required' });
  }
  
  const db = router.db;
  
  // Check if user with this email or NIK already exists
  const existingUser = db.get('members').find({ email }).value() || 
                       db.get('members').find({ nik }).value();
  
  if (existingUser) {
    return res.status(409).json({ error: 'User with this email or NIK already exists' });
  }
  
  // In a real app, you would send an OTP to the phone number
  // For mockup purposes, we'll simulate OTP verification
  
  return res.json({ 
    message: 'Registration initiated. OTP sent to your phone.',
    verification_id: 'mock-verification-id'
  });
});

// Endpoint for OTP verification
server.post('/verify-otp', (req, res) => {
  const { verification_id, otp } = req.body;
  
  // In a real app, you would verify the OTP against the stored one
  // For mockup purposes, we'll accept any OTP
  
  if (!verification_id || !otp) {
    return res.status(400).json({ error: 'Verification ID and OTP are required' });
  }
  
  // For mockup, we'll accept any 6-digit OTP
  if (!/^\d{6}$/.test(otp)) {
    return res.status(400).json({ error: 'Invalid OTP format' });
  }
  
  return res.json({ 
    message: 'OTP verified successfully. You can now login.'
  });
});

// Endpoint for OCR processing
server.post('/ocr', (req, res) => {
  // In a real app, this would process an uploaded KTP image
  // For mockup purposes, we'll return mock OCR data
  
  return res.json({
    nik: '3171012345678903',
    name: 'AHMAD SUBAGYO',
    birth_place: 'JAKARTA',
    birth_date: '1988-03-15',
    gender: 'LAKI-LAKI',
    address: 'JL. KEBON JERUK NO. 123 RT 001/002',
    district: 'KEBON JERUK',
    city: 'JAKARTA BARAT',
    province: 'DKI JAKARTA'
  });
});

// Add custom routes before JSON Server router
server.use((req, res, next) => {
  // Authentication middleware would go here in a real app
  // For mockup purposes, we'll allow all requests
  next();
});

// Use default router
server.use(router);

// Start server
const PORT = 3000;
server.listen(PORT, () => {
  console.log(`JSON Server is running on port ${PORT}`);
});
