const { pool } = require('../config/database');

class Chama {
    static async findAll() {
        try {
            const [chamas] = await pool.execute(`
                SELECT c.*, 
                       COUNT(m.id) as member_count,
                       COALESCE(SUM(co.amount), 0) as total_collected
                FROM chamas c
                LEFT JOIN members m ON c.id = m.chama_id AND m.is_active = TRUE
                LEFT JOIN meetings me ON c.id = me.chama_id
                LEFT JOIN contributions co ON me.id = co.meeting_id
                GROUP BY c.id
            `);
            return chamas;
        } catch (error) {
            throw error;
        }
    }

    static async findById(id) {
        try {
            const [chamas] = await pool.execute(`
                SELECT c.*, 
                       COUNT(m.id) as member_count,
                       COALESCE(SUM(co.amount), 0) as total_collected
                FROM chamas c
                LEFT JOIN members m ON c.id = m.chama_id AND m.is_active = TRUE
                LEFT JOIN meetings me ON c.id = me.chama_id
                LEFT JOIN contributions co ON me.id = co.meeting_id
                WHERE c.id = ?
                GROUP BY c.id
            `, [id]);
            return chamas[0] || null;
        } catch (error) {
            throw error;
        }
    }

    static async create(chamaData) {
        try {
            const { name, monthly_contribution, meeting_fee, late_fine, absent_fine, meeting_day, rules } = chamaData;
            const [result] = await pool.execute(`
                INSERT INTO chamas (name, monthly_contribution, meeting_fee, late_fine, absent_fine, meeting_day, rules)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            `, [name, monthly_contribution, meeting_fee || 0, late_fine || 0, absent_fine || 0, meeting_day, rules]);
            return result.insertId;
        } catch (error) {
            throw error;
        }
    }

    static async update(id, chamaData) {
        try {
            const { name, monthly_contribution, meeting_fee, late_fine, absent_fine, meeting_day, rules } = chamaData;
            const [result] = await pool.execute(`
                UPDATE chamas 
                SET name = ?, monthly_contribution = ?, meeting_fee = ?, late_fine = ?, absent_fine = ?, meeting_day = ?, rules = ?
                WHERE id = ?
            `, [name, monthly_contribution, meeting_fee, late_fine, absent_fine, meeting_day, rules, id]);
            return result.affectedRows > 0;
        } catch (error) {
            throw error;
        }
    }

    static async delete(id) {
        try {
            const [result] = await pool.execute('DELETE FROM chamas WHERE id = ?', [id]);
            return result.affectedRows > 0;
        } catch (error) {
            throw error;
        }
    }
}

module.exports = Chama;