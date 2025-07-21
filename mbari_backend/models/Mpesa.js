
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
    
    const sql = `UPDATE payments 
                 SET status = ?, mpesa_transaction_id = ?, mpesa_receipt_number = ?, 
                 result_code = ?, result_desc = ?, completed_at = ?
                 WHERE mpesa_checkout_request_id = ?`;
    
    const [result] = await pool.execute(sql, [
      status, mpesa_transaction_id, mpesa_receipt_number, 
      result_code, result_desc, completed_at, mpesa_checkout_request_id
    ]);
    
    return result.affectedRows > 0;
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
