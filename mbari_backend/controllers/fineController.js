
// controllers/fineController.js
const { Fine } = require('../models/FinancialModels');

const fineController = {
    async getAll(req, res) {
        try {
            const fines = await Fine.findAll();
            res.json(fines);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    async getById(req, res) {
        try {
            const fine = await Fine.findById(req.params.id);
            if (!fine) {
                return res.status(404).json({ error: 'Fine not found' });
            }
            res.json(fine);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    async getByMeeting(req, res) {
        try {
            const fines = await Fine.findByMeetingId(req.params.meetingId);
            res.json(fines);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    async getByMember(req, res) {
        try {
            const fines = await Fine.findByMemberId(req.params.memberId);
            res.json(fines);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    async create(req, res) {
        try {
            const id = await Fine.create(req.body);
            res.status(201).json({ id, message: 'Fine created successfully' });
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    async update(req, res) {
        try {
            const success = await Fine.update(req.params.id, req.body);
            if (!success) {
                return res.status(404).json({ error: 'Fine not found' });
            }
            res.json({ message: 'Fine updated successfully' });
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    async updateStatus(req, res) {
        try {
            const { status, payment_date, payment_reference } = req.body;
            const success = await Fine.updateStatus(req.params.id, status, payment_date, payment_reference);
            if (!success) {
                return res.status(404).json({ error: 'Fine not found' });
            }
            res.json({ message: 'Fine status updated successfully' });
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    async delete(req, res) {
        try {
            const success = await Fine.delete(req.params.id);
            if (!success) {
                return res.status(404).json({ error: 'Fine not found' });
            }
            res.json({ message: 'Fine deleted successfully' });
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    async getPendingByMember(req, res) {
        try {
            const fines = await Fine.getPendingFinesByMember(req.params.memberId);
            res.json(fines);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    async getMemberStats(req, res) {
        try {
            const { memberId } = req.params;
            const { chamaId } = req.query;
            const stats = await Fine.getTotalFinesByMember(memberId, chamaId);
            res.json(stats);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }
};



module.exports=fineController;