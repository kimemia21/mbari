
// routes/meetingFees.js
const express = require('express');
const router = express.Router();
const meetingFeeController = require('../controllers/meetingFeeController');
const { authenticateToken } = require('../middleware/auth');

router.use(authenticateToken)

router.get('/', meetingFeeController.getAll);
router.get('/:id', meetingFeeController.getById);
router.get('/meeting/:meetingId', meetingFeeController.getByMeeting);
router.post('/', meetingFeeController.create);
router.post('/bulk', meetingFeeController.bulkCreate);
router.put('/:id', meetingFeeController.update);
router.patch('/:id/status', meetingFeeController.updateStatus);
router.delete('/:id', meetingFeeController.delete);

module.exports = router;