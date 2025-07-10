
// controllers/meetingFeeController.js
const { MeetingFee } = require('../models/financialModels');

const meetingFeeController = {
    async getAll(req, res) {
        try {
            const fees = await MeetingFee.findAll();
            res.json(fees);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    async getById(req, res) {
        try {
            const fee = await MeetingFee.findById(req.params.id);
            if (!fee) {
                return res.status(404).json({ error: 'Meeting fee not found' });
            }
            res.json(fee);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    async getByMeeting(req, res) {
        try {
            const fees = await MeetingFee.findByMeetingId(req.params.meetingId);
            res.json(fees);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    async create(req, res) {
        try {
            const id = await MeetingFee.create(req.body);
            res.status(201).json({ id, message: 'Meeting fee created successfully' });
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    async update(req, res) {
        try {
            const success = await MeetingFee.update(req.params.id, req.body);
            if (!success) {
                return res.status(404).json({ error: 'Meeting fee not found' });
            }
            res.json({ message: 'Meeting fee updated successfully' });
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    async updateStatus(req, res) {
        try {
            const { status, payment_date, collected_by } = req.body;
            const success = await MeetingFee.updateStatus(req.params.id, status, payment_date, collected_by);
            if (!success) {
                return res.status(404).json({ error: 'Meeting fee not found' });
            }
            res.json({ message: 'Meeting fee status updated successfully' });
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    async delete(req, res) {
        try {
            const success = await MeetingFee.delete(req.params.id);
            if (!success) {
                return res.status(404).json({ error: 'Meeting fee not found' });
            }
            res.json({ message: 'Meeting fee deleted successfully' });
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    async bulkCreate(req, res) {
        try {
            const { meetingId, memberIds } = req.body;
            const count = await MeetingFee.bulkCreate(meetingId, memberIds);
            res.status(201).json({ count, message: 'Meeting fees created successfully' });
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }
};


module.exports=meetingFeeController;
