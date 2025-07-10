const express = require('express');
const memberController = require('../controllers/memberController');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

router.post('/register', memberController.register);
router.post('/login', memberController.login);
router.get('/profile', authenticateToken, memberController.getProfile);
router.get('/dashboard', authenticateToken, memberController.getDashboard);

module.exports = router;







