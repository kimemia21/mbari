const db = require('../config/database');
class MpesaPayment {
  static async save({ phone, amount, receipt, transactionDate, status }) {
    
    const sql = `
      INSERT INTO payments (phone, amount, mpesa_receipt_number, transaction_date, status)
      VALUES (?, ?, ?, ?, ?)
    `;
    const [result] = await db.execute(sql, [phone, amount, receipt, transactionDate, status]);
    return result.insertId;
  }
}

module.exports = MpesaPayment;