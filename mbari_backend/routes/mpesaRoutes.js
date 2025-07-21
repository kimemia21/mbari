// routes/mpesa.js
const express = require('express');
const router = express.Router();
const mpesaController = require('../controllers/MpesaController');

// Middleware specifically for M-Pesa callback to handle ngrok and CORS
const mpesaCallbackMiddleware = (req, res, next) => {
  // Set headers for ngrok compatibility
  res.setHeader('ngrok-skip-browser-warning', 'true');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, GET, OPTIONS, PUT, DELETE');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
  res.setHeader('Content-Type', 'application/json');
  
  // Log all incoming requests for debugging
  console.log('=== M-PESA CALLBACK REQUEST ===');
  console.log('Method:', req.method);
  console.log('URL:', req.originalUrl);
  console.log('Headers:', JSON.stringify(req.headers, null, 2));
  console.log('Body:', JSON.stringify(req.body, null, 2));
  console.log('Query:', req.query);
  console.log('Params:', req.params);
  console.log('================================');
  
  // Handle preflight OPTIONS requests
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }
  
  next();
};

// Apply middleware to callback route specifically
router.use('/callback', mpesaCallbackMiddleware);

// Test endpoint to verify ngrok connectivity
router.get('/test', (req, res) => {
  res.setHeader('ngrok-skip-browser-warning', 'true');
  res.json({ 
    message: 'M-Pesa endpoints are accessible',
    timestamp: new Date().toISOString(),
    url: req.originalUrl,
    method: req.method
  });
});

// Test POST endpoint (useful for testing callback format)
router.post('/test-callback', (req, res) => {
  res.setHeader('ngrok-skip-browser-warning', 'true');
  console.log('Test callback received:', JSON.stringify(req.body, null, 2));
  res.json({ 
    message: 'Test callback received successfully',
    received_data: req.body,
    timestamp: new Date().toISOString()
  });
});

// Initiate STK push
router.post('/stk-push', mpesaController.stkPush);

// M-Pesa callback endpoint - this is where M-Pesa will send the callback
router.post('/callback', mpesaController.stkCallback);

// Query payment status
router.get('/query/:checkout_request_id', mpesaController.queryPaymentStatus);

// Get payment details
router.get('/payment/:reference', mpesaController.getPayment);

module.exports = router;