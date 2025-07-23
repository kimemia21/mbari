
// controllers/contributionController.js
const { Contribution } = require('../models/financialModels');

const contributionController = {
    async getAll(req, res) {
        try {
            const contributions = await Contribution.findAll();
            res.json(contributions);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    async getById(req, res) {
        try {
            const contribution = await Contribution.findById(req.params.id);
            if (!contribution) {
                return res.status(404).json({ error: 'Contribution not found' });
            }
            res.json(contribution);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    async getByMeeting(req, res) {
        console.log("Fetching contributions for meeting:", req.params.meetingId);
        try {
            console.log("Fetching contributions for meeting:", req.params.meetingId);
            const contributions = await Contribution.findByMeetingId(req.params.meetingId);
            res.json(contributions);
        } catch (error) {

            res.status(500).json({ 
                 success: false,
                error: error.message ,
                message:error.message});
        }
    },

    async getByMember(req, res) {
        try {
            const contributions = await Contribution.findByMemberId(req.params.memberId);
            res.json(contributions);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    async create(req, res) {
        try {
            const id = await Contribution.create(req.body);
            res.status(201).json({ id, message: 'Contribution created successfully' });
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    async update(req, res) {
        try {
            const success = await Contribution.update(req.params.id, req.body);
            if (!success) {
                return res.status(404).json({ error: 'Contribution not found' });
            }
            res.json({ message: 'Contribution updated successfully' });
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    async updateStatus(req, res) {
        try {
            const { status, payment_date, payment_reference } = req.body;
            const success = await Contribution.updateStatus(req.params.id, status, payment_date, payment_reference);
            if (!success) {
                return res.status(404).json({ error: 'Contribution not found' });
            }
            res.json({ message: 'Contribution status updated successfully' });
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    async delete(req, res) {
        try {
            const success = await Contribution.delete(req.params.id);
            if (!success) {
                return res.status(404).json({ error: 'Contribution not found' });
            }
            res.json({ message: 'Contribution deleted successfully' });
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    async bulkCreate(req, res) {
        try {
            const { meetingId, memberIds } = req.body;
            const count = await Contribution.bulkCreate(meetingId, memberIds);
            res.status(201).json({ count, message: 'Contributions created successfully' });
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }
};


module.exports= contributionController