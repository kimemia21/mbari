const express = require('express');
const chamaController = require('../controllers/chamaController');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

router.get('/',authenticateToken, chamaController.getAllChamas);
router.get('/:id', chamaController.getChamaById);
router.post('/', authenticateToken, chamaController.createChama);
router.put('/:id', authenticateToken, chamaController.updateChama);
router.delete('/:id', authenticateToken, chamaController.deleteChama);

module.exports = router;