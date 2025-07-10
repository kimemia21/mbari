const { MemberDeposit } = require('../models/financialModels');

const memberDepositController = {
    async getAll(req, res) {
        try {
            const deposits = await MemberDeposit.findByChamaId(req.user.chama_id);
            res.json(deposits);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    async getByMember(req, res) {
        try {
            const { memberId } = req.params;
            const result = await MemberDeposit.findByMemberId(memberId, req.user.chama_id);
          res.json({
            success: result.success,
            message: result.message,
            deposits: result.data
        });

    } catch (error) {
        res.status(500).json({
            success: false,
            message: "Failed to retrieve member deposits",
            error: error.message
        });
    }
},




    async getByChama(req, res) {
        try {
            const deposits = await MemberDeposit.findByChamaId(req.user.chama_id);
            res.json(deposits);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    async updateInvestmentShare(req, res) {
        try {
            const { memberId, investment_share } = req.body;
            const success = await MemberDeposit.updateInvestmentShare(memberId, req.user.chama_id, investment_share);
            if (!success) {
                return res.status(404).json({ error: 'Member deposit not found' });
            }
            res.json({ message: 'Investment share updated successfully' });
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    async getChamaStats(req, res) {
        try {
            const stats = await MemberDeposit.getChamaTotalDeposits(req.user.chama_id);
            res.json(stats);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }
};

module.exports = memberDepositController;