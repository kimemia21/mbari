
// routes/fines.js
const express = require('express');
const router = express.Router();
const fineController = require('../controllers/fineController');

router.get('/', fineController.getAll);
router.get('/:id', fineController.getById);
router.get('/meeting/:meetingId', fineController.getByMeeting);
router.get('/member/:memberId', fineController.getByMember);
router.get('/member/:memberId/pending', fineController.getPendingByMember);
router.get('/member/:memberId/stats', fineController.getMemberStats);
router.post('/', fineController.create);
router.put('/:id', fineController.update);
router.patch('/:id/status', fineController.updateStatus);
router.delete('/:id', fineController.delete);

module.exports = router;
