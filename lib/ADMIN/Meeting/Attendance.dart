import 'package:flutter/material.dart';
import 'package:mbari/ADMIN/Meeting/Widgets.dart';
import 'package:mbari/data/models/AttendanceModel.dart';
import 'package:mbari/data/models/Member.dart';
import 'package:mbari/data/services/globalFetch.dart';
import 'package:mbari/core/constants/constants.dart';
import 'package:mbari/core/utils/Alerts.dart';
import 'package:mbari/widgets/MeetingLoadingWidget.dart';

class AttendanceTable extends StatefulWidget {
  @override
  State<AttendanceTable> createState() => _AttendanceTableState();
}

class _AttendanceTableState extends State<AttendanceTable> {
  late Future<List<AttendanceRecord>> _attendanceRecordsFuture;
  late Future<List<Member>> _membersFuture;
  bool isAttendanceOpen = false;
  bool isMeetingPast = false;
  String statusMessage = '';

  @override
  void initState() {
    super.initState();
    _attendanceRecordsFuture = fetchAttendance();
    _membersFuture = _fetchMembers();
    _checkAttendanceStatus();
  }

  // Fetch attendance records for the meeting
  Future<List<AttendanceRecord>> fetchAttendance() async {
    final results = await fetchGlobal<AttendanceRecord>(
      getRequests: (endpoint) => comms.getRequests(endpoint: endpoint),
      fromJson: (json) => AttendanceRecord.fromJson(json),
      endpoint: "meeting/attendance/meeting/${meeting.id}",
    );
    return results;
  }

  // Fetch all members
  Future<List<Member>> _fetchMembers() async {
    final results = await fetchGlobal<Member>(
      getRequests: (endpoint) => comms.getRequests(endpoint: endpoint),
      fromJson: (json) => Member.fromJson(json),
      endpoint: "members",
    );
    return results;
  }

  // Mark a member as present
  Future<void> markPresent(Member member) async {
    final data = {
      "meeting_id": meeting.id,
      "member_id": member.id,
      "attendance_status": "present",
      "arrival_time": DateTime.now().toString(),
      "notes": "Arrival is ontime",
    };

    final response = await comms.postRequest(
      endpoint: "meeting/attendance",
      data: data,
    );

    if (response["rsp"]["success"]) {
      _refreshData();
      showalert(
        success: true,
        context: context,
        title: "Success",
        subtitle: "Attendance marked successfully",
      );
    } else {
      showalert(
        success: false,
        context: context,
        title: "Error",
        subtitle: response["rsp"]["message"] ?? "Failed to mark attendance",
      );
    }
  }

  // Refresh data after marking attendance
  void _refreshData() {
    setState(() {
      _attendanceRecordsFuture = fetchAttendance();
      _membersFuture = _fetchMembers();
    });
  }

