const { pool } = require('../config/database');

// Contributions Model
class Contribution {
    static async findAll(chamaId) {
        try {
       const [contributions] = await pool.execute(`
    SELECT c.*, m.name AS member_name, mt.meeting_date
    FROM contributions c
    LEFT JOIN members m ON c.member_id = m.id
    LEFT JOIN meetings mt ON c.meeting_id = mt.id
    WHERE c.chama_id = ?
    ORDER BY mt.meeting_date DESC, c.created_at DESC
`, [chamaId]);

            return contributions;
        } catch (error) {
            throw error;
        }
    }

    static async findById(id) {
        try {
            const [contributions] = await pool.execute(`
                SELECT c.*, m.name as member_name, mt.meeting_date
                FROM contributions c
                LEFT JOIN members m ON c.member_id = m.id
                LEFT JOIN meetings mt ON c.meeting_id = mt.id
                WHERE c.id = ?
            `, [id]);
            return contributions[0] || null;
        } catch (error) {
            throw error;
        }
    }

    static async findMemberMeetingContributions(meetingId, memberId) {
        try {
            const [contributions] = await pool.execute(`
                SELECT * FROM contributions WHERE meeting_id = ? AND member_id = ?
            `, [meetingId, memberId]);
            return contributions[0] || null;
        } catch (error) {
            throw error;
        }
    }
static async findByMeetingId(meetingId) {
    console.log("Finding contributions for meetingId:", meetingId);
        try {
            const [data] = await pool.execute(`
                SELECT c.*, m.name as member_name
                FROM contributions c
                LEFT JOIN members m ON c.member_id = m.id
                WHERE c.meeting_id = ?
                ORDER BY c.created_at DESC
            `, [meetingId]);

            // Calculate total amount
            const total = data.reduce((sum, contribution) => {
                return sum + parseFloat(contribution.amount || 0);
            }, 0);

            return {
                success: true,
                data,
                total: parseFloat(total.toFixed(2))
            };
        } catch (error) {
            throw error;
        }
    }

static async findByMeetingIdAdmin(meetingId, chamaId) {
    console.log("Finding contributions for meetingId Admin:", meetingId);

    // we have an issue when the value total is more than expected amount 

    const query = `
        SELECT 
            c.id AS chama_id,
            c.monthly_contribution,
            (SELECT COUNT(*) 
             FROM members m 
             WHERE m.chama_id = c.id) AS total_members,
             
            (SELECT COUNT(*) 
             FROM members m 
             WHERE m.chama_id = c.id) * c.monthly_contribution AS expected_contributions,

            (SELECT SUM(amount) 
             FROM contributions ctr 
             WHERE ctr.chama_id = c.id 
               AND ctr.meeting_id = ? 
               AND ctr.contribution_type = 'contribution') AS collected_contributions

        FROM chamas c
        WHERE c.id = ?;
    `;

    try {
        const [rows] = await pool.execute(query, [meetingId, chamaId]);

        if (rows.length === 0) {
            return {
                success: false,
                message: "No data found for this chama/meeting.",
                data: null
            };
        }

        const result = rows[0];
        const expected = parseFloat(result.expected_contributions || 0);
        const collected = parseFloat(result.collected_contributions || 0);
        const balance = expected - collected;

        return {
            success: true,
            data: {
                chama_id: result.chama_id,
                monthly_contribution: parseFloat(result.monthly_contribution),
                total_members: result.total_members,
                expected_contributions: expected,
                collected_contributions: collected,
                balance: parseFloat(balance.toFixed(2))
            }
        };

    } catch (error) {
        console.error("Error fetching meeting contributions:", error);
        throw error;
    }
}









    static async findByMemberId(memberId) {
        try {
            const [contributions] = await pool.execute(`
                SELECT c.*, mt.meeting_date
                FROM contributions c
                LEFT JOIN meetings mt ON c.meeting_id = mt.id
                WHERE c.member_id = ?
                ORDER BY mt.meeting_date DESC, c.created_at DESC
            `, [memberId]);
            return contributions;
        } catch (error) {
            throw error;
        }
    }

