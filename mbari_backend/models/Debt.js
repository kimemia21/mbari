const { pool } = require('../config/database');

class Debt {
    static async findByMember(memberId) {
        try {
            const [debts] = await pool.execute(`
                SELECT d.*, me.meeting_date
                FROM member_debts d
                JOIN meetings me ON d.meeting_id = me.id
                WHERE d.member_id = ? AND d.is_paid = FALSE
                ORDER BY me.meeting_date DESC
            `, [memberId]);
            return debts;
        } catch (error) {
            throw error;
        }
    }

    static async create(debtData) {
        try {
            const { member_id, meeting_id, debt_type, amount } = debtData;
            const [result] = await pool.execute(`
                INSERT INTO member_debts (member_id, meeting_id, debt_type, amount)
                VALUES (?, ?, ?, ?)
            `, [member_id, meeting_id, debt_type, amount]);
            return result.insertId;
        } catch (error) {
            throw error;
        }
    }

    static async markAsPaid(debtId) {
        try {
            const [result] = await pool.execute(`
                UPDATE member_debts 
                SET is_paid = TRUE, paid_at = CURRENT_TIMESTAMP
                WHERE id = ?
            `, [debtId]);
            return result.affectedRows > 0;
        } catch (error) {
            throw error;
        }
    }

    static async getTotalDebtForMember(memberId) {
        try {
            const [result] = await pool.execute(`
                SELECT COALESCE(SUM(amount), 0) as total_debt
                FROM member_debts
                WHERE member_id = ? AND is_paid = FALSE
            `, [memberId]);
            return result[0].total_debt;
        } catch (error) {
            throw error;
        }
    }
}

module.exports = Debt;