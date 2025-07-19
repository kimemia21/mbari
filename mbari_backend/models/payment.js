const { pool } = require('../config/database');

// Payment Types Model
class PaymentType {
    static async findAll() {
        try {
            const [paymentTypes] = await pool.execute(`
                SELECT * FROM payment_types WHERE is_active = TRUE
            `);
            return paymentTypes;
        } catch (error) {
            throw error;
        }
    }

    static async findById(id) {
        try {
            const [paymentTypes] = await pool.execute(`
                SELECT * FROM payment_types WHERE id = ?
            `, [id]);
            return paymentTypes[0] || null;
        } catch (error) {
            throw error;
        }
    }

    static async create(paymentTypeData) {
        try {
            const { name, description, is_active = true } = paymentTypeData;
            const [result] = await pool.execute(`
                INSERT INTO payment_types (name, description, is_active)
                VALUES (?, ?, ?)
            `, [name, description, is_active]);
            return result.insertId;
        } catch (error) {
            throw error;
        }
    }

    static async update(id, paymentTypeData) {
        try {
            const { name, description, is_active } = paymentTypeData;
            const [result] = await pool.execute(`
                UPDATE payment_types 
                SET name = ?, description = ?, is_active = ?
                WHERE id = ?
            `, [name, description, is_active, id]);
            return result.affectedRows > 0;
        } catch (error) {
            throw error;
        }
    }

    static async delete(id) {
        try {
            const [result] = await pool.execute(`
                UPDATE payment_types SET is_active = FALSE WHERE id = ?
            `, [id]);
            return result.affectedRows > 0;
        } catch (error) {
            throw error;
        }
    }
}

// Banks Model
class Bank {
    static async findAll() {
        try {
            const [banks] = await pool.execute(`
                SELECT * FROM banks WHERE is_active = TRUE
            `);
            return banks;
        } catch (error) {
            throw error;
        }
    }

    static async findById(id) {
        try {
            const [banks] = await pool.execute(`
                SELECT * FROM banks WHERE id = ?
            `, [id]);
            return banks[0] || null;
        } catch (error) {
            throw error;
        }
    }

    static async create(bankData) {
        try {
            const { name, code, is_active = true } = bankData;
            const [result] = await pool.execute(`
                INSERT INTO banks (name, code, is_active)
                VALUES (?, ?, ?)
            `, [name, code, is_active]);
            return result.insertId;
        } catch (error) {
            throw error;
        }
    }

    static async update(id, bankData) {
        try {
            const { name, code, is_active } = bankData;
            const [result] = await pool.execute(`
                UPDATE banks 
                SET name = ?, code = ?, is_active = ?
                WHERE id = ?
            `, [name, code, is_active, id]);
            return result.affectedRows > 0;
        } catch (error) {
            throw error;
        }
    }

    static async delete(id) {
        try {
            const [result] = await pool.execute(`
                UPDATE banks SET is_active = FALSE WHERE id = ?
            `, [id]);
            return result.affectedRows > 0;
        } catch (error) {
            throw error;
        }
    }
}

// Paybills Model
class Paybill {
    static async findAll() {
        try {
            const [paybills] = await pool.execute(`
                SELECT p.*, c.name as chama_name
                FROM paybills p
                LEFT JOIN chamas c ON p.chama_id = c.id
                WHERE p.is_active = TRUE
            `);
            return paybills;
        } catch (error) {
            throw error;
        }
    }

    static async findById(id) {
        try {
            const [paybills] = await pool.execute(`
                SELECT p.*, c.name as chama_name
                FROM paybills p
                LEFT JOIN chamas c ON p.chama_id = c.id
                WHERE p.id = ?
            `, [id]);
            return paybills[0] || null;
        } catch (error) {
            throw error;
        }
    }

    static async findByChamaId(chamaId) {
        try {
            const [paybills] = await pool.execute(`
                SELECT * FROM paybills 
                WHERE chama_id = ? AND is_active = TRUE
            `, [chamaId]);
            return paybills;
        } catch (error) {
            throw error;
        }
    }

    static async create(paybillData) {
        try {
            const { chama_id, provider, paybill_number, account_number, business_name, is_active = true } = paybillData;
            const [result] = await pool.execute(`
                INSERT INTO paybills (chama_id, provider, paybill_number, account_number, business_name, is_active)
                VALUES (?, ?, ?, ?, ?, ?)
            `, [chama_id, provider, paybill_number, account_number, business_name, is_active]);
            return result.insertId;
        } catch (error) {
            throw error;
        }
    }

    static async update(id, paybillData) {
        try {
            const { chama_id, provider, paybill_number, account_number, business_name, is_active } = paybillData;
            const [result] = await pool.execute(`
                UPDATE paybills 
                SET chama_id = ?, provider = ?, paybill_number = ?, account_number = ?, business_name = ?, is_active = ?
                WHERE id = ?
            `, [chama_id, provider, paybill_number, account_number, business_name, is_active, id]);
            return result.affectedRows > 0;
        } catch (error) {
            throw error;
        }
    }

    static async delete(id) {
        try {
            const [result] = await pool.execute(`
                UPDATE paybills SET is_active = FALSE WHERE id = ?
            `, [id]);
            return result.affectedRows > 0;
        } catch (error) {
            throw error;
        }
    }
}



const savePayment = (data, callback) => {
  const sql = `INSERT INTO payments (phone, amount, mpesa_receipt_number, transaction_date, status)
               VALUES (?, ?, ?, NOW(), ?)`;
  db.query(sql, [data.phone, data.amount, data.receipt, 'Success'], callback);
};


module.exports = {
    PaymentType,
    Bank,
    Paybill,
    savePayment
};