  // Check if attendance is open based on meeting time
  void _checkAttendanceStatus() {
    final now = DateTime.now();
    final meetingDate = meeting.meetingDate;
    final startTime = meeting.startTime;

    bool canCheckIn = false;
    bool isPast = false;

    if (startTime == null || meetingDate == null) {
      statusMessage = 'Invalid meeting data';
    } else {
      final isSameDay = _isSameDay(now, meetingDate);
      final meetingStartDateTime = DateTime(
        meetingDate.year,
        meetingDate.month,
        meetingDate.day,
        startTime.hour,
        startTime.minute,
      );

      if (now.isAfter(meetingStartDateTime.add(const Duration(hours: 2)))) {
        isPast = true;
        statusMessage = 'Meeting has ended. Showing final attendance.';
      } else if (!isSameDay) {
        if (now.isAfter(meetingDate)) {
          isPast = true;
          statusMessage = 'Meeting has ended. Showing final attendance.';
        } else {
          statusMessage = 'You can only check in on the meeting day.';
        }
      } else {
        final earlyCheckIn = meetingStartDateTime.subtract(
          const Duration(minutes: 30),
        );

        if (now.isBefore(earlyCheckIn)) {
          final minutesUntilOpen = earlyCheckIn.difference(now).inMinutes;
          statusMessage =
              'Too early to check in. Please wait $minutesUntilOpen minutes.';
          canCheckIn = false;
        } else if (now.isAfter(earlyCheckIn) &&
            now.isBefore(meetingStartDateTime)) {
          final minutesUntilStart =
              meetingStartDateTime.difference(now).inMinutes;
          statusMessage =
              'You can check in now. Meeting starts in $minutesUntilStart minutes.';
          canCheckIn = true;
        } else if (now.isAfter(meetingStartDateTime)) {
          final minutesLate = now.difference(meetingStartDateTime).inMinutes;
          statusMessage = 'Too late! Meeting started $minutesLate minutes ago.';
          canCheckIn = false;
        } else {
          statusMessage = 'Unable to determine attendance status.';
          canCheckIn = false;
        }
      }
    }

    setState(() {
      isAttendanceOpen = canCheckIn;
      isMeetingPast = isPast;
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void showMemberSelectionDialog() {
    String searchQuery = '';

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Select Member'),
                  content: SizedBox(
                    width: double.maxFinite,
                    height: 350,
                    child: Column(
                      children: [
                        // Search field
                        TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search members...',
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Member list
                        Expanded(
                          child: FutureBuilder<List<Object>>(
                            future: Future.wait([
                              _membersFuture,
                              _attendanceRecordsFuture,
                            ]),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return MeetingLoadingWidget();
                              }
                              if (snapshot.hasError) {
                                return Center(
                                  child: Text('Error: ${snapshot.error}'),
                                );
                              }
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: Text('No data available'),
                                );
                              }

                              final members = snapshot.data![0] as List<Member>;
                              final attendanceRecords =
                                  snapshot.data![1] as List<AttendanceRecord>;
                              final presentMemberIds =
                                  attendanceRecords
                                      .map((r) => r.memberId)
                                      .toSet();

                              // Filter out members who are already present
                              var availableMembers =
                                  members
                                      .where(
                                        (m) => !presentMemberIds.contains(m.id),
                                      )
                                      .toList();

                              // Apply search filter
                              if (searchQuery.isNotEmpty) {
                                availableMembers =
                                    availableMembers
                                        .where(
                                          (m) => m.name.toLowerCase().contains(
                                            searchQuery.toLowerCase(),
                                          ),
                                        )
                                        .toList();
                              }

                              if (availableMembers.isEmpty) {
                                return Center(
                                  child: Text(
                                    searchQuery.isEmpty
                                        ? 'All members are already present'
                                        : 'No members found',
                                  ),
                                );
                              }

                              return ListView.builder(
                                itemCount: availableMembers.length,
                                itemBuilder: (context, index) {
                                  final member = availableMembers[index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blue[100],
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                    title: Text(member.name),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      markPresent(member);
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
          ),
    );
  }

  Widget _buildAttendanceSection() {
    return MeetingWidgets.buildTableSection(
      title: 'Attendance',
      actionButton:
          isAttendanceOpen
              ? ElevatedButton.icon(
                onPressed: showMemberSelectionDialog,
                icon: const Icon(Icons.check_circle),
                label: const Text('Mark Attendance'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                ),
              )
              : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status message
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color:
                  isAttendanceOpen
                      ? Colors.green[50]
                      : isMeetingPast
                      ? Colors.blue[50]
                      : Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    isAttendanceOpen
                        ? Colors.green[200]!
                        : isMeetingPast
                        ? Colors.blue[200]!
                        : Colors.orange[200]!,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isAttendanceOpen
                      ? Icons.check_circle
                      : isMeetingPast
                      ? Icons.assignment_turned_in
                      : Icons.schedule,
                  color:
                      isAttendanceOpen
                          ? Colors.green[600]
                          : isMeetingPast
                          ? Colors.blue[600]
                          : Colors.orange[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    statusMessage,
                    style: TextStyle(
                      color:
                          isAttendanceOpen
                              ? Colors.green[700]
                              : isMeetingPast
                              ? Colors.blue[700]
                              : Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Attendance table
          FutureBuilder<List<AttendanceRecord>>(
            future: _attendanceRecordsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No attendance records found'),
                  ),
                );
              }

              final attendanceRecords = snapshot.data!;
              return MeetingWidgets.buildDataTable(
                context: context,
                columns: ['Name', 'Status', 'Arrival Time'],
                rows:
                    attendanceRecords
                        .map(
                          (record) => [
                            record.memberName,
                            MeetingWidgets.buildStatusChip('Present'),
                            record.arrivalTime != null
                                ? _formatTime(record.arrivalTime!)
                                : 'N/A',
                          ],
                        )
                        .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildAttendanceSection();
  }
}
