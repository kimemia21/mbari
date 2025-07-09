const app = require('./app');
const { initializeDatabase } = require('./config/database');
const os = require('os');
require('dotenv').config();

const PORT = process.env.PORT || 3000;

function getLocalIPAddress() {
    const interfaces = os.networkInterfaces();
    for (const iface of Object.values(interfaces)) {
        for (const alias of iface) {
            if (alias.family === 'IPv4' && !alias.internal) {
                return alias.address;
            }
        }
    }
    return '127.0.0.1'; // fallback
}

async function startServer() {
    try {
        await initializeDatabase();
        app.listen(PORT, () => {
            const localIP = getLocalIPAddress();
            console.log(`✅ Server running on:`);
            console.log(`🔗 Local:     http://localhost:${PORT}`);
            console.log(`🔗 Network:   http://${localIP}:${PORT}`);
        });
    } catch (error) {
        console.error('❌ Failed to start server:', error);
        process.exit(1);
    }
}

startServer();
