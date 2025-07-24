const jwt = require('jsonwebtoken');
const { pool } = require('../config/database');

const authenticateToken = async (req, res, next) => {
  try {
    // Get token from header
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    console.log(`token ${token}`);
    
    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'No authentication token, access denied'
      });
    }
    
    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key');
 
    // Check if user exists and token is valid
    const query = 'SELECT * FROM members WHERE id = ?';
    const result = await pool.execute(query, [decoded.id]);
    
    if (result[0].length === 0) {
      return res.status(401).json({
        success: false,
        message: 'Member not found or inactive'
      });
    }

    
    // Add user info to request
    req.user = result[0][0];


    next();
  } catch (error) {
    console.error('Auth middleware error:', error);
    res.status(401).json({
      success: false,
      message: 'Token is invalid',
      error: error.message
    });
  }
};

module.exports = { authenticateToken };