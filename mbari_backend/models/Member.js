const { pool } = require('../config/database');
const bcrypt = require('bcrypt');

class Member {
    static async findAll(chamaId) {
        try {
            const [members] = await pool.execute(`
                SELECT m.*, c.name as chama_name 
                FROM members m
                JOIN chamas c ON m.chama_id = c.id
                WHERE m.chama_id = ? AND m.is_active = TRUE
                ORDER BY m.name
            `, [chamaId]);
            return members;
        } catch (error) {
            throw error;
        }
    }

    static async findById(id) {
        try {
            const [members] = await pool.execute(`
                SELECT m.*, c.name as chama_name, c.monthly_contribution, c.meeting_fee, 
                       c.late_fine, c.absent_fine, c.meeting_day
                FROM members m
                JOIN chamas c ON m.chama_id = c.id
                WHERE m.id = ?
            `, [id]);
            return members[0] || null;
        } catch (error) {
            throw error;
        }
    }

    static async findByPhoneNumber(phoneNumber) {
        try {
            const [members] = await pool.execute(`
                SELECT m.*, c.name as chama_name, c.monthly_contribution, c.meeting_fee, 
                       c.late_fine, c.absent_fine, c.meeting_day
                FROM members m
                JOIN chamas c ON m.chama_id = c.id
                WHERE m.phoneNumber = ? AND m.is_active = TRUE
            `, [phoneNumber]);
            return members[0] || null;
        } catch (error) {
            throw error;
        }
    }

    static async create(memberData) {
        try {
            const { chama_id, name, phoneNumber, password } = memberData;
            const password_hash = await bcrypt.hash(password, 10);
            
            const [result] = await pool.execute(`
                INSERT INTO members (chama_id, name, phoneNumber, password_hash)
                VALUES (?, ?, ?, ?)
            `, [chama_id, name, phoneNumber, password_hash]);
            return result.insertId;
        } catch (error) {
            throw error;
        }
    }

    static async getMemberStats(memberId) {
        try {
            const [stats] = await pool.execute(`
                SELECT 
                    COALESCE(SUM(c.amount), 0) as total_contributed,
                    COUNT(c.id) as total_contributions,
                    COALESCE(SUM(CASE WHEN d.is_paid = FALSE THEN d.amount ELSE 0 END), 0) as outstanding_debt
                FROM members m
                LEFT JOIN contributions c ON m.id = c.member_id
                LEFT JOIN member_debts d ON m.id = d.member_id
                WHERE m.id = ?
                GROUP BY m.id
            `, [memberId]);
            return stats[0] || { total_contributed: 0, total_contributions: 0, outstanding_debt: 0 };
        } catch (error) {
            throw error;
        }
    }

    static async validatePassword(hashedPassword, password) {
        return await bcrypt.compare(password, hashedPassword);
    }
}

module.exports = Member;