    static async create(contributionData) {
        try {
            const { 
                member_id, 
                meeting_id, 
                amount, 
                contribution_type = null,
                payment_method = 'cash', 
                paid_at = null
            } = contributionData;
            
            const [result] = await pool.execute(`
                INSERT INTO contributions (
                    member_id, 
                    meeting_id, 
                    amount, 
                    contribution_type,
                    payment_method, 
                    paid_at
                )
                VALUES (?, ?, ?, ?, ?, ?)
            `, [
                member_id, 
                meeting_id, 
                amount, 
                contribution_type,
                payment_method, 
                paid_at || new Date()
            ]);
            
            return result.insertId;
        } catch (error) {
            throw error;
        }
    }

    static async update(id, contributionData) {
        try {
            const { 
                member_id, 
                meeting_id, 
                amount, 
                contribution_type, 
                payment_method, 
                paid_at 
            } = contributionData;
            
            const [result] = await pool.execute(`
                UPDATE contributions 
                SET member_id = ?, meeting_id = ?, amount = ?, contribution_type = ?, payment_method = ?, paid_at = ?
                WHERE id = ?
            `, [member_id, meeting_id, amount, contribution_type, payment_method, paid_at, id]);
            return result.affectedRows > 0;
        } catch (error) {
            throw error;
        }
    }

    static async updatePaymentInfo(id, payment_method, paid_at = null) {
        try {
            const [result] = await pool.execute(`
                UPDATE contributions 
                SET payment_method = ?, paid_at = ?
                WHERE id = ?
            `, [payment_method, paid_at || new Date(), id]);
            return result.affectedRows > 0;
        } catch (error) {
            throw error;
        }
    }

    static async delete(id) {
        try {
            const [result] = await pool.execute('DELETE FROM contributions WHERE id = ?', [id]);
            return result.affectedRows > 0;
        } catch (error) {
            throw error;
        }
    }

    static async bulkCreate(meetingId, contributionsData) {
        try {
            const values = contributionsData.map(data => [
                data.member_id || data.memberId,
                meetingId,
                data.amount || 0,
                data.contribution_type || null,
                data.payment_method || 'cash'
            ]);
            
            const placeholders = values.map(() => '(?, ?, ?, ?, ?)').join(', ');
            const flatValues = values.flat();
            
            const [result] = await pool.execute(`
                INSERT INTO contributions (member_id, meeting_id, amount, contribution_type, payment_method)
                VALUES ${placeholders}
            `, flatValues);
            return result.affectedRows;
        } catch (error) {
            throw error;
        }
    }

    // Helper method to get contributions by type
    static async findByType(contribution_type, meetingId = null) {
        try {
            let query = `
                SELECT c.*, m.name as member_name, mt.meeting_date
                FROM contributions c
                LEFT JOIN members m ON c.member_id = m.id
                LEFT JOIN meetings mt ON c.meeting_id = mt.id
                WHERE c.contribution_type = ?
            `;
            const params = [contribution_type];
            
            if (meetingId) {
                query += ` AND c.meeting_id = ?`;
                params.push(meetingId);
            }
            
            query += ` ORDER BY mt.meeting_date DESC, c.created_at DESC`;
            
            const [contributions] = await pool.execute(query, params);
            return contributions;
        } catch (error) {
            throw error;
        }
    }

    // Helper method to get total contributions by type
    static async getTotalByType(contribution_type, meetingId = null) {
        try {
            let query = `SELECT SUM(amount) as total FROM contributions WHERE contribution_type = ?`;
            const params = [contribution_type];
            
            if (meetingId) {
                query += ` AND meeting_id = ?`;
                params.push(meetingId);
            }
            
            const [result] = await pool.execute(query, params);
            return result[0]?.total || 0;
        } catch (error) {
            throw error;
        }
    }
}

// Meeting Fees Model
class MeetingFee {
    static async findAll() {
        try {
            const [fees] = await pool.execute(`
                SELECT mf.*, m.name as member_name, mt.meeting_date, p.name as payment_method, cb.name as collected_by_name
                FROM meeting_fees mf
                LEFT JOIN members m ON mf.member_id = m.id
                LEFT JOIN meetings mt ON mf.meeting_id = mt.id
                LEFT JOIN payment_types p ON mf.payment_method_id = p.id
                LEFT JOIN members cb ON mf.collected_by = cb.id
                ORDER BY mt.meeting_date DESC
            `);
            return fees;
        } catch (error) {
            throw error;
        }
    }

