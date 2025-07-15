const { pool } = require('../config/database');

// Meeting Model
class Meeting {
    static async findAll() {
        try {
            const [meetings] = await pool.execute(`
       SELECT 
    m.*, 
    c.name AS chama_name,
    mem.name AS created_by_name
FROM 
    meetings m
LEFT JOIN 
    chamas c ON m.chama_id = c.id
LEFT JOIN 
    members mem ON m.created_by = mem.id
ORDER BY 
    m.meeting_date DESC;

            `);
            return meetings;
        } catch (error) {
            throw error;
        }
    }

    static async findById(id) {
        try {
            const [meetings] = await pool.execute(`
     SELECT 
    m.*, 
    c.name AS chama_name,
    mem.name AS created_by_name
FROM 
    meetings m
LEFT JOIN 
    chamas c ON m.chama_id = c.id
LEFT JOIN 
    members mem ON m.created_by = mem.id
WHERE 
    m.id = ?
ORDER BY 
    m.meeting_date DESC;

            `, [id]);
            return meetings[0] || null;
        } catch (error) {
            throw error;
        }
    }

    static async findByChamaId(chamaId) {
        try {
            const [meetings] = await pool.execute(`
             SELECT 
    m.*, 
    c.name AS chama_name,
    mem.name AS created_by_name
FROM 
    meetings m
LEFT JOIN 
    chamas c ON m.chama_id = c.id
LEFT JOIN 
    members mem ON m.created_by = mem.id
WHERE 
    m.chama_id = ?
ORDER BY 
    m.meeting_date DESC;

             
            `, [chamaId]);
            return meetings;
        } catch (error) {
            throw error;
        }
    }

    static async create(meetingData) {
        try {
            const { chama_id, meeting_date, venue, agenda, status = 'scheduled', start_time, end_time, created_by } = meetingData;

            console.log("meeting data", meetingData)
            const [result] = await pool.execute(`
                INSERT INTO meetings (chama_id, meeting_date, venue, agenda, status, start_time, end_time, created_by)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            `, [chama_id, meeting_date, venue, agenda, status, start_time, end_time, created_by]);
                   return result.insertId;
        } catch (error) {
            throw error;
        }
    }

    static async update(id, meetingData) {
        try {
            const { chama_id, meeting_date, venue, agenda, status } = meetingData;
            const [result] = await pool.execute(`
                UPDATE meetings 
                SET chama_id = ?, meeting_date = ?, venue = ?, agenda = ?, status = ?
                WHERE id = ?
            `, [chama_id, meeting_date, venue, agenda, status, id]);
            return result.affectedRows > 0;
        } catch (error) {
            throw error;
        }
    }

    static async delete(id) {
        try {
            const [result] = await pool.execute('DELETE FROM meetings WHERE id = ?', [id]);
            return result.affectedRows > 0;
        } catch (error) {
            throw error;
        }
    }

    static async getUpcomingMeetings(chamaId) {
        try {
            const [meetings] = await pool.execute(`
                SELECT * FROM meetings 
                WHERE chama_id = ? AND meeting_date >= NOW() AND status IN ('scheduled', 'in_progress')
                ORDER BY meeting_date ASC
            `, [chamaId]);
            return meetings;
        } catch (error) {
            throw error;
        }
    }

    static async getCompletedMeetings(chamaId) {
        try {
            const [meetings] = await pool.execute(`
                SELECT * FROM meetings 
                WHERE chama_id = ? AND status = 'completed'
                ORDER BY meeting_date DESC
            `, [chamaId]);
            return meetings;
        } catch (error) {
            throw error;
        }
    }
}

// Meeting Attendance Model
class MeetingAttendance {
    static async findAll() {
        try {
            const [attendance] = await pool.execute(`
                SELECT ma.*, m.meeting_date, mb.name as member_name
                FROM meeting_attendance ma
                LEFT JOIN meetings m ON ma.meeting_id = m.id
                LEFT JOIN members mb ON ma.member_id = mb.id
                ORDER BY m.meeting_date DESC
            `);
            return attendance;
        } catch (error) {
            throw error;
        }
    }

    static async findById(id) {
        try {
            const [attendance] = await pool.execute(`
                SELECT ma.*, m.meeting_date, mb.name as member_name
                FROM meeting_attendance ma
                LEFT JOIN meetings m ON ma.meeting_id = m.id
                LEFT JOIN members mb ON ma.member_id = mb.id
                WHERE ma.id = ?
            `, [id]);
            return attendance[0] || null;
        } catch (error) {
            throw error;
        }
    }

