const { pool } = require('../config/database');
const { MeetingFee, Fine, Contribution } = require('./financialModels');

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



static async meetingForToday(chamaId) {
    try {
        const now = new Date();
        const formattedDate = now.toISOString().split('T')[0]; // 'YYYY-MM-DD'

        const [rows] = await pool.execute(`
            SELECT * FROM meetings
            WHERE chama_id = ? AND DATE(meeting_date) = ?
        `, [chamaId, formattedDate]);

        if (rows.length === 0) {
            return {
                success: false,
                message: 'You have no meeting scheduled for today.',
                meeting: null
            };
        }

        // Optional: loop through and filter out ended ones if needed
        const activeMeetings = rows.filter(meeting => {
            const endTimeParts = meeting.end_time.split(':'); // 'HH:MM:SS'
            const endDateTime = new Date(meeting.meeting_date);
            endDateTime.setHours(endTimeParts[0], endTimeParts[1], endTimeParts[2] || 0);
            return now < endDateTime;
        });

        if (activeMeetings.length === 0) {
            const lastEnded = rows[rows.length - 1]; // assume last one ended most recently
            const end = lastEnded.end_time?.slice(0, 5);
            return {
         
                message: `Meeting already ended at ${end}`,
                meeting: null
            };
        }

        // Return first active meeting or all if needed
        return {
            success: true,
            message: `You have ${activeMeetings.length} meeting(s) today.`,
            meeting: activeMeetings[0] // or return full array
        };

    } catch (error) {
        console.error('Error checking today\'s meeting:', error);
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
static async getMemberMeetingStatsSingleQuery(meetingId, memberId) {
    console.log("Fetching member meeting stats for meetingId:", meetingId, "and memberId:", memberId);
    try {
        const query = `
           SELECT 
    m.id AS meeting_id,
    
    -- Attendance info
    MAX(ma.attendance_status) AS attendance_status,
    MAX(ma.arrival_time) AS arrival_time,
    
    -- Meeting fees
    COALESCE(SUM(CASE WHEN mf.amount IS NOT NULL THEN mf.amount ELSE 0 END), 0) AS total_meeting_fees_paid,
    COUNT(mf.id) AS meeting_fees_count,
    
    -- Fines
    COALESCE(SUM(CASE WHEN f.amount IS NOT NULL THEN f.amount ELSE 0 END), 0) AS total_fines,
    COUNT(f.id) AS fines_count,
    
    -- Contributions
    COALESCE(SUM(CASE WHEN c.amount IS NOT NULL THEN c.amount ELSE 0 END), 0) AS total_contributions,
    COUNT(c.id) AS contributions_count

FROM meetings m
LEFT JOIN meeting_attendance ma 
    ON m.id = ma.meeting_id AND ma.member_id =?
LEFT JOIN meeting_fees mf 
    ON m.id = mf.meeting_id AND mf.member_id = ?
LEFT JOIN fines f 
    ON m.id = f.meeting_id AND f.member_id = ?
LEFT JOIN contributions c 
    ON m.id = c.meeting_id AND c.member_id = ?
WHERE m.id = ?
GROUP BY m.id; `;
const [results] = await pool.execute(query, [memberId, memberId, memberId, memberId, meetingId]
    );

        // Handle case where no meeting is found
        if (!results || results.length === 0) {
            return {
                meetingId,
                memberId,
                attendance: {
                    status: 'Not Recorded',
                    checkInTime: null,
                    checkOutTime: null
                },
                meetingFees: {
                    totalPaid: 0,
                    count: 0
                },
                fines: {
                    totalFines: 0,
                    count: 0
                },
                contributions: {
                    totalContributions: 0,
                    count: 0
                },
                summary: {
                    totalFinancialActivity: 0,
                    outstandingFines: 0,
                    netContribution: 0
                }
            };
        }

        const stats = results[0];

        // Convert values with proper null handling
        const totalMeetingFees = parseFloat(stats.total_meeting_fees_paid) || 0;
        const totalFines = parseFloat(stats.total_fines) || 0;
        const totalContributions = parseFloat(stats.total_contributions) || 0;

        return {
            meetingId,
            memberId,
            attendance: {
                status: stats.attendance_status || 'Not Recorded',
                checkInTime: stats.arrival_time || null,
                checkOutTime: null
            },
            meetingFees: {
                totalPaid: totalMeetingFees,
                count: parseInt(stats.meeting_fees_count) || 0
            },
            fines: {
                totalFines: totalFines,
                count: parseInt(stats.fines_count) || 0
            },
            contributions: {
                totalContributions: totalContributions,
                count: parseInt(stats.contributions_count) || 0
            },
            summary: {
                totalFinancialActivity: totalMeetingFees + totalContributions,
                outstandingFines: totalFines,
                netContribution: totalContributions - totalFines
            }
        };

    } catch (error) {
        console.error('Error fetching member meeting stats (single query):', error);
        throw new Error('Failed to retrieve member meeting statistics');
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

    static async findMemberinMeeting(meetingId, memberId) {
        try {
            const [attendance] = await pool.execute(`
                SELECT * FROM meeting_attendance 
                WHERE meeting_id = ? AND member_id = ?
            `, [meetingId, memberId]);
            return attendance[0] || null;
        } catch (error) {
            console.error('Error in findMemberinMeeting:', error);
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