  static async findMemberinMeetingfees(meetingId, memberId) {
        try {
            const [fees] = await pool.execute(`
               SELECT * FROM meeting_fees WHERE meeting_id = ? AND member_id = ?
            `, [meetingId, memberId]);
            return fees[0] || null;
        } catch (error) {
            throw error;
        }

    }


    static async findById(id) {
        try {
            const [fees] = await pool.execute(`
                SELECT mf.*, m.name as member_name, mt.meeting_date, p.name as payment_method, cb.name as collected_by_name
                FROM meeting_fees mf
                LEFT JOIN members m ON mf.member_id = m.id
                LEFT JOIN meetings mt ON mf.meeting_id = mt.id
                LEFT JOIN payment_types p ON mf.payment_method_id = p.id
                LEFT JOIN members cb ON mf.collected_by = cb.id
                WHERE mf.id = ?
            `, [id]);
            return fees[0] || null;
        } catch (error) {
            throw error;
        }
    }

    static async findByMeetingId(meetingId) {
        try {
            const [fees] = await pool.execute(`
                SELECT mf.*, m.name as member_name, p.name as payment_method
                FROM meeting_fees mf
                LEFT JOIN members m ON mf.member_id = m.id
                LEFT JOIN payment_types p ON mf.payment_method_id = p.id
                WHERE mf.meeting_id = ?
            `, [meetingId]);
            return fees;
        } catch (error) {
            throw error;
        }
    }


static async findByMeetingIdAdmin(meetingId, chamaId) {
    try {
        const [result] = await pool.execute(`
            SELECT
              (
                SELECT SUM(mf.amount)
                FROM meeting_fees mf
                WHERE mf.meeting_id = ?
                  AND mf.member_id IN (
                    SELECT a.member_id
                    FROM meeting_attendance a
                    WHERE a.meeting_id = ?
                      AND a.attendance_status IN ('present', 'late')
                  )
              ) AS total_collected,

              (
                SELECT COUNT(*)
                FROM meeting_attendance a
                WHERE a.meeting_id = ?
                  AND a.attendance_status IN ('present', 'late')
              ) AS expected_count,

              (
                SELECT c.meeting_fee
                FROM chamas c
                WHERE c.id = ?
              ) AS meeting_fee;
        `, [meetingId, meetingId, meetingId, chamaId]);

        const { total_collected = 0, expected_count = 0, meeting_fee = 0 } = result[0];

        return {
            total_collected: parseFloat(total_collected) || 0,
            expected_count,
            expected_amount: parseFloat(meeting_fee) * expected_count,
        };
    } catch (error) {
        throw error;
    }
}


 static async create(feeData) {
    console.log("feeData", feeData);

    try {
        const {
            member_id,
            meeting_id,
            amount = 100.00,
            payment_method_id = 1,
            status = 'pending',
            notes = "pending payment"
        } = feeData;

        const [result] = await pool.execute(`
            INSERT INTO meeting_fees (
                member_id,
                meeting_id,
                amount,
                payment_method_id,
                status,
                notes
            ) VALUES (?, ?, ?, ?, ?, ?)
        `, [
            member_id,
            meeting_id,
            amount,
            payment_method_id,
            status, 
            notes
        ]);

        return result.insertId;

    } catch (error) {
        console.error("Error inserting meeting fee:", error);
        throw error;
    }
}


    static async update(id, feeData) {
        try {
            const {payment_date, status, collected_by, notes } = feeData;
            const [result] = await pool.execute(`
                UPDATE meeting_fees 
                SET payment_date = ?, status = ?, collected_by = ?, notes = ?
                WHERE id = ?
            `, [payment_date, status, collected_by, notes, id]);
            return result.affectedRows > 0;
        } catch (error) {
            throw error;
        }
    }

