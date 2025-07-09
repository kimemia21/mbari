const { pool } = require('../config/database');

class Contribution {
    static async findAll(meetingId) {
        try {
            const [contributions] = await pool.execute(`
                SELECT c.*, m.name as member_name
                FROM contributions c
                JOIN members m ON c.member_id = m.id
                WHERE c.meeting_id = ?
                ORDER BY c.paid_at DESC
            `, [meetingId]);
            return contributions;
        } catch (error) {
            throw error;
        }
    }

    static async findByMember(memberId) {
        try {
            const [contributions] = await pool.execute(`
                SELECT c.*, me.meeting_date
                FROM contributions c
                JOIN meetings me ON c.meeting_id = me.id
                WHERE c.member_id = ?
                ORDER BY c.paid_at DESC
            `, [memberId]);
            return contributions;
        } catch (error) {
            throw error;
        }
    }

    static async create(contributionData) {
        try {
            const { member_id, meeting_id, amount, contribution_type, payment_method } = contributionData;
            const [result] = await pool.execute(`
                INSERT INTO contributions (member_id, meeting_id, amount, contribution_type, payment_method)
                VALUES (?, ?, ?, ?, ?)
            `, [member_id, meeting_id, amount, contribution_type, payment_method]);
            return result.insertId;
        } catch (error) {
            throw error;
        }
    }

    static async getTotalForMeeting(meetingId) {
        try {
            const [result] = await pool.execute(`
                SELECT COALESCE(SUM(amount), 0) as total
                FROM contributions
                WHERE meeting_id = ?
            `, [meetingId]);
            return result[0].total;
        } catch (error) {
            throw error;
        }
    }
}

module.exports = Contribution;