const { Contribution, MeetingFee, Fine } = require('../models/FinancialModels');
const { Meeting, MeetingAttendance, MeetingFinancials } = require('../models/Meeting');

// Meeting Controller
class MeetingController {
    static async getAllMeetings(req, res) {
        try {
            const meetings = await Meeting.findAll();
            res.json({
                success: true,
                data: meetings,
                message: 'Meetings retrieved successfully'
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error retrieving meetings',
                error: error.message
            });
        }
    }


   







static async getMemberMeetingStats(req, res) {
    try {
        const  {meetingId} = req.params; 
        const memberId = req.user.id; // Assuming user ID is stored in req.user
        const stats = await Meeting.getMemberMeetingStatsSingleQuery(meetingId, memberId);
        if (!stats) {   
            return res.status(404).json({
                success: false,
                message: 'No statistics found for this member in the specified meeting'
            });
        }
        res.json({
            success: true,
            data: stats,
            message: 'Member meeting statistics retrieved successfully'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error retrieving member meeting statistics',
            error: error.message

        });
    }
}



static async getMeetingForToday(req, res) {
    try {
        const chamaId = req.user.chama_id;
        const result = await Meeting.meetingForToday(chamaId);

        // Handle if meetingForToday returned no meeting or explicitly signaled failure
        if (!result || result.success === false || !result.meeting) {
            return res.status(404).json({
                success: false,
                message: result?.message || 'No meeting found for today',
                data: null
            });
        }

        const meeting = result.meeting;
        const startTime = meeting.start_time?.slice(0, 5) || 'unknown';
        const venue = meeting.venue || 'unspecified location';
        const agenda = meeting.agenda || 'No agenda provided';

        return res.json({
            success: true,
            data: meeting,
            message: `✅ You have a meeting today at ${startTime} Venue is  ${venue}. Agenda: ${agenda}`
        });

    } catch (error) {
        console.error('Error retrieving today\'s meeting:', error);
        return res.status(500).json({
            success: false,
            message: 'Error retrieving meeting',
            error: error.message
        });
    }
}




    




    static async getMeetingById(req, res) {
        try {
            const { id } = req.params;
            const meeting = await Meeting.findById(id);
            
            if (!meeting) {
                return res.status(404).json({
                    success: false,
                    message: 'Meeting not found'
                });
            }

            res.json({
                success: true,
                data: meeting,
                message: 'Meeting retrieved successfully'
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error retrieving meeting',
                error: error.message
            });
        }
    }

    static async getMeetingsByChamaId(req, res) {
          console.log("Fetching meetings");
        try {
            // console.log("Fetching meetings for chama_id:", req.user.chama_id);
            const chamaId = req.user.chama_id;
            const meetings = await Meeting.findByChamaId(chamaId);
            
            res.json({
                success: true,
                data: meetings,
                message: 'Meetings retrieved successfully'
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error retrieving meetings',
                error: error.message
            });
        }
    }

    static async createMeeting(req, res) {
        try {
            const chamaId = req.user.chama_id;
            const meetingData = { ...req.body, chama_id: chamaId };

            const meetingId = await Meeting.create(meetingData);
            
            res.status(201).json({
                success: true,
                data: { id: meetingId },
                message: 'Meeting created successfully'
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error creating meeting',
                error: error.message
            });
        }
    }

    static async updateMeeting(req, res) {
        try {
            const { id } = req.params;
            const meetingData = req.body;
            const updated = await Meeting.update(id, meetingData);
            
            if (!updated) {
                return res.status(404).json({
                    success: false,
                    message: 'Meeting not found or not updated'
                });
            }

            res.json({
                success: true,
                message: 'Meeting updated successfully'
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error updating meeting',
                error: error.message
            });
        }
    }

    static async deleteMeeting(req, res) {
        try {
            const { id } = req.params;
            const deleted = await Meeting.delete(id);
            
            if (!deleted) {
                return res.status(404).json({
                    success: false,
                    message: 'Meeting not found'
                });
            }

            res.json({
                success: true,
                message: 'Meeting deleted successfully'
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error deleting meeting',
                error: error.message
            });
        }
    }