    static async updateStatus(id, status, paymentDate = null, collectedBy = null, notes) {
        try {
            const [result] = await pool.execute(`
                UPDATE meeting_fees 
                SET status = ?, payment_date = ?, collected_by = ?,  notes=?
                WHERE id = ?
            `, [status, paymentDate, collectedBy, notes ,id]);
            return result.affectedRows > 0;
        } catch (error) {
            throw error;
        }
    }

    static async delete(id) {
        try {
            const [result] = await pool.execute('DELETE FROM meeting_fees WHERE id = ?', [id]);
            return result.affectedRows > 0;
        } catch (error) {
            throw error;
        }
    }

    static async bulkCreate(meetingId, memberIds) {
        try {
            const values = memberIds.map(memberId => [memberId, meetingId]);
            const placeholders = values.map(() => '(?, ?)').join(', ');
            const flatValues = values.flat();
            
            const [result] = await pool.execute(`
                INSERT INTO meeting_fees (member_id, meeting_id)
                VALUES ${placeholders}
            `, flatValues);
            return result.affectedRows;
        } catch (error) {
            throw error;
        }
    }
}

// Fines Model
class Fine {
    static async findAll() {
        try {
            const [fines] = await pool.execute(`
                SELECT f.*, m.name as member_name, mt.meeting_date, p.name as payment_method, pb.paybill_number
                FROM fines f
                LEFT JOIN members m ON f.member_id = m.id
                LEFT JOIN meetings mt ON f.meeting_id = mt.id
                LEFT JOIN payment_types p ON f.payment_method_id = p.id
                LEFT JOIN paybills pb ON f.paybill_id = pb.id
                ORDER BY mt.meeting_date DESC
            `);
            return fines;
        } catch (error) {
            throw error;
        }
    }

    static async findById(id) {
        try {
            const [fines] = await pool.execute(`
                SELECT f.*, m.name as member_name, mt.meeting_date, p.name as payment_method, pb.paybill_number
                FROM fines f
                LEFT JOIN members m ON f.member_id = m.id
                LEFT JOIN meetings mt ON f.meeting_id = mt.id
                LEFT JOIN payment_types p ON f.payment_method_id = p.id
                LEFT JOIN paybills pb ON f.paybill_id = pb.id
                WHERE f.id = ?
            `, [id]);
            return fines[0] || null;
        } catch (error) {
            throw error;
        }
    }

static async findByMeetingIdAdmin(meetingId) {
    try {
        const [result] = await pool.execute(`
            SELECT
                COUNT(*) AS total_fines,
                SUM(amount) AS total_fines_amount,

                SUM(CASE WHEN status = 'paid' THEN 1 ELSE 0 END) AS fines_paid_count,
                SUM(CASE WHEN status = 'paid' THEN amount ELSE 0 END) AS fines_paid_amount
            FROM fines
            WHERE meeting_id = ?
        `, [meetingId]);

        const {
            total_fines = 0,
            total_fines_amount = 0,
            fines_paid_count = 0,
            fines_paid_amount = 0
        } = result[0];

        const unpaid_fines_count = total_fines - fines_paid_count;

        return {
            total_fines,
            total_fines_amount: parseFloat(total_fines_amount) || 0,
            fines_paid_count,
            fines_paid_amount: parseFloat(fines_paid_amount) || 0,
            unpaid_fines_count
        };
    } catch (error) {
        throw error;
    }
}


    static async create(fineData) {
        try {
            const { member_id, meeting_id, fine_type, amount, payment_method_id, paybill_id, payment_reference, payment_date, status = 'pending', reason } = fineData;
            const [result] = await pool.execute(`
                INSERT INTO fines (member_id, meeting_id, fine_type, amount, payment_method_id, paybill_id, payment_reference, payment_date, status, reason)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            `, [member_id, meeting_id, fine_type, amount, payment_method_id, paybill_id, payment_reference, payment_date, status, reason]);
            return result.insertId;
        } catch (error) {
            throw error;
        }
    }
// Fine model continuation from where it was cut off
    static async update(id, fineData) {
        try {
            const { member_id, meeting_id, fine_type, amount, payment_method_id, paybill_id, payment_reference, payment_date, status, reason } = fineData;
            const [result] = await pool.execute(`
                UPDATE fines 
                SET member_id = ?, meeting_id = ?, fine_type = ?, amount = ?, payment_method_id = ?, paybill_id = ?, payment_reference = ?, payment_date = ?, status = ?, reason = ?
                WHERE id = ?
            `, [member_id, meeting_id, fine_type, amount, payment_method_id, paybill_id, payment_reference, payment_date, status, reason, id]);
            return result.affectedRows > 0;
        } catch (error) {
            throw error;
        }
    }

