const { pool } = require('../config/database');

// Contributions Model
class Contribution {
    static async findAll() {
        try {
            const [contributions] = await pool.execute(`
                SELECT c.*, m.name as member_name, mt.meeting_date, p.name as payment_method, pb.paybill_number
                FROM contributions c
                LEFT JOIN members m ON c.member_id = m.id
                LEFT JOIN meetings mt ON c.meeting_id = mt.id
                LEFT JOIN payment_types p ON c.payment_method_id = p.id
                LEFT JOIN paybills pb ON c.paybill_id = pb.id
                ORDER BY mt.meeting_date DESC
            `);
            return contributions;
        } catch (error) {
            throw error;
        }
    }

    static async findById(id) {
        try {
            const [contributions] = await pool.execute(`
                SELECT c.*, m.name as member_name, mt.meeting_date, p.name as payment_method, pb.paybill_number
                FROM contributions c
                LEFT JOIN members m ON c.member_id = m.id
                LEFT JOIN meetings mt ON c.meeting_id = mt.id
                LEFT JOIN payment_types p ON c.payment_method_id = p.id
                LEFT JOIN paybills pb ON c.paybill_id = pb.id
                WHERE c.id = ?
            `, [id]);
            return contributions[0] || null;
        } catch (error) {
            throw error;
        }
    }

    static async findByMeetingId(meetingId) {
        try {
            const [contributions] = await pool.execute(`
                SELECT c.*, m.name as member_name, p.name as payment_method
                FROM contributions c
                LEFT JOIN members m ON c.member_id = m.id
                LEFT JOIN payment_types p ON c.payment_method_id = p.id
                WHERE c.meeting_id = ?
            `, [meetingId]);
            return contributions;
        } catch (error) {
            throw error;
        }
    }

    static async findByMemberId(memberId) {
        try {
            const [contributions] = await pool.execute(`
                SELECT c.*, mt.meeting_date, p.name as payment_method
                FROM contributions c
                LEFT JOIN meetings mt ON c.meeting_id = mt.id
                LEFT JOIN payment_types p ON c.payment_method_id = p.id
                WHERE c.member_id = ?
                ORDER BY mt.meeting_date DESC
            `, [memberId]);
            return contributions;
        } catch (error) {
            throw error;
        }
    }

    static async create(contributionData) {
        try {
            const { member_id, meeting_id, amount = 500.00, payment_method_id, paybill_id, payment_reference, payment_date, status = 'pending' } = contributionData;
            const [result] = await pool.execute(`
                INSERT INTO contributions (member_id, meeting_id, amount, payment_method_id, paybill_id, payment_reference, payment_date, status)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            `, [member_id, meeting_id, amount, payment_method_id, paybill_id, payment_reference, payment_date, status]);
            return result.insertId;
        } catch (error) {
            throw error;
        }
    }

    static async update(id, contributionData) {
        try {
            const { member_id, meeting_id, amount, payment_method_id, paybill_id, payment_reference, payment_date, status } = contributionData;
            const [result] = await pool.execute(`
                UPDATE contributions 
                SET member_id = ?, meeting_id = ?, amount = ?, payment_method_id = ?, paybill_id = ?, payment_reference = ?, payment_date = ?, status = ?
                WHERE id = ?
            `, [member_id, meeting_id, amount, payment_method_id, paybill_id, payment_reference, payment_date, status, id]);
            return result.affectedRows > 0;
        } catch (error) {
            throw error;
        }
    }

    static async updateStatus(id, status, paymentDate = null, paymentReference = null) {
        try {
            const [result] = await pool.execute(`
                UPDATE contributions 
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
            const [result] = await pool.execute('DELETE FROM contributions WHERE id = ?', [id]);
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
                INSERT INTO contributions (member_id, meeting_id)
                VALUES ${placeholders}
            `, flatValues);
            return result.affectedRows;
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

    static async create(feeData) {
        try {
            const { member_id, meeting_id, amount = 100.00, payment_method_id, payment_date, status = 'pending', collected_by, notes } = feeData;
            const [result] = await pool.execute(`
                INSERT INTO meeting_fees (member_id, meeting_id, amount, payment_method_id, payment_date, status, collected_by, notes)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            `, [member_id, meeting_id, amount, payment_method_id, payment_date, status, collected_by, notes]);
            return result.insertId;
        } catch (error) {
            throw error;
        }
    }

    static async update(id, feeData) {
        try {
            const { member_id, meeting_id, amount, payment_method_id, payment_date, status, collected_by, notes } = feeData;
            const [result] = await pool.execute(`
                UPDATE meeting_fees 
                SET member_id = ?, meeting_id = ?, amount = ?, payment_method_id = ?, payment_date = ?, status = ?, collected_by = ?, notes = ?
                WHERE id = ?
            `, [member_id, meeting_id, amount, payment_method_id, payment_date, status, collected_by, notes, id]);
            return result.affectedRows > 0;
        } catch (error) {
            throw error;
        }
    }

    static async updateStatus(id, status, paymentDate = null, collectedBy = null) {
        try {
            const [result] = await pool.execute(`
                UPDATE meeting_fees 
                SET status = ?, payment_date = ?, collected_by = ?
                WHERE id = ?
            `, [status, paymentDate, collectedBy, id]);
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

    static async findByMeetingId(meetingId) {
        try {
            const [fines] = await pool.execute(`
                SELECT f.*, m.name as member_name, p.name as payment_method
                FROM fines f
                LEFT JOIN members m ON f.member_id = m.id
                LEFT JOIN payment_types p ON f.payment_method_id = p.id
                WHERE f.meeting_id = ?
            `, [meetingId]);
            return fines;
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