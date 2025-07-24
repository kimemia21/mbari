const express = require('express');
const memberController = require('../controllers/memberController');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();
const{authorizeAdmin} = require('../middleware/authAdmin');

router.post('/register', memberController.register);
router.post('/login', memberController.login);
router.get('/profile', authenticateToken, memberController.getProfile);
router.get('/dashboard', authenticateToken, memberController.getDashboard);
router.get('/',authenticateToken,memberController.getAllUsers);
router.get('/admin/dashboard',authenticateToken,memberController.getAdminDashBoard);
router.get('/admin/members',authenticateToken,memberController.getAdminMembers);

module.exports = router;