    static async updateStatus(id, status, paymentDate = null, paymentReference = null) {
        try {
            const [result] = await pool.execute(`
                UPDATE fines 
                SET status = ?, payment_date = ?, payment_reference = ?
                WHERE id = ?
            `, [status, paymentDate, paymentReference, id]);
            return result.affectedRows > 0;
        } catch (error) {
            throw error;
        }
    }

    static async delete(id) {
        try {
            const [result] = await pool.execute('DELETE FROM fines WHERE id = ?', [id]);
            return result.affectedRows > 0;
        } catch (error) {
            throw error;
        }
    }



    static async findMemberMeetingFines(meetingId, memberId) {
        try {
            const [fines] = await pool.execute(`
                SELECT * FROM fines WHERE meeting_id = ? AND member_id = ?
            `, [meetingId, memberId]);
            return fines[0] || null;
        } catch (error) {
            throw error;
        }
    }



    static async findByMemberId(memberId) {
        try {
            const [fines] = await pool.execute(`
                SELECT f.*, mt.meeting_date, p.name as payment_method, pb.paybill_number
                FROM fines f
                LEFT JOIN meetings mt ON f.meeting_id = mt.id
                LEFT JOIN payment_types p ON f.payment_method_id = p.id
                LEFT JOIN paybills pb ON f.paybill_id = pb.id
                WHERE f.member_id = ?
                ORDER BY mt.meeting_date DESC
            `, [memberId]);
            return fines;
        } catch (error) {
            throw error;
        }
    }

    static async createFromAttendance(meetingId, memberId, attendanceStatus) {
        try {
            const fineType = attendanceStatus === 'late' ? 'late' : 'absent';
            const amount = attendanceStatus === 'late' ? 50.00 : 100.00;
            
            // Get paybill for the meeting's chama
            const [paybills] = await pool.execute(`
                SELECT pb.id 
                FROM paybills pb
                JOIN meetings m ON m.chama_id = pb.chama_id
                WHERE m.id = ? AND pb.is_active = 1
                LIMIT 1
            `, [meetingId]);
            
            if (paybills.length === 0) {
                throw new Error('No active paybill found for this meeting');
            }
            
            const paybillId = paybills[0].id;
            const paymentMethodId = 2; // Mobile payment
            
            const [result] = await pool.execute(`
                INSERT INTO fines (member_id, meeting_id, fine_type, amount, payment_method_id, paybill_id, status, reason)
                VALUES (?, ?, ?, ?, ?, ?, 'pending', ?)
            `, [memberId, meetingId, fineType, amount, paymentMethodId, paybillId, `${fineType} attendance fine`]);
            
            return result.insertId;
        } catch (error) {
            throw error;
        }
    }

    static async bulkCreateFromAttendance(meetingId, attendanceData) {
        try {
            // Get paybill for the meeting's chama
            const [paybills] = await pool.execute(`
                SELECT pb.id 
                FROM paybills pb
                JOIN meetings m ON m.chama_id = pb.chama_id
                WHERE m.id = ? AND pb.is_active = 1
                LIMIT 1
            `, [meetingId]);
            
            if (paybills.length === 0) {
                throw new Error('No active paybill found for this meeting');
            }
            
            const paybillId = paybills[0].id;
            const paymentMethodId = 2; // Mobile payment
            
            const fineData = attendanceData
                .filter(att => att.attendance_status === 'late' || att.attendance_status === 'absent')
                .map(att => [
                    att.member_id,
                    meetingId,
                    att.attendance_status,
                    att.attendance_status === 'late' ? 50.00 : 100.00,
                    paymentMethodId,
                    paybillId,
                    'pending',
                    `${att.attendance_status} attendance fine`
                ]);
            
            if (fineData.length === 0) {
                return 0;
            }
            
            const placeholders = fineData.map(() => '(?, ?, ?, ?, ?, ?, ?, ?)').join(', ');
            const flatValues = fineData.flat();
            
            const [result] = await pool.execute(`
                INSERT INTO fines (member_id, meeting_id, fine_type, amount, payment_method_id, paybill_id, status, reason)
                VALUES ${placeholders}
            `, flatValues);
            
            return result.affectedRows;
        } catch (error) {
            throw error;
        }
    }

