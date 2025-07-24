const express = require('express');
const cors = require('cors');
const { initializeDatabase } = require('./config/database');
// const csrf = require('csurf');
// const cookieParser = require('cookie-parser');

// Route imports
const chamaRoutes = require('./routes/chamaRoutes');
const memberRoutes = require('./routes/memberRoutes');
const contributionRoutes = require('./routes/contributions');
const meetingFeeRoutes = require('./routes/meetingFees');
const fineRoutes = require('./routes/fines');
const memberDebtRoutes = require('./routes/memberDebts');
const memberDepositRoutes = require('./routes/memberDeposits');
const paymentTypeRoutes = require('./routes/paymentTypes');
const paybillRoutes = require('./routes/paybills');
const meetings = require("./routes/meeting");
const mpesaRoutes = require("./routes/mpesaRoutes");





const app = express();

// Middleware
app.use(cors());
// app.use(cookieParser());
app.use(express.json());


// Routes
app.use('/api/chamas', chamaRoutes);
app.use('/api/members', memberRoutes);
app.use('/api/contributions', contributionRoutes);
app.use('/api/meeting-fees', meetingFeeRoutes);
app.use('/api/fines', fineRoutes);
app.use('/api/member-debts', memberDebtRoutes);
app.use('/api/member-deposits', memberDepositRoutes);
app.use('/api/payment-types', paymentTypeRoutes);
app.use('/api/paybills', paybillRoutes);
 app.use("/api/meeting", meetings)
app.use('/api/mpesa', mpesaRoutes);

app._router.stack.forEach(r => {
  if (r.route && r.route.path) {
    console.log(`${r.route.stack[0].method.toUpperCase()} ${r.route.path}`);
  }
});



// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ error: 'Something went wrong!' });
});

// 404 handler
app.use('*', (req, res) => {
    res.status(404).json({ error: 'Route not found' });
});

module.exports = app;