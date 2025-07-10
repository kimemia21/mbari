
// routes/memberDebts.js
const express = require('express');
const router = express.Router();
const memberDebtController = require('../controllers/memberDebtController');

router.get('/', memberDebtController.getAll);
router.get('/:id', memberDebtController.getById);
router.get('/member/:memberId', memberDebtController.getByMember);
router.get('/member/:memberId/outstanding', memberDebtController.getOutstandingByMember);
router.get('/member/:memberId/stats', memberDebtController.getMemberStats);
router.patch('/:id/payment', memberDebtController.updatePayment);
router.patch('/:id/waive', memberDebtController.waiveDebt);

module.exports = router;
