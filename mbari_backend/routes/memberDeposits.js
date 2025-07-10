
// routes/memberDeposits.js
const express = require('express');
const router = express.Router();
const memberDepositController = require('../controllers/memberDepositController');
const { authenticateToken } = require('../middleware/auth');

router.get('/',authenticateToken, memberDepositController.getAll);
router.get('/member/:memberId',authenticateToken, memberDepositController.getByMember);
router.get('/chama/:chamaId',authenticateToken, memberDepositController.getByChama);
router.get('/chama/:chamaId/stats',authenticateToken, memberDepositController.getChamaStats);
router.patch('/investment-share',authenticateToken, memberDepositController.updateInvestmentShare);

module.exports = router;
