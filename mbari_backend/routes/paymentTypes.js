
// routes/paymentTypes.js
const express = require('express');
const router = express.Router();
const { pool } = require('../config/database');

router.get('/', async (req, res) => {
    try {
        const [paymentTypes] = await pool.execute('SELECT * FROM payment_types WHERE is_active = 1');
        res.json(paymentTypes);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.post('/', async (req, res) => {
    try {
        const { name, description } = req.body;
        const [result] = await pool.execute(
            'INSERT INTO payment_types (name, description) VALUES (?, ?)',
            [name, description]
        );
        res.status(201).json({ id: result.insertId, message: 'Payment type created successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;

