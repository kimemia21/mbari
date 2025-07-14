const { MemberDeposit } = require('../models/financialModels');
const Member = require('../models/Member');
const jwt = require('jsonwebtoken');

class AdminController {
  
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

module.exports = AdminController;