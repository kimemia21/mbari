const axios = require('axios');
const Payment = require('../models/Mpesa');
require('dotenv').config();

const getAccessToken = async () => {
  const auth = Buffer.from(
    `${process.env.MPESA_CONSUMER_KEY}:${process.env.MPESA_CONSUMER_SECRET}`
  ).toString('base64');

  const res = await axios.get(
    'https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials',
    {
      headers: {
        Authorization: `Basic ${auth}`,
      },
    }
  );

  return res.data.access_token;
};

exports.stkPush = async (req, res) => {
  try {
    const { PhoneNumber, Amount } = req.body;
    console.log(`${PhoneNumber}, ${Amount}`)

    const accessToken = await getAccessToken();

    const timestamp = new Date().toISOString().replace(/[-T:.Z]/g, '').slice(0, 14);
    const password = Buffer.from(
      `${process.env.MPESA_SHORTCODE}${process.env.MPESA_PASSKEY}${timestamp}`
    ).toString('base64');

    const payload = {
      BusinessShortCode: process.env.MPESA_SHORTCODE,
      Password: password,
      Timestamp: timestamp,
      TransactionType: 'CustomerPayBillOnline',
      Amount: Amount,
      PartyA: PhoneNumber,
      PartyB: process.env.MPESA_SHORTCODE,
      PhoneNumber: PhoneNumber,
      CallBackURL: process.env.MPESA_CALLBACK_URL,
      AccountReference: 'CHAMA',
      TransactionDesc: 'Chama Payment'
    };

    console.log("Testing ", payload)

    const response = await axios.post(
      'https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest',
      payload,
      { headers: { Authorization: `Bearer ${accessToken}` } }
    );

    res.status(200).json(response.data);
  } catch (error) {
    console.error(error.response?.data || error);
    res.status(500).json({ error: 'STK Push initiation failed' });
  }
};

exports.stkCallback = async (req, res) => {
  const body = req.body.Body.stkCallback;
  if (body.ResultCode !== 0) return res.sendStatus(200); // failed or cancelled

  const metadata = body.CallbackMetadata.Item;
  const data = {
    amount: metadata.find(i => i.Name === 'Amount')?.Value,
    phone: metadata.find(i => i.Name === 'PhoneNumber')?.Value,
    receipt: metadata.find(i => i.Name === 'MpesaReceiptNumber')?.Value,
    transactionDate: metadata.find(i => i.Name === 'TransactionDate')?.Value,
    status: 'Completed'
  };

  const dateStr = data.transactionDate.toString();
  data.transactionDate = `${dateStr.slice(0, 4)}-${dateStr.slice(4, 6)}-${dateStr.slice(6, 8)} ${dateStr.slice(8, 10)}:${dateStr.slice(10, 12)}:${dateStr.slice(12, 14)}`;

  try {
    console.log(data)
    await Payment.save(data);
    res.sendStatus(200);
  } catch (err) {
    console.error('DB Save Error:', err);
    res.sendStatus(500);
  }
};
