const { MemberDeposit } = require('../models/financialModels');
const Member = require('../models/Member');
const jwt = require('jsonwebtoken');

class membercontroller {
    // Register new member
    static async register(req, res) {
        try {
            const { chama_id, name, phoneNumber, password } = req.body;
            console.log(req.body)

            // Validate required fields
            if (!chama_id || !name || !phoneNumber || !password) {
                return res.status(400).json({
                    success: false,
                    error: 'All fields are required: chama_id, name, phoneNumber, password'
                });
            }

            // Create member using the enhanced model
            const newMember = await Member.create({
                chama_id,
                name,
                phoneNumber,
                password
            });

            res.status(201).json({
                success: true,
                message: 'Member registered successfully',
                member: {
                    id: newMember.id,
                    name: newMember.name,
                    phoneNumber: newMember.phoneNumber,
                    chama_id: newMember.chama_id
                }
            });
        } catch (error) {
            console.error('Registration error:', error);

            // Handle specific errors
            if (error.message.includes('Phone number already exists')) {
                return res.status(409).json({
                    success: false,
                    error: 'Phone number already registered'
                });
            }

            if (error.message.includes('Chama not found')) {
                return res.status(404).json({
                    success: false,
                    error: 'Chama not found'
                });
            }

            if (error.message.includes('inactive chama')) {
                return res.status(400).json({
                    success: false,
                    error: 'Cannot register to inactive chama'
                });
            }

            res.status(500).json({
                success: false,
                error: 'Registration failed',
                details: error.message
            });
        }
    }

    // Enhanced Login member - returns all required fields for Flutter model
    static async login(req, res) {
        try {
            const { phoneNumber, password } = req.body;

            // Validate required fields
            if (!phoneNumber || !password) {
                return res.status(400).json({
                    success: false,
                    error: 'Phone number and password are required'
                });
            }

            // Find member by phone number
            const member = await Member.findByPhoneNumber(phoneNumber);
            if (!member) {
                return res.status(401).json({
                    success: false,
                    error: 'Invalid credentials'
                });
            }

            // Validate password
            const isValidPassword = await Member.validatePassword(member.password_hash, password);
            if (!isValidPassword) {
                return res.status(401).json({
                    success: false,
                    error: 'Invalid credentials'
                });
            }

            // Generate JWT token
            const token = jwt.sign(
                {
                    id: member.id,
                    phoneNumber: member.phoneNumber,
                    chama_id: member.chama_id
                },
                process.env.JWT_SECRET || 'your-secret-key',
                { expiresIn: '24h' }
            );


            const  deposits  = await MemberDeposit.findByMemberId(member.id, member.chama_id);

            // Return complete member data matching Flutter model requirements
            res.json({
                success: true,
                message: 'Login successful',
                token,
                member: {
                    id: member.id,
                    chama_id: member.chama_id,
                    name: member.name,
                    phoneNumber: member.phoneNumber,
                    is_active: member.is_active || 1, // Default to 1 if not set
                    joined_date: member.joined_date || member.created_at, // Use created_at if joined_date doesn't exist
                    created_at: member.created_at,
                    updated_at: member.updated_at,
                    role:member.role,
                    chama_name: member.chama_name,
                    monthly_contribution: member.monthly_contribution,
                    meeting_fee: member.meeting_fee,
                    late_fine: member.late_fine,
                    absent_fine: member.absent_fine,
                    meeting_day: member.meeting_day,

                    deposits:deposits.data
                }
            });
        } catch (error) {
            console.error('Login error:', error);
            res.status(500).json({
                success: false,
                error: 'Login failed',
                details: error.message
            });
        }
    }

    // Get member profile
    static async getProfile(req, res) {
        try {
            const memberId = req.user.id; // From auth middleware

            const member = await Member.findById(memberId);
            if (!member) {
                return res.status(404).json({
                    success: false,
                    error: 'Member not found'
                });
            }

            // Get member stats
            const stats = await Member.getMemberStats(memberId);

            res.json({
                success: true,
                member: {
                    id: member.id,
                    name: member.name,
                    phoneNumber: member.phoneNumber,
                    chama_id: member.chama_id,
                    chama_name: member.chama_name,
                    monthly_contribution: member.monthly_contribution,
                    meeting_fee: member.meeting_fee,
                    late_fine: member.late_fine,
                    absent_fine: member.absent_fine,
                    meeting_day: member.meeting_day,
                    created_at: member.created_at
                },
                stats
            });
        } catch (error) {
            console.error('Profile error:', error);
            res.status(500).json({
                success: false,
                error: 'Failed to get profile',
                details: error.message
            });
        }
    }

    // Get member dashboard data
    static async getDashboard(req, res) {
        try {
            const memberId = req.user.id; // From auth middleware

            const member = await Member.findById(memberId);
            if (!member) {
                return res.status(404).json({
                    success: false,
                    error: 'Member not found'
                });
            }

            // Get member stats
            const stats = await Member.getMemberStats(memberId);

            // Get chama members (optional - for dashboard display)
            const chamaMembers = await Member.findAll(member.chama_id);

            res.json({
                success: true,
                dashboard: {
                    member: {
                        id: member.id,
                        name: member.name,
                        chama_name: member.chama_name,
                        monthly_contribution: member.monthly_contribution
                    },
                    stats: {
                        total_contributed: stats.total_contributed,
                        total_contributions: stats.total_contributions,
                        outstanding_debt: stats.outstanding_debt
                    },
                    chama_info: {
                        id: member.chama_id,
                        name: member.chama_name,
                        total_members: chamaMembers.length,
                        meeting_day: member.meeting_day
                    }
                }
            });
        } catch (error) {
            console.error('Dashboard error:', error);
            res.status(500).json({
                success: false,
                error: 'Failed to get dashboard data',
                details: error.message
            });
        }
    }
}

module.exports = membercontroller;