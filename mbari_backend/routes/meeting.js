const express = require('express');
const { MeetingController, MeetingAttendanceController, MeetingFinancialsController } = require('../controllers/meetingController');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

router.use(authenticateToken);
// Meeting Routes
router.get('/', MeetingController.getAllMeetings);
router.get('/:id', MeetingController.getMeetingById);
router.get('/chama/:chamaId', MeetingController.getMeetingsByChamaId);
router.post('', MeetingController.createMeeting);
router.put('/:id', MeetingController.updateMeeting);
router.delete('/:id', MeetingController.deleteMeeting);
router.get('/chama/:chamaId/upcoming', MeetingController.getUpcomingMeetings);
router.get('/chama/:chamaId/completed', MeetingController.getCompletedMeetings);

// Meeting Attendance Routes
router.get('/attendance', MeetingAttendanceController.getAllAttendance);
router.get('/attendance/:id', MeetingAttendanceController.getAttendanceById);
router.get('/attendance/meeting/:meetingId', MeetingAttendanceController.getAttendanceByMeetingId);
router.post('/attendance', MeetingAttendanceController.createAttendance);
router.put('/attendance/:id', MeetingAttendanceController.updateAttendance);
router.delete('/attendance/:id', MeetingAttendanceController.deleteAttendance);
router.post('/attendance/bulk', MeetingAttendanceController.bulkCreateAttendance);

// Meeting Financials Routes
router.get('/financials', MeetingFinancialsController.getAllFinancials);
router.get('/financials/:id', MeetingFinancialsController.getFinancialById);
router.get('/financials/meeting/:meetingId', MeetingFinancialsController.getFinancialByMeetingId);
router.get('/financials/chama/:chamaId', MeetingFinancialsController.getFinancialsByChamaId);
router.patch('/financials/meeting/:meetingId/finalize', MeetingFinancialsController.finalizeMeeting);
router.get('/financials/chama/:chamaId/summary', MeetingFinancialsController.getChamaSummary);

module.exports = router;