import 'package:flutter/material.dart';
import 'package:mbari/core/constants/constants.dart';
import 'package:mbari/data/models/Meeting.dart';
import 'package:mbari/data/models/Member.dart';
import 'package:mbari/data/services/globalFetch.dart';

class MeetingDetailsContent extends StatefulWidget {
  final Meeting meeting;

  const MeetingDetailsContent({
    super.key,
    required this.meeting,
  });

  @override
  State<MeetingDetailsContent> createState() => _MeetingDetailsContentState();
}

class _MeetingDetailsContentState extends State<MeetingDetailsContent> {
  late Future<List<Member>> _membersFuture;
  late String msg;
  bool isAttendanceOpen = false;

  @override
  void initState() {
    super.initState();
    _membersFuture = _fetchMembers();
    _checkAttendanceStatus();
  }

  Future<List<Member>> _fetchMembers() async {
    final results = await fetchGlobal<Member>(
      getRequests: (endpoint) => comms.getRequests(endpoint: endpoint),
      fromJson: (json) => Member.fromJson(json),
      endpoint: "members",
    );
    return results;
  }

void _checkAttendanceStatus() {
  final now = DateTime.now();
  final meetingDate = widget.meeting.meetingDate;
  final startTime = widget.meeting.startTime;

  String statusMessage;
  bool canCheckIn = false;

  if (startTime == null || meetingDate == null) {
    statusMessage = 'Invalid meeting data';
  } else {
    final isSameDay = _isSameDay(now, meetingDate);

    if (!isSameDay) {
      statusMessage = 'You can only check in on the meeting day.';
    } else {
      final meetingStartDateTime = DateTime(
        meetingDate.year,
        meetingDate.month,
        meetingDate.day,
        startTime.hour,
        startTime.minute,
      );

      // Calculate attendance window: 30 minutes before start time, closes at start time
      final earlyCheckIn = meetingStartDateTime.subtract(const Duration(minutes: 30));

      if (now.isBefore(earlyCheckIn)) {
        // Too early to check in
        final minutesUntilOpen = earlyCheckIn.difference(now).inMinutes;
        statusMessage = 'Too early to check in. Please wait $minutesUntilOpen minutes.';
        canCheckIn = false;
      } else if (now.isAfter(earlyCheckIn) && now.isBefore(meetingStartDateTime)) {
        // Early check-in window (30 minutes before start)
        final minutesUntilStart = meetingStartDateTime.difference(now).inMinutes;
        statusMessage = 'You can check in now. Meeting starts in $minutesUntilStart minutes.';
        canCheckIn = true;
      } else if (now.isAfter(meetingStartDateTime)) {
        // Meeting has started - too late to check in
        final minutesLate = now.difference(meetingStartDateTime).inMinutes;
        statusMessage = 'Too late! Meeting started $minutesLate minutes ago.';
        canCheckIn = false;
      } else {
        // Edge case fallback
        statusMessage = 'Unable to determine attendance status.';
        canCheckIn = false;
      }
    }
  }

  setState(() {
    msg = statusMessage;
    isAttendanceOpen = canCheckIn;
  });
}
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  bool _isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1024;
  }

  double _getMaxWidth(BuildContext context) {
    if (_isMobile(context)) return MediaQuery.of(context).size.width * 0.95;
    if (_isTablet(context)) return MediaQuery.of(context).size.width * 0.85;
    return 800;
  }

  double _getContainerWidth(BuildContext context) {
    if (_isMobile(context)) return MediaQuery.of(context).size.width * 0.95;
    if (_isTablet(context)) return MediaQuery.of(context).size.width * 0.85;
    return MediaQuery.of(context).size.width * 0.75;
  }

  double _getContainerHeight(BuildContext context) {
    if (_isMobile(context)) return MediaQuery.of(context).size.height * 0.9;
    return MediaQuery.of(context).size.height * 0.75;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _getContainerWidth(context),
      height: _getContainerHeight(context),
      padding: EdgeInsets.all(_isMobile(context) ? 16.0 : 24.0),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: _getMaxWidth(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: _isMobile(context) ? 16 : 20),
              _buildMeetingDetails(context),
              SizedBox(height: _isMobile(context) ? 16 : 20),
              _buildAttendanceSection(context),
              SizedBox(height: _isMobile(context) ? 16 : 20),
              _buildActionButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Text(
      'Meeting Details',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontSize: _isMobile(context) ? 20 : 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMeetingDetails(BuildContext context) {
    if (_isMobile(context)) {
      return _buildMobileDetailsCard(context);
    }
    return _buildDesktopDetailsGrid(context);
  }

  Widget _buildMobileDetailsCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMobileDetailItem(
              context,
              Icons.business,
              'Chama',
              widget.meeting.chamaName ?? 'N/A',
            ),
            const SizedBox(height: 12),
            _buildMobileDetailItem(
              context,
              Icons.assignment,
              'Agenda',
              widget.meeting.agenda,
            ),
            const SizedBox(height: 12),
            _buildMobileDetailItem(
              context,
              Icons.location_on,
              'Venue',
              widget.meeting.venue,
            ),
            const SizedBox(height: 12),
            _buildMobileDetailItem(
              context,
              Icons.calendar_today,
              'Date',
              _formatDate(widget.meeting.meetingDate),
            ),
            const SizedBox(height: 12),
            _buildMobileDetailItem(
              context,
              Icons.access_time,
              'Start Time',
              widget.meeting.startTime != null
                  ? '${widget.meeting.startTime!.format(context)}'
                  : 'N/A',
            ),
            const SizedBox(height: 12),
            _buildMobileDetailItem(
              context,
              Icons.person,
              'Created By',
              widget.meeting.createdByName ?? 'Deleted',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileDetailItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopDetailsGrid(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDetailRow(
                  'Chama:',
                  widget.meeting.chamaName ?? 'N/A',
                ),
              ),
              const SizedBox(width: 24),
              Expanded(child: _buildDetailRow('Venue:', widget.meeting.venue)),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Agenda:', widget.meeting.agenda),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailRow(
                  'Date:',
                  _formatDate(widget.meeting.meetingDate),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildDetailRow(
                  'Start Time:',
                  widget.meeting.startTime != null
                      ? '${widget.meeting.startTime!.format(context)}'
                      : 'N/A',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Created By:',
            widget.meeting.createdByName ?? 'Deleted',
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isAttendanceOpen ? Icons.check_circle : Icons.access_time,
              size: _isMobile(context) ? 20 : 24,
              color: isAttendanceOpen ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(
              isAttendanceOpen ? 'Mark Attendance' : 'Attendance Not Yet Open',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: _isMobile(context) ? 16 : 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (isAttendanceOpen)
          _buildAttendanceList(context)
        else
          _buildAttendanceClosedMessage(context),
      ],
    );
  }

  Widget _buildAttendanceList(BuildContext context) {
    return FutureBuilder<List<Member>>(
      future: _membersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No members found.'));
        } else {
          final members = snapshot.data!;
          
          if (_isMobile(context)) {
            return _buildMobileAttendanceList(context, members);
          }
          return _buildDesktopAttendanceList(context, members);
        }
      },
    );
  }

  Widget _buildMobileAttendanceList(BuildContext context, List<Member> members) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: members.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[200]),
        itemBuilder: (context, index) {
          final member = members[index];
          
          return StatefulBuilder(
            builder: (context, setState) {
              bool isPresent = false;
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: isPresent ? Colors.green[100] : Colors.grey[200],
                      child: Icon(
                        isPresent ? Icons.check : Icons.person,
                        size: 16,
                        color: isPresent ? Colors.green : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        member.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Switch(
                      value: isPresent,
                      onChanged: (value) {
                        setState(() {
                          isPresent = value;
                        });
                      },
                      activeColor: Colors.green,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDesktopAttendanceList(BuildContext context, List<Member> members) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          
          return StatefulBuilder(
            builder: (context, setState) {
              bool isPresent = false;
              
              return SwitchListTile(
                value: isPresent,
                title: Text(
                  member.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                secondary: CircleAvatar(
                  radius: 20,
                  backgroundColor: isPresent ? Colors.green[100] : Colors.grey[200],
                  child: Icon(
                    isPresent ? Icons.check : Icons.person,
                    size: 18,
                    color: isPresent ? Colors.green : Colors.grey[600],
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    isPresent = value;
                  });
                },
                activeColor: Colors.green,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAttendanceClosedMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              msg,
              style: TextStyle(color: Colors.orange[700], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return FutureBuilder<List<Member>>(
      future: _membersFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        
        final members = snapshot.data!;
        
        if (_isMobile(context)) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isAttendanceOpen
                  ? () {
                      final attendanceData = members.map((member) => {
                        'id': member.id,
                        'name': member.name,
                        'status': 'absent', // Default to absent since we don't track state
                      }).toList();
                      Navigator.pop(context, attendanceData);
                    }
                  : null,
              icon: const Icon(Icons.check),
              label: const Text('Confirm Attendance'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          );
        }

        return Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: isAttendanceOpen
                ? () {
                    final attendanceData = members.map((member) => {
                      'id': member.id,
                      'name': member.name,
                      'status': 'absent', // Default to absent since we don't track state
                    }).toList();
                    Navigator.pop(context, attendanceData);
                  }
                : null,
            icon: const Icon(Icons.check),
            label: const Text('Confirm'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}