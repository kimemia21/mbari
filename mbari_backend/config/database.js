const mysql = require('mysql2/promise');
require('dotenv').config();

const dbConfig = {
    host: process.env.DB_HOST ,
    user: process.env.DB_USER ,
    password: process.env.DB_PASS ,
    database: process.env.DB_NAME ,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
};




const pool = mysql.createPool(dbConfig);

// Database initialization
const initializeDatabase = async () => {
    try {
        const connection = await pool.getConnection();
        
        // Create tables
        await connection.execute(`
            CREATE TABLE IF NOT EXISTS chamas (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(255) NOT NULL UNIQUE,
                monthly_contribution DECIMAL(10,2) NOT NULL,
                meeting_fee DECIMAL(10,2) DEFAULT 0,
                late_fine DECIMAL(10,2) DEFAULT 0,
                absent_fine DECIMAL(10,2) DEFAULT 0,
                meeting_day INT NOT NULL COMMENT '1=Monday, 2=Tuesday, etc.',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            )
        `);

        await connection.execute(`
            CREATE TABLE IF NOT EXISTS members (
                id INT AUTO_INCREMENT PRIMARY KEY,
                chama_id INT NOT NULL,
                name VARCHAR(255) NOT NULL,
                phonenumber VARCHAR(255) UNIQUE,
                phone VARCHAR(20),
                password_hash VARCHAR(255) NOT NULL,
                is_active BOOLEAN DEFAULT TRUE,
                joined_date DATE DEFAULT (CURRENT_DATE),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                FOREIGN KEY (chama_id) REFERENCES chamas(id) ON DELETE CASCADE
            )
        `);

        await connection.execute(`
            CREATE TABLE IF NOT EXISTS meetings (
                id INT AUTO_INCREMENT PRIMARY KEY,
                chama_id INT NOT NULL,
                meeting_date DATE NOT NULL,
                status ENUM('scheduled', 'completed', 'cancelled') DEFAULT 'scheduled',
                total_collected DECIMAL(10,2) DEFAULT 0,
                notes TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                FOREIGN KEY (chama_id) REFERENCES chamas(id) ON DELETE CASCADE,
                UNIQUE KEY unique_chama_meeting (chama_id, meeting_date)
            )
        `);

        await connection.execute(`
            CREATE TABLE IF NOT EXISTS contributions (
                id INT AUTO_INCREMENT PRIMARY KEY,
                member_id INT NOT NULL,
                meeting_id INT NOT NULL,
                amount DECIMAL(10,2) NOT NULL,
                contribution_type ENUM('monthly', 'meeting_fee', 'fine', 'extra') DEFAULT 'monthly',
                payment_method VARCHAR(50) DEFAULT 'cash',
                paid_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE,
                FOREIGN KEY (meeting_id) REFERENCES meetings(id) ON DELETE CASCADE
            )
        `);

        await connection.execute(`
            CREATE TABLE IF NOT EXISTS member_debts (
                id INT AUTO_INCREMENT PRIMARY KEY,
                member_id INT NOT NULL,
                meeting_id INT NOT NULL,
                debt_type ENUM('monthly_contribution', 'meeting_fee', 'late_fine', 'absent_fine') NOT NULL,
                amount DECIMAL(10,2) NOT NULL,
                is_paid BOOLEAN DEFAULT FALSE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                paid_at TIMESTAMP NULL,
                FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE,
                FOREIGN KEY (meeting_id) REFERENCES meetings(id) ON DELETE CASCADE
            )
        `);

        await connection.execute(`
            CREATE TABLE IF NOT EXISTS attendance (
                id INT AUTO_INCREMENT PRIMARY KEY,
                member_id INT NOT NULL,
                meeting_id INT NOT NULL,
                status ENUM('present', 'late', 'absent') DEFAULT 'present',
                arrival_time TIME,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE,
                FOREIGN KEY (meeting_id) REFERENCES meetings(id) ON DELETE CASCADE,
                UNIQUE KEY unique_member_meeting (member_id, meeting_id)
            )
        `);

        connection.release();
        console.log('Database initialized successfully');
    } catch (error) {
        console.error('Database initialization error:', error);
        throw error;
    }
};

module.exports = { pool, initializeDatabase };