// controllers/MpesaController.js
const axios = require('axios');
const Payment = require('../models/Mpesa');
require('dotenv').config();

const getAccessToken = async () => {
  try {
    const auth = Buffer.from(
      `${process.env.MPESA_CONSUMER_KEY}:${process.env.MPESA_CONSUMER_SECRET}`
    ).toString('base64');

    console.log('Requesting access token...');

    const res = await axios.get(
      'https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials',
      {
        headers: {
          Authorization: `Basic ${auth}`,
        },
      }
    );

    if (!res.data.access_token) {
      throw new Error('No access token received');
    }

    console.log('Access token obtained successfully');
    return res.data.access_token;

  } catch (error) {
    console.error('Access Token Error:', error.response?.data || error.message);
    throw new Error('Failed to get access token: ' + (error.response?.data?.error_description || error.message));
  }
};

exports.stkPush = async (req, res) => {
  try {
    const { 
      member_id, 
      meeting_id, 
      phone_number, 
      amount, 
      payment_type = 'contribution' 
    } = req.body;

    // Validate required fields
    if (!member_id || !meeting_id || !phone_number || !amount) {
      return res.status(400).json({ 
        error: 'Missing required fields: member_id, meeting_id, phone_number, amount' 
      });
    }

    // Validate environment variables
    const requiredEnvVars = ['MPESA_CONSUMER_KEY', 'MPESA_CONSUMER_SECRET', 'MPESA_SHORTCODE', 'MPESA_PASSKEY'];
    const missingVars = requiredEnvVars.filter(varName => !process.env[varName]);
    
    if (missingVars.length > 0) {
      console.error('Missing environment variables:', missingVars);
      return res.status(500).json({ 
        error: 'Server configuration error. Missing environment variables.' 
      });
    }

    // Debug: Log environment variable values (mask sensitive data)
    console.log('Environment Check:', {
      MPESA_CONSUMER_KEY: process.env.MPESA_CONSUMER_KEY ? `${process.env.MPESA_CONSUMER_KEY.slice(0, 8)}...` : 'MISSING',
      MPESA_CONSUMER_SECRET: process.env.MPESA_CONSUMER_SECRET ? `${process.env.MPESA_CONSUMER_SECRET.slice(0, 8)}...` : 'MISSING',
      MPESA_SHORTCODE: process.env.MPESA_SHORTCODE,
      MPESA_PASSKEY: process.env.MPESA_PASSKEY ? `${process.env.MPESA_PASSKEY.slice(0, 8)}...` : 'MISSING'
    });

    console.log(`Initiating payment: Member ${member_id}, Meeting ${meeting_id}, Amount ${amount}`);

    const accessToken = await getAccessToken();

    // Generate timestamp in correct format (YYYYMMDDHHMMSS)
    const now = new Date();
    const timestamp = now.getFullYear().toString() +
                     (now.getMonth() + 1).toString().padStart(2, '0') +
                     now.getDate().toString().padStart(2, '0') +
                     now.getHours().toString().padStart(2, '0') +
                     now.getMinutes().toString().padStart(2, '0') +
                     now.getSeconds().toString().padStart(2, '0');

    // Generate password
    const password = Buffer.from(
      `${process.env.MPESA_SHORTCODE}${process.env.MPESA_PASSKEY}${timestamp}`
    ).toString('base64');

    // Format phone number (ensure it starts with 254)
    let formattedPhone = phone_number.toString().replace(/\s+/g, '');
    if (formattedPhone.startsWith('0')) {
      formattedPhone = '254' + formattedPhone.slice(1);
    } else if (formattedPhone.startsWith('+254')) {
      formattedPhone = formattedPhone.slice(1);
    } else if (!formattedPhone.startsWith('254')) {
      formattedPhone = '254' + formattedPhone;
    }

    // Validate phone number format
    if (!/^254[17]\d{8}$/.test(formattedPhone)) {
      return res.status(400).json({ 
        error: 'Invalid phone number format. Use format: 2547XXXXXXXX or 2541XXXXXXXX' 
      });
    }

    const payload = {
      BusinessShortCode: process.env.MPESA_SHORTCODE,
      Password: password,
      Timestamp: timestamp,
      TransactionType: 'CustomerPayBillOnline',
      Amount: 1, // Testing with 1 KES
      PartyA: formattedPhone,
      PartyB: process.env.MPESA_SHORTCODE,
      PhoneNumber: formattedPhone,
      CallBackURL:"https://6353e83ee1ce.ngrok-free.app/api/mpesa/callback",
      AccountReference: `CHAMA_${meeting_id}`,
      TransactionDesc: `Chama ${payment_type} payment`
    };

    // Verify all required fields are present and valid
    const requiredFields = ['BusinessShortCode', 'Password', 'Timestamp', 'Amount', 'PartyA', 'PartyB', 'PhoneNumber', 'CallBackURL'];
    const missingFields = requiredFields.filter(field => !payload[field]);
    
    if (missingFields.length > 0) {
      console.error('Missing required payload fields:', missingFields);
      return res.status(500).json({ 
        error: 'Invalid request payload', 
        missing_fields: missingFields 
      });
    }

    console.log("STK Push Payload:", {
      ...payload,
      Password: '[HIDDEN]' // Don't log sensitive data
    });

    const response = await axios.post(
      'https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest',
      payload,
      { headers: { Authorization: `Bearer ${accessToken}` } }
    );

    console.log('M-Pesa Response:', response.data);

    // If STK push initiated successfully, save payment record
    if (response.data.ResponseCode === '0') {
      const paymentData = await Payment.createPayment({
        member_id,
        meeting_id,
        amount,
        phone_number: formattedPhone,
        payment_type,
        mpesa_checkout_request_id: response.data.CheckoutRequestID
      });

      res.status(200).json({
        success: true,
        message: response.data.ResponseDescription,
        checkout_request_id: response.data.CheckoutRequestID,
        merchant_request_id: response.data.MerchantRequestID,
        reference: paymentData.reference,
        payment_id: paymentData.insertId
      });
    } else {
      console.error('STK Push failed:', response.data);
      res.status(400).json({
        success: false,
        error: response.data.ResponseDescription || 'STK Push initiation failed',
        response_code: response.data.ResponseCode
      });
    }

  } catch (error) {
    console.error('STK Push Error:', error.response?.data || error.message);
    res.status(500).json({ 
      success: false,
      error: 'STK Push initiation failed',
      details: error.response?.data || error.message
    });
  }
};
exports.stkCallback = async (req, res) => {
  try {
    // Add headers for ngrok
    res.setHeader('ngrok-skip-browser-warning', 'true');
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'POST, GET, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    
    console.log('M-Pesa Callback received:', JSON.stringify(req.body, null, 2));
    console.log('Headers:', JSON.stringify(req.headers, null, 2));
    
    // Handle preflight OPTIONS request
    if (req.method === 'OPTIONS') {
      return res.sendStatus(200);
    }

    // Check if body exists
    if (!req.body || !req.body.Body || !req.body.Body.stkCallback) {
      console.error('Invalid callback body structure:', req.body);
      return res.status(400).json({ error: 'Invalid callback structure' });
    }
    
    const body = req.body.Body.stkCallback;
    const checkoutRequestId = body.CheckoutRequestID;
    
    // Get the existing payment record
    const existingPayment = await Payment.getPaymentByCheckoutId(checkoutRequestId);
    if (!existingPayment) {
      console.log('Payment record not found for checkout ID:', checkoutRequestId);
      return res.status(200).json({ message: 'Payment record not found' });
    }

    let updateData = {
      mpesa_checkout_request_id: checkoutRequestId,
      result_code: body.ResultCode.toString(),
      result_desc: body.ResultDesc
    };

    if (body.ResultCode === 0) {
      // Payment successful
      const metadata = body.CallbackMetadata.Item;
      
      updateData.status = 'SUCCESS';
      updateData.mpesa_transaction_id = metadata.find(i => i.Name === 'MpesaReceiptNumber')?.Value;
      updateData.mpesa_receipt_number = metadata.find(i => i.Name === 'MpesaReceiptNumber')?.Value;
      
      console.log('Payment successful for member:', existingPayment.member_name);
      
    } else {
      // Payment failed or cancelled
      updateData.status = body.ResultCode === 1032 ? 'CANCELLED' : 'FAILED';
      console.log('Payment failed/cancelled:', body.ResultDesc);
    }

    // Update payment status
    const updated = await Payment.updatePaymentStatus(updateData);
    
    if (updated) {
      console.log('Payment status updated successfully');
    } else {
      console.log('Failed to update payment status');
    }

    // Return 200 with JSON response instead of just status
    res.status(200).json({ 
      message: 'Callback processed successfully',
      checkout_request_id: checkoutRequestId 
    });
    
  } catch (error) {
    console.error('Callback processing error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Query payment status (optional - for manual checking)
exports.queryPaymentStatus = async (req, res) => {
  try {
    const { checkout_request_id } = req.params;
    
    const accessToken = await getAccessToken();
    
    // Generate timestamp
    const now = new Date();
    const timestamp = now.getFullYear().toString() +
                     (now.getMonth() + 1).toString().padStart(2, '0') +
                     now.getDate().toString().padStart(2, '0') +
                     now.getHours().toString().padStart(2, '0') +
                     now.getMinutes().toString().padStart(2, '0') +
                     now.getSeconds().toString().padStart(2, '0');

    const password = Buffer.from(
      `${process.env.MPESA_SHORTCODE}${process.env.MPESA_PASSKEY}${timestamp}`
    ).toString('base64');

    const payload = {
      BusinessShortCode: process.env.MPESA_SHORTCODE,
      Password: password,
      Timestamp: timestamp,
      CheckoutRequestID: checkout_request_id
    };

    const response = await axios.post(
      'https://sandbox.safaricom.co.ke/mpesa/stkpushquery/v1/query',
      payload,
      { headers: { Authorization: `Bearer ${accessToken}` } }
    );

    res.status(200).json(response.data);
    
  } catch (error) {
    console.error('Query Error:', error.response?.data || error);
    res.status(500).json({ error: 'Query failed' });
  }
};

// Get payment details
exports.getPayment = async (req, res) => {
  try {
    const { reference } = req.params;
    
    const payment = await Payment.getPaymentByReference(reference);
    
    if (!payment) {
      return res.status(404).json({ error: 'Payment not found' });
    }
    
    res.status(200).json(payment);
    
  } catch (error) {
    console.error('Get Payment Error:', error);
    res.status(500).json({ error: 'Failed to retrieve payment' });
  }
};