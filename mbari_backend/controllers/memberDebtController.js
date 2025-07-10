
// controllers/memberDebtController.js
const { MemberDebt } = require('../models/financialModels');

const memberDebtController = {
    async getAll(req, res) {
        try {
            const debts = await MemberDebt.findAll();
            res.json(debts);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    async getById(req, res) {
        try {
            const debt = await MemberDebt.findById(req.params.id);
            if (!debt) {
                return res.status(404).json({ error: 'Debt not found' });
            }
            res.json(debt);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    async getByMember(req, res) {
        try {
            const debts = await MemberDebt.findByMemberId(req.params.memberId);
            res.json(debts);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    async getOutstandingByMember(req, res) {
        try {
            const debts = await MemberDebt.findOutstandingByMember(req.params.memberId);
            res.json(debts);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    async updatePayment(req, res) {
        try {
            const { amount_paid, payment_reference } = req.body;
            const success = await MemberDebt.updatePayment(req.params.id, amount_paid, payment_reference);
            if (!success) {
                return res.status(404).json({ error: 'Debt not found' });
            }
            res.json({ message: 'Debt payment updated successfully' });
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    async waiveDebt(req, res) {
        try {
            const success = await MemberDebt.waiveDebt(req.params.id);
            if (!success) {
                return res.status(404).json({ error: 'Debt not found' });
            }
            res.json({ message: 'Debt waived successfully' });
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    async getMemberStats(req, res) {
        try {
            const { memberId } = req.params;
            const { chamaId } = req.query;
            const stats = await MemberDebt.getTotalDebtsByMember(memberId, chamaId);
            res.json(stats);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }
};

module.exports=memberDebtController;