    static async getUpcomingMeetings(req, res) {
        try {
            const chamaId = req.user.chama_id;
            const meetings = await Meeting.getUpcomingMeetings(chamaId);
            
            res.json({
                success: true,
                data: meetings,
                message: 'Upcoming meetings retrieved successfully'
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error retrieving upcoming meetings',
                error: error.message
            });
        }
    }

    static async getCompletedMeetings(req, res) {
        try {
            const chamaId = req.user.chama_id;
            const meetings = await Meeting.getCompletedMeetings(chamaId);
            
            res.json({
                success: true,
                data: meetings,
                message: 'Completed meetings retrieved successfully'
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error retrieving completed meetings',
                error: error.message
            });
        }
    }




   static async getMeetingStatsAdmin(req, res) {
    try {
        const { chama_id: chamaId } = req.user;
        const { meetingId } = req.body;

        // Early validation
        if (!meetingId) {
            return res.status(400).json({
                success: false,
                message: 'Meeting ID is required'
            });
        }

        // Execute all database queries in parallel for better performance
        const [
            moneyAtHand,
            attendance,
            contributions,
            meetingFees,
            fines
        ] = await Promise.all([
            Meeting.getMoneyInHand(chamaId, meetingId),
            MeetingAttendance.getAttendanceStatsByMeeting(meetingId, chamaId),
            Contribution.findByMeetingIdAdmin(meetingId, chamaId),
            MeetingFee.findByMeetingIdAdmin(meetingId, chamaId),
            Fine.findByMeetingIdAdmin(meetingId, chamaId)
        ]);

        // Calculate total collected amount from all sources
        const totalCollected = MeetingController.calculateTotalCollected({
            contributions,
            meetingFees,
            fines,
            moneyAtHand
        });

        // Structure response data
        const responseData = {
            moneyAtHand,
            attendance,
            contributions,
            meetingFees,
            fines,
            totalCollected
        };

        res.json({
            success: true,
            data: responseData,
            message: 'Meeting statistics retrieved successfully'
        });

    } catch (error) {
        console.error('Error in getMeetingStatsAdmin:', error);
        
        res.status(500).json({
            success: false,
            message: 'Error retrieving meeting statistics',
            error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
        });
    }
}

// Helper function to calculate total collected amount
static calculateTotalCollected({ contributions, meetingFees, fines, moneyAtHand }) {
    let total = 0;

    // Add contributions amount
    if (contributions?.data?.collected_contributions) {
        total += parseFloat(contributions.data.collected_contributions) || 0;
    }

    // Add meeting fees
    if (meetingFees?.total_collected) {
        total += parseFloat(meetingFees.total_collected) || 0;
    }

    // Add fines paid amount
    if (fines?.fines_paid_amount) {
        total += parseFloat(fines.fines_paid_amount) || 0;
    }

    // Add money at hand (if it represents additional funds)
    if (moneyAtHand) {
        total += parseFloat(moneyAtHand) || 0;
    }

    return total.toFixed(2);
}




}

// Meeting Attendance Controller
class MeetingAttendanceController {
    static async getAllAttendance(req, res) {
        try {
            const attendance = await MeetingAttendance.findAll();
            res.json({
                success: true,
                data: attendance,
                message: 'Attendance records retrieved successfully'
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error retrieving attendance records',
                error: error.message
            });
        }
    }

    static async getAttendanceById(req, res) {
        try {
            const { id } = req.params;
            const attendance = await MeetingAttendance.findById(id);
            
            if (!attendance) {
                return res.status(404).json({
                    success: false,
                    message: 'Attendance record not found'
                });
            }

            res.json({
                success: true,
                data: attendance,
                message: 'Attendance record retrieved successfully'
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error retrieving attendance record',
                error: error.message
            });
        }
    }

    static async getAttendanceByMeetingId(req, res) {
        try {
            const { meetingId } = req.params;
            const attendance = await MeetingAttendance.findByMeetingId(meetingId);
            
            res.json({
                success: true,
                data: attendance,
                message: 'Meeting attendance retrieved successfully'
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error retrieving meeting attendance',
                error: error.message
            });
        }
    }

