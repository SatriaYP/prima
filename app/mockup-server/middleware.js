const jwt = require('jsonwebtoken');

// Secret key for JWT signing (only for mockup purposes)
const JWT_SECRET = 'prima-id-secret-key';

module.exports = (req, res, next) => {
  // Skip authentication for login endpoint
  if (req.method === 'POST' && req.path === '/login') {
    return next();
  }

  // Skip authentication for self-registration endpoint
  if (req.method === 'POST' && req.path === '/register') {
    return next();
  }

  // Check for Authorization header
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    if (req.method === 'GET') {
      // Allow GET requests without authentication for easier testing
      return next();
    }
    return res.status(401).json({ error: 'Authentication required' });
  }

  const token = authHeader.split(' ')[1];
  
  try {
    // Verify the token
    const decoded = jwt.verify(token, JWT_SECRET);
    
    // Add user info to request
    req.user = decoded;
    
    // Continue with the request
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token' });
  }
};
