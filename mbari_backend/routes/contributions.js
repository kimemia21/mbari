
// routes/contributions.js
const express = require('express');
const router = express.Router();
const contributionController = require('../controllers/contributionController');


router.get('/', contributionController.getAll);
router.get('/:id', contributionController.getById);
router.get('/meeting/:meetingId', contributionController.getByMeeting);
router.get('/member/:memberId', contributionController.getByMember);
router.post('/', contributionController.create);
router.post('/bulk', contributionController.bulkCreate);
router.put('/:id', contributionController.update);
router.patch('/:id/status', contributionController.updateStatus);
router.delete('/:id', contributionController.delete);

module.exports = router;
