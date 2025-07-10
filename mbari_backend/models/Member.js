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
                       c.late_fine, c.absent_fine, c.meeting_day, c.created_at as chama_created_at,
                       c.updated_at as chama_updated_at
                FROM members m
                JOIN chamas c ON m.chama_id = c.id
                WHERE m.phoneNumber = ? AND m.is_active = TRUE
            `, [phoneNumber]);
            return members[0] || null;
        } catch (error) {
            throw error;
        }
    }

    static async findChamaById(chamaId) {
        console.log("------------chama id is",chamaId)
        try {
            const [chamas] = await pool.execute(`
                SELECT * FROM chamas WHERE id = ?
            `, [chamaId]);
            console.log("===========chama",chamas)

            return chamas[0] || null;
        } catch (error) {
            throw error;
        }
    }

    static async create(memberData) {
        try {
            console.log("----------------------registering this user",memberData);
            const { chama_id, name, phoneNumber, password } = memberData;
            
            // Validate required fields
            if (!chama_id || !name || !phoneNumber || !password) {
                throw new Error('All fields are required: chama_id, name, phoneNumber, password');
            }

            // Check if phone number already exists
            const existingMember = await this.findByPhoneNumber(phoneNumber);
            if (existingMember) {
                throw new Error('Phone number already exists in the system');
            }

            // Check if chama exists
            const chama = await this.findChamaById(chama_id);
            if (!chama) {
                throw new Error('Chama not found');
            }

            // REMOVED: Check if chama is active - this was causing the error
            // The chamas table doesn't have an is_active column
            // if (!chama.is_active) {
            //     throw new Error('Cannot add members to an inactive chama');
            // }

            // Hash password
            const password_hash = await bcrypt.hash(password, 10);
            
            // Create member
            const [result] = await pool.execute(`
                INSERT INTO members (chama_id, name, phoneNumber, password_hash)
                VALUES (?, ?, ?, ?)
            `, [chama_id, name, phoneNumber, password_hash]);
            
            return {
                id: result.insertId,
                chama_id,
                name,
                phoneNumber,
                message: 'Member created successfully'
            };
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

    // Additional utility methods for better error handling
    static async isPhoneNumberUnique(phoneNumber, excludeMemberId = null) {
        try {
            let query = 'SELECT id FROM members WHERE phoneNumber = ? AND is_active = TRUE';
            let params = [phoneNumber];
            
            if (excludeMemberId) {
                query += ' AND id != ?';
                params.push(excludeMemberId);
            }
            
            const [members] = await pool.execute(query, params);
            return members.length === 0;
        } catch (error) {
            throw error;
        }
    }

    static async getChamaDetails(chamaId) {
        try {
            // UPDATED: Removed is_active from SELECT since it doesn't exist in the table
            const [chamas] = await pool.execute(`
                SELECT id, name, monthly_contribution, meeting_fee, 
                       late_fine, absent_fine, meeting_day, created_at
                FROM chamas 
                WHERE id = ?
            `, [chamaId]);
            return chamas[0] || null;
        } catch (error) {
            throw error;
        }
    }
}

module.exports = Member;