    static async findByMeetingId(meetingId) {
        try {
            const [attendance] = await pool.execute(`
                SELECT ma.*, mb.name as member_name
                FROM meeting_attendance ma
                LEFT JOIN members mb ON ma.member_id = mb.id
                WHERE ma.meeting_id = ?
            `, [meetingId]);
            return attendance;
        } catch (error) {
            throw error;
        }
    }

    static async create(attendanceData) {
        try {
            const { meeting_id, member_id, attendance_status = 'absent', arrival_time, notes } = attendanceData;
            const [result] = await pool.execute(`
                INSERT INTO meeting_attendance (meeting_id, member_id, attendance_status, arrival_time, notes)
                VALUES (?, ?, ?, ?, ?)
            `, [meeting_id, member_id, attendance_status, arrival_time, notes]);
            return result.insertId;
        } catch (error) {
            throw error;
        }
    }

    static async update(id, attendanceData) {
        try {
            const { meeting_id, member_id, attendance_status, arrival_time, notes } = attendanceData;
            const [result] = await pool.execute(`
                UPDATE meeting_attendance 
                SET meeting_id = ?, member_id = ?, attendance_status = ?, arrival_time = ?, notes = ?
                WHERE id = ?
            `, [meeting_id, member_id, attendance_status, arrival_time, notes, id]);
            return result.affectedRows > 0;
        } catch (error) {
            throw error;
        }
    }

    static async delete(id) {
        try {
            const [result] = await pool.execute('DELETE FROM meeting_attendance WHERE id = ?', [id]);
            return result.affectedRows > 0;
        } catch (error) {
            throw error;
        }
    }

    static async bulkCreate(meetingId, memberIds) {
        try {
            const values = memberIds.map(memberId => [meetingId, memberId]);
            const placeholders = values.map(() => '(?, ?)').join(', ');
            const flatValues = values.flat();
            
            const [result] = await pool.execute(`
                INSERT INTO meeting_attendance (meeting_id, member_id)
                VALUES ${placeholders}
            `, flatValues);
            return result.affectedRows;
        } catch (error) {
            throw error;
        }
    }
}

// Meeting Financials Model
class MeetingFinancials {
    static async findAll() {
        try {
            const [financials] = await pool.execute(`
                SELECT mf.*, m.meeting_date, c.name as chama_name
                FROM meeting_financials mf
                LEFT JOIN meetings m ON mf.meeting_id = m.id
                LEFT JOIN chamas c ON mf.chama_id = c.id
                ORDER BY m.meeting_date DESC
            `);
            return financials;
        } catch (error) {
            throw error;
        }
    }

    static async findById(id) {
        try {
            const [financials] = await pool.execute(`
                SELECT mf.*, m.meeting_date, c.name as chama_name
                FROM meeting_financials mf
                LEFT JOIN meetings m ON mf.meeting_id = m.id
                LEFT JOIN chamas c ON mf.chama_id = c.id
                WHERE mf.id = ?
            `, [id]);
            return financials[0] || null;
        } catch (error) {
            throw error;
        }
    }

    static async findByMeetingId(meetingId) {
        try {
            const [financials] = await pool.execute(`
                SELECT * FROM meeting_financials 
                WHERE meeting_id = ?
            `, [meetingId]);
            return financials[0] || null;
        } catch (error) {
            throw error;
        }
    }

    static async findByChamaId(chamaId) {
        try {
            const [financials] = await pool.execute(`
                SELECT mf.*, m.meeting_date
                FROM meeting_financials mf
                LEFT JOIN meetings m ON mf.meeting_id = m.id
                WHERE mf.chama_id = ?
                ORDER BY m.meeting_date DESC
            `, [chamaId]);
            return financials;
        } catch (error) {
            throw error;
        }
    }

    static async finalizeMeeting(meetingId, finalizedBy) {
        try {
            const [result] = await pool.execute(`
                UPDATE meeting_financials 
                SET is_finalized = TRUE, finalized_by = ?, finalized_at = NOW()
                WHERE meeting_id = ?
            `, [finalizedBy, meetingId]);
            return result.affectedRows > 0;
        } catch (error) {
            throw error;
        }
    }

    static async getSummaryByChama(chamaId) {
        try {
            const [summary] = await pool.execute(`
                SELECT 
                    COUNT(*) as total_meetings,
                    SUM(grand_total_collected) as total_collected,
                    SUM(total_contributions_collected) as total_contributions,
                    SUM(total_meeting_fees_collected) as total_meeting_fees,
                    SUM(total_fines_collected) as total_fines,
                    SUM(total_debts_outstanding) as total_debts,
                    AVG(members_present) as avg_attendance
                FROM meeting_financials
                WHERE chama_id = ?
            `, [chamaId]);
            return summary[0] || null;
        } catch (error) {
            throw error;
        }
    }
}

module.exports = {
    Meeting,
    MeetingAttendance,
    MeetingFinancials
};