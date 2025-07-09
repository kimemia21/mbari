const Chama = require('../models/Chama');

const chamaController = {
    async getAllChamas(req, res) {
        try {
            const chamas = await Chama.findAll();
            res.json(chamas);
        } catch (error) {
            res.status(500).json({ error: 'Failed to fetch chamas' });
        }
    },

    async getChamaById(req, res) {
        try {
            const chama = await Chama.findById(req.params.id);
            if (!chama) {
                return res.status(404).json({ error: 'Chama not found' });
            }
            res.json(chama);
        } catch (error) {
            res.status(500).json({ error: 'Failed to fetch chama' });
        }
    },

    async createChama(req, res) {
        try {
            const chamaId = await Chama.create(req.body);
            res.status(201).json({ 
                id: chamaId, 
                message: 'Chama created successfully' 
            });
        } catch (error) {
            if (error.code === 'ER_DUP_ENTRY') {
                return res.status(400).json({ error: 'Chama name already exists' });
            }
            res.status(500).json({ error: 'Failed to create chama' });
        }
    },

    async updateChama(req, res) {
        try {
            const updated = await Chama.update(req.params.id, req.body);
            if (!updated) {
                return res.status(404).json({ error: 'Chama not found' });
            }
            res.json({ message: 'Chama updated successfully' });
        } catch (error) {
            res.status(500).json({ error: 'Failed to update chama' });
        }
    },

    async deleteChama(req, res) {
        try {
            const deleted = await Chama.delete(req.params.id);
            if (!deleted) {
                return res.status(404).json({ error: 'Chama not found' });
            }
            res.json({ message: 'Chama deleted successfully' });
        } catch (error) {
            res.status(500).json({ error: 'Failed to delete chama' });
        }
    }
};


module.exports = chamaController;