    static async getPendingFinesByMember(memberId) {
        try {
            const [fines] = await pool.execute(`
                SELECT f.*, mt.meeting_date, pb.paybill_number
                FROM fines f
                LEFT JOIN meetings mt ON f.meeting_id = mt.id
                LEFT JOIN paybills pb ON f.paybill_id = pb.id
                WHERE f.member_id = ? AND f.status = 'pending'
                ORDER BY mt.meeting_date ASC
            `, [memberId]);
            return fines;
        } catch (error) {
            throw error;
        }
    }

    static async getTotalFinesByMember(memberId, chamaId = null) {
        try {
            let query = `
                SELECT 
                    COUNT(*) as total_fines,
                    SUM(CASE WHEN status = 'paid' THEN amount ELSE 0 END) as total_paid,
                    SUM(CASE WHEN status = 'pending' THEN amount ELSE 0 END) as total_pending
                FROM fines f
                LEFT JOIN meetings m ON f.meeting_id = m.id
                WHERE f.member_id = ?
            `;
            
            const params = [memberId];
            
            if (chamaId) {
                query += ' AND m.chama_id = ?';
                params.push(chamaId);
            }
            
            const [result] = await pool.execute(query, params);
            return result[0];
        } catch (error) {
            throw error;
        }
    }
}

// Member Debts Model
class MemberDebt {
    static async findAll() {
        try {
            const [debts] = await pool.execute(`
                SELECT md.*, m.name as member_name, mt.meeting_date
                FROM member_debts md
                LEFT JOIN members m ON md.member_id = m.id
                LEFT JOIN meetings mt ON md.meeting_id = mt.id
                ORDER BY md.original_due_date DESC
            `);
            return debts;
        } catch (error) {
            throw error;
        }
    }

    static async findById(id) {
        try {
            const [debts] = await pool.execute(`
                SELECT md.*, m.name as member_name, mt.meeting_date
                FROM member_debts md
                LEFT JOIN members m ON md.member_id = m.id
                LEFT JOIN meetings mt ON md.meeting_id = mt.id
                WHERE md.id = ?
            `, [id]);
            return debts[0] || null;
        } catch (error) {
            throw error;
        }
    }

    static async findByMemberId(memberId) {
        try {
            const [debts] = await pool.execute(`
                SELECT md.*, mt.meeting_date
                FROM member_debts md
                LEFT JOIN meetings mt ON md.meeting_id = mt.id
                WHERE md.member_id = ?
                ORDER BY md.original_due_date DESC
            `, [memberId]);
            return debts;
        } catch (error) {
            throw error;
        }
    }

    static async findOutstandingByMember(memberId) {
        try {
            const [debts] = await pool.execute(`
                SELECT md.*, mt.meeting_date
                FROM member_debts md
                LEFT JOIN meetings mt ON md.meeting_id = mt.id
                WHERE md.member_id = ? AND md.status IN ('outstanding', 'partially_paid')
                ORDER BY md.original_due_date ASC
            `, [memberId]);
            return debts;
        } catch (error) {
            throw error;
        }
    }

    static async updatePayment(id, amountPaid, paymentReference = null) {
        try {
            const debt = await this.findById(id);
            if (!debt) {
                throw new Error('Debt not found');
            }

            const newAmountPaid = debt.amount_paid + amountPaid;
            const newStatus = newAmountPaid >= debt.amount ? 'paid' : 'partially_paid';

            const [result] = await pool.execute(`
                UPDATE member_debts 
                SET amount_paid = ?, status = ?, payment_date = ?, payment_reference = ?, updated_at = CURRENT_TIMESTAMP
                WHERE id = ?
            `, [newAmountPaid, newStatus, new Date(), paymentReference, id]);
            
            return result.affectedRows > 0;
        } catch (error) {
            throw error;
        }
    }

