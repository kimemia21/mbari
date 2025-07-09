const Member = require('../models/Member');
const Debt = require('../models/Debt');
const jwt = require('jsonwebtoken');

const memberController = {
    async register(req, res) {
        try {
            const memberId = await Member.create(req.body);
            res.status(201).json({ 
                id: memberId, 
                message: 'Member registered successfully' 
            });
        } catch (error) {
            if (error.code === 'ER_DUP_ENTRY') {
                return res.status(400).json({ error: 'Phone number already exists' });
            }
            res.status(500).json({ error: 'Failed to register member' });
        }
    },

    async login(req, res) {
        try {
            const { phoneNumber, password } = req.body;
            const member = await Member.findByPhoneNumber(phoneNumber);
            
            if (!member) {
                return res.status(401).json({ error: 'Invalid credentials' });
            }
            
            const isValidPassword = await Member.validatePassword(member.password_hash, password);
            if (!isValidPassword) {
                return res.status(401).json({ error: 'Invalid credentials' });
            }
            
            const token = jwt.sign(
                { id: member.id, phoneNumber: member.phoneNumber, chama_id: member.chama_id },
                process.env.JWT_SECRET ,
                { expiresIn: '24h' }
            );
            
            delete member.password_hash;
            res.json({ token, member });
        } catch (error) {
            res.status(500).json({ error: 'Login failed' });
        }
    },

    async getProfile(req, res) {
        try {
            const member = await Member.findById(req.user.id);
            if (!member) {
                return res.status(404).json({ error: 'Member not found' });
            }
            
            delete member.password_hash;
            res.json(member);
        } catch (error) {
            res.status(500).json({ error: 'Failed to fetch profile' });
        }
    },

    async getDashboard(req, res) {
        try {
            const member = await Member.findById(req.user.id);
            const stats = await Member.getMemberStats(req.user.id);
            const debts = await Debt.findByMember(req.user.id);
            
            delete member.password_hash;
            
            res.json({
                member,
                stats,
                debts
            });
        } catch (error) {
            res.status(500).json({ error: 'Failed to fetch dashboard data' });
        }
    }
};

module.exports = memberController;
