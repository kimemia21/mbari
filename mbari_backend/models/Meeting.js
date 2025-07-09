const { pool } = require('../config/database');

class Meeting {
    static async findAll(chamaId) {
        try {
            const [meetings] = await pool.execute(`
                SELECT m.*, COUNT(a.id) as attendance_count
                FROM meetings m
                LEFT JOIN attendance a ON m.id = a.meeting_id
                WHERE m.chama_id = ?
                GROUP BY m.id
                ORDER BY m.meeting_date DESC
            `, [chamaId]);
            return meetings;
        } catch (error) {
            throw error;
        }
    }

    static async findById(id) {
        try {
            const [meetings] = await pool.execute(`
                SELECT m.*, COUNT(a.id) as attendance_count
                FROM meetings m
                LEFT JOIN attendance a ON m.id = a.meeting_id
                WHERE m.id = ?
                GROUP BY m.id
            `, [id]);
            return meetings[0] || null;
        } catch (error) {
            throw error;
        }
    }

    static async getUpcoming(chamaId) {
        try {
            const [meetings] = await pool.execute(`
                SELECT * FROM meetings 
                WHERE chama_id = ? AND meeting_date >= CURRENT_DATE 
                ORDER BY meeting_date ASC
            `, [chamaId]);
            return meetings;
        } catch (error) {
            throw error;
        }
    }

    static async create(meetingData) {
        try {
            const { chama_id, meeting_date, notes } = meetingData;
            const [result] = await pool.execute(`
                INSERT INTO meetings (chama_id, meeting_date, notes)
                VALUES (?, ?, ?)
            `, [chama_id, meeting_date, notes]);
            return result.insertId;
        } catch (error) {
            throw error;
        }
    }

    static async updateStatus(id, status, totalCollected = null) {
        try {
            let query = 'UPDATE meetings SET status = ?';
            let params = [status];
            
            if (totalCollected !== null) {
                query += ', total_collected = ?';
                params.push(totalCollected);
            }
            
            query += ' WHERE id = ?';
            params.push(id);
            
            const [result] = await pool.execute(query, params);
            return result.affectedRows > 0;
        } catch (error) {
            throw error;
        }
    }
}

module.exports = Meeting;