    static async waiveDebt(id) {
        try {
            const [result] = await pool.execute(`
                UPDATE member_debts 
                SET status = 'waived', updated_at = CURRENT_TIMESTAMP
                WHERE id = ?
            `, [id]);
            return result.affectedRows > 0;
        } catch (error) {
            throw error;
        }
    }

    static async getTotalDebtsByMember(memberId, chamaId = null) {
        try {
            let query = `
                SELECT 
                    COUNT(*) as total_debts,
                    SUM(amount) as total_amount,
                    SUM(amount_paid) as total_paid,
                    SUM(amount - amount_paid) as total_outstanding
                FROM member_debts md
                LEFT JOIN meetings m ON md.meeting_id = m.id
                WHERE md.member_id = ? AND md.status IN ('outstanding', 'partially_paid')
            `;
            
            const params = [memberId];
            
            if (chamaId) {
                query += ' AND m.chama_id = ?';
                params.push(chamaId);
            }
            
            const [result] = await pool.execute(query, params);
            return result[0];
        } catch (error) {
            throw error;
        }
    }
}

// Member Deposits Model
class MemberDeposit {
    static async findAll() {
        try {
            const [deposits] = await pool.execute(`
                SELECT md.*, m.name as member_name, c.name as chama_name
                FROM member_deposits md
                LEFT JOIN members m ON md.member_id = m.id
                LEFT JOIN chamas c ON md.chama_id = c.id
                ORDER BY md.last_updated DESC
            `);
            return deposits;
        } catch (error) {
            throw error;
        }
    }
static async findByMemberId(memberId, chamaId) {
    try {
        let query = `
            SELECT md.*, c.name AS chama_name
            FROM member_deposits md
            LEFT JOIN chamas c ON md.chama_id = c.id
            WHERE md.member_id = ?
        `;
        
        const params = [memberId];
        
        if (chamaId) {
            query += ' AND md.chama_id = ?';
            params.push(chamaId);
        }

        const [rows] = await pool.execute(query, params);

        if (rows.length === 0) {
            return {
                success: false,
                message: chamaId 
                    ? `No deposits found for member ${memberId} in this chama`
                    : `No deposits found for member ${memberId}`,
                data: [0]
            };
        }

        return {
            success: true,
            message: `Found ${rows.length} deposit${rows.length > 1 ? 's' : ''} for member ${memberId}`,
            data: rows
        };

    } catch (error) {
        throw error;
    }
}



    static async findByChamaId(chamaId) {
        try {
            const [deposits] = await pool.execute(`
                SELECT md.*, m.name as member_name
                FROM member_deposits md
                LEFT JOIN members m ON md.member_id = m.id
                WHERE md.chama_id = ?
                ORDER BY md.total_contributions DESC
            `, [chamaId]);
            return deposits;
        } catch (error) {
            throw error;
        }
    }

    static async updateInvestmentShare(memberId, chamaId, investmentShare) {
        try {
            const [result] = await pool.execute(`
                UPDATE member_deposits 
                SET investment_share = ?, last_updated = CURRENT_TIMESTAMP
                WHERE member_id = ? AND chama_id = ?
            `, [investmentShare, memberId, chamaId]);
            return result.affectedRows > 0;
        } catch (error) {
            throw error;
        }
    }

    static async getChamaTotalDeposits(chamaId) {
        try {
            const [result] = await pool.execute(`
                SELECT 
                    SUM(total_contributions) as total_contributions,
                    SUM(total_meeting_fees) as total_meeting_fees,
                    SUM(total_fines) as total_fines,
                    SUM(investment_share) as total_investment_share,
                    SUM(emergency_fund_contribution) as total_emergency_fund,
                    COUNT(*) as total_members
                FROM member_deposits
                WHERE chama_id = ?
            `, [chamaId]);
            return result[0];
        } catch (error) {
            throw error;
        }
    }
}

module.exports = {
    Contribution,
    MeetingFee,
    Fine,
    MemberDebt,
    MemberDeposit
};