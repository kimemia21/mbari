
// models/MpesaPayment.js
const {pool} = require('../config/database');

class MpesaPayment {
  // Create initial payment record when STK push is initiated
  static async createPayment({ 
    member_id, 
    meeting_id, 
    amount, 
    phone_number, 
    payment_type = 'contribution',
    mpesa_checkout_request_id 
  }) {
    // Generate unique reference
    const reference = `PAY_${Date.now()}_${member_id}`;
    
    const sql = `
      INSERT INTO payments (
        member_id, meeting_id, amount, payment_type, phone_number, 
        mpesa_checkout_request_id, reference, status
      ) VALUES (?, ?, ?, ?, ?, ?, ?, 'PENDING')
    `;
    
    const [result] = await pool.execute(sql, [
      member_id, meeting_id, amount, payment_type, 
      phone_number, mpesa_checkout_request_id, reference
    ]);
    
    return { insertId: result.insertId, reference };
  }

  // Update payment status from M-Pesa callback
 
static async updatePaymentStatus({
    mpesa_checkout_request_id,
    status,
    mpesa_transaction_id = null,
    mpesa_receipt_number = null,
    result_code = null,
    result_desc = null
}) {
    const completed_at = status === 'SUCCESS' ? new Date() : null;
    
    // Start transaction to ensure data consistency
    const connection = await pool.getConnection();
    
    try {
        await connection.beginTransaction();
        
        // Update payment status
        const updateSql = `UPDATE payments 
                          SET status = ?, mpesa_transaction_id = ?, mpesa_receipt_number = ?,
                          result_code = ?, result_desc = ?, completed_at = ?
                          WHERE mpesa_checkout_request_id = ?`;
        
        const [updateResult] = await connection.execute(updateSql, [
            status, mpesa_transaction_id, mpesa_receipt_number,
            result_code, result_desc, completed_at, mpesa_checkout_request_id
        ]);
        
        // If payment was successful and payment record was updated, create contribution
        if (status === 'SUCCESS' && updateResult.affectedRows > 0) {
            // Get payment details to create contribution
            const [paymentRows] = await connection.execute(
                'SELECT member_id, meeting_id, amount, payment_type FROM payments WHERE mpesa_checkout_request_id = ?',
                [mpesa_checkout_request_id]
            );
            
            if (paymentRows.length > 0) {
                const payment = paymentRows[0];
                
                // Create contribution record
                const contributionSql = `INSERT INTO contributions (
                    member_id, 
                    meeting_id, 
                    amount, 
                    contribution_type,
                    payment_method, 
                    paid_at
                ) VALUES (?, ?, ?, ?, ?, ?)`;
                
                await connection.execute(contributionSql, [
                    payment.member_id,
                    payment.meeting_id,
                    payment.amount,
                    payment.payment_type,
                    'mpesa', // payment method
                    completed_at
                ]);

            }
        }
        
        await connection.commit();
        return updateResult.affectedRows > 0;
        
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}


  // Get payment by checkout request ID
  static async getPaymentByCheckoutId(checkout_request_id) {
    const sql = `
      SELECT p.*, m.name as member_name, mt.meeting_date
      FROM payments p
      JOIN members m ON p.member_id = m.id
      JOIN meetings mt ON p.meeting_id = mt.id
      WHERE p.mpesa_checkout_request_id = ?
    `;
    
    const [rows] = await pool.execute(sql, [checkout_request_id]);
    return rows[0] || null;
  }

  // Get payment by reference
  static async getPaymentByReference(reference) {
    const sql = `
      SELECT p.*, m.name as member_name, mt.meeting_date
      FROM payments p
      JOIN members m ON p.member_id = m.id
      JOIN meetings mt ON p.meeting_id = mt.id
      WHERE p.reference = ?
    `;
    
    const [rows] = await pool.execute(sql, [reference]);
    return rows[0] || null;
  }

  // Get member's payments for a specific meeting
  static async getMemberPayments(member_id, meeting_id) {
    const sql = `
      SELECT * FROM payments 
      WHERE member_id = ? AND meeting_id = ?
      ORDER BY created_at DESC
    `;
    
    const [rows] = await pool.execute(sql, [member_id, meeting_id]);
    return rows;
  }

  // Mark expired payments
  static async markExpiredPayments(timeoutMinutes = 5) {
    const sql = `
      UPDATE payments 
      SET status = 'EXPIRED' 
      WHERE status = 'PENDING' 
      AND created_at < DATE_SUB(NOW(), INTERVAL ? MINUTE)
    `;
    
    const [result] = await pool.execute(sql, [timeoutMinutes]);
    return result.affectedRows;
  }
}

module.exports = MpesaPayment;
