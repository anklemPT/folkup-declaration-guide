#!/usr/bin/env node

// Environment variables expected from process.env (no dotenv in production)
// For local testing: export JWT_SECRET=your-test-secret

const jwt = require('jsonwebtoken');

// Generate a test JWT token for API testing
function generateTestToken() {
  const payload = {
    sub: 'test-user',
    id: 'test-user-id',
    iss: 'test-issuer',
    aud: 'control-center-backend',
    iat: Math.floor(Date.now() / 1000),
    exp: Math.floor(Date.now() / 1000) + (60 * 60) // Expires in 1 hour
  };

  const secret = process.env.JWT_SECRET;

  if (!secret) {
    console.error('JWT_SECRET not configured in environment variables');
    process.exit(1);
  }

  const token = jwt.sign(payload, secret);

  console.log('Test JWT Token Generated:');
  console.log('========================');
  console.log(token);
  console.log('');
  console.log('Use this token in Authorization header as:');
  console.log(`Bearer ${token}`);
  console.log('');
  console.log('Token expires in 1 hour');

  return token;
}

if (require.main === module) {
  generateTestToken();
}

module.exports = { generateTestToken };