    static async createAttendance(req, res) {
        try {
            const attendanceData = req.body;
            const attendanceId = await MeetingAttendance.create(attendanceData);
            const member_id = req.body.member_id;
            const meeting_id =req.body.meeting_id;

            const  feeData = {member_id,meeting_id};
// once attendance is confirmed the meeting fee is created
            await MeetingFee.create(feeData);
            
            res.status(201).json({
                success: true,
                data: { id: attendanceId },
                message: 'Attendance record created successfully'
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error creating attendance record',
                error: error.message
            });
        }
    }

    static async updateAttendance(req, res) {
        try {
            const { id } = req.params;
            const attendanceData = req.body;
            const updated = await MeetingAttendance.update(id, attendanceData);
            
            if (!updated) {
                return res.status(404).json({
                    success: false,
                    message: 'Attendance record not found or not updated'
                });
            }

            res.json({
                success: true,
                message: 'Attendance record updated successfully'
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error updating attendance record',
                error: error.message
            });
        }
    }

    static async deleteAttendance(req, res) {
        try {
            const { id } = req.params;
            const deleted = await MeetingAttendance.delete(id);
            
            if (!deleted) {
                return res.status(404).json({
                    success: false,
                    message: 'Attendance record not found'
                });
            }

            res.json({
                success: true,
                message: 'Attendance record deleted successfully'
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error deleting attendance record',
                error: error.message
            });
        }
    }

    static async bulkCreateAttendance(req, res) {
        try {
            const { meetingId, memberIds } = req.body;
            const created = await MeetingAttendance.bulkCreate(meetingId, memberIds);
            
            res.status(201).json({
                success: true,
                data: { recordsCreated: created },
                message: 'Attendance records created successfully'
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error creating attendance records',
                error: error.message
            });
        }
    }
}

// Meeting Financials Controller
class MeetingFinancialsController {
    static async getAllFinancials(req, res) {
        try {
            const financials = await MeetingFinancials.findAll();
            res.json({
                success: true,
                data: financials,
                message: 'Financial records retrieved successfully'
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error retrieving financial records',
                error: error.message
            });
        }
    }

    static async getFinancialById(req, res) {
        try {
            const { id } = req.params;
            const financial = await MeetingFinancials.findById(id);
            
            if (!financial) {
                return res.status(404).json({
                    success: false,
                    message: 'Financial record not found'
                });
            }

            res.json({
                success: true,
                data: financial,
                message: 'Financial record retrieved successfully'
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error retrieving financial record',
                error: error.message
            });
        }
    }

    static async getFinancialByMeetingId(req, res) {
        try {
            const { meetingId } = req.params;
            const financial = await MeetingFinancials.findByMeetingId(meetingId);
            
            if (!financial) {
                return res.status(404).json({
                    success: false,
                    message: 'Financial record not found for this meeting'
                });
            }

            res.json({
                success: true,
                data: financial,
                message: 'Meeting financial record retrieved successfully'
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error retrieving meeting financial record',
                error: error.message
            });
        }
    }

    static async getFinancialsByChamaId(req, res) {
        try {
            const chamaId = req.user.chama_id;
            const financials = await MeetingFinancials.findByChamaId(chamaId);
            
            res.json({
                success: true,
                data: financials,
                message: 'Chama financial records retrieved successfully'
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error retrieving chama financial records',
                error: error.message
            });
        }
    }

    static async finalizeMeeting(req, res) {
        try {
            const { meetingId } = req.params;
            const { finalizedBy } = req.body;
            const finalized = await MeetingFinancials.finalizeMeeting(meetingId, finalizedBy);
            
            if (!finalized) {
                return res.status(404).json({
                    success: false,
                    message: 'Meeting financial record not found or already finalized'
                });
            }

            res.json({
                success: true,
                message: 'Meeting finalized successfully'
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error finalizing meeting',
                error: error.message
            });
        }
    }

    static async getChamaSummary(req, res) {
        try {
            const chamaId = req.user.chama_id;
            const summary = await MeetingFinancials.getSummaryByChama(chamaId);
            
            if (!summary) {
                return res.status(404).json({
                    success: false,
                    message: 'No financial records found for this chama'
                });
            }

            res.json({
                success: true,
                data: summary,
                message: 'Chama financial summary retrieved successfully'
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error retrieving chama financial summary',
                error: error.message
            });
        }
    }
}

module.exports = {
    MeetingController,
    MeetingAttendanceController,
    MeetingFinancialsController
};