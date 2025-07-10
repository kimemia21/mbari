
// routes/paybills.js
const express = require('express');
const router = express.Router();
const { pool } = require('../config/database');

router.get('/', async (req, res) => {
    try {
        const [paybills] = await pool.execute(`
            SELECT p.*, c.name as chama_name
            FROM paybills p
            LEFT JOIN chamas c ON p.chama_id = c.id
            WHERE p.is_active = 1
        `);
        res.json(paybills);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.get('/chama/:chamaId', async (req, res) => {
    try {
        const [paybills] = await pool.execute(
            'SELECT * FROM paybills WHERE chama_id = ? AND is_active = 1',
            [req.params.chamaId]
        );
        res.json(paybills);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.post('/', async (req, res) => {
    try {
        const { chama_id, provider, paybill_number, account_number, business_name } = req.body;
        const [result] = await pool.execute(
            'INSERT INTO paybills (chama_id, provider, paybill_number, account_number, business_name) VALUES (?, ?, ?, ?, ?)',
            [chama_id, provider, paybill_number, account_number, business_name]
        );
        res.status(201).json({ id: result.insertId, message: 'Paybill created successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;