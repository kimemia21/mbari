const express = require('express');
const router = express.Router();
const mpesaController = require('../controllers/MpesaController');

router.post('/stk-push', mpesaController.stkPush);
router.post('/callback', mpesaController.stkCallback);

module.exports = router;