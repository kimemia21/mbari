import 'package:flutter/material.dart';
import 'package:mbari/core/constants/constants.dart';
import 'package:mbari/core/utils/Alerts.dart';
import 'package:mbari/data/models/AttendanceModel.dart';
import 'package:mbari/data/models/Meeting.dart';
import 'package:mbari/data/models/Member.dart';
import 'package:mbari/data/services/globalFetch.dart';

class MeetingDetailsContent extends StatefulWidget {
  final Meeting meeting;

  const MeetingDetailsContent({super.key, required this.meeting});

  @override
  State<MeetingDetailsContent> createState() => _MeetingDetailsContentState();
}

class _MeetingDetailsContentState extends State<MeetingDetailsContent> {
  late Future<List<Member>> _membersFuture;
  late Future<List<AttendanceRecord>> _presentMembersFuture;
  late String msg;
  bool isAttendanceOpen = false;
  bool isMeetingPast = false;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _membersFuture = _fetchMembers();
    _presentMembersFuture = _fetchPresentMembers();
    _checkAttendanceStatus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Member>> _fetchMembers() async {
    final results = await fetchGlobal<Member>(
      getRequests: (endpoint) => comms.getRequests(endpoint: endpoint),
      fromJson: (json) => Member.fromJson(json),
      endpoint: "members",
    );
    return results;
  }

  Future<List<AttendanceRecord>> _fetchPresentMembers() async {
    final results = await fetchGlobal<AttendanceRecord>(
      getRequests: (endpoint) => comms.getRequests(endpoint: endpoint),
      fromJson: (json) => AttendanceRecord.fromJson(json),
      endpoint: "meeting/attendance/meeting/${widget.meeting.id}",
    );
    return results;
  }

  Future<void> markPresent(Member member, Meeting meeting) async {
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
    } else {
      showalert(
        success: false,
        context: context,
        title: "Error",
        subtitle: response["rsp"]["message"] ?? "Failed",
      );
    }
  }

  void _refreshData() {
    setState(() {
      _membersFuture = _fetchMembers();
      _presentMembersFuture = _fetchPresentMembers();
    });
  }

  void _checkAttendanceStatus() {
    final now = DateTime.now();
    final meetingDate = widget.meeting.meetingDate;
    final startTime = widget.meeting.startTime;

    String statusMessage;
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

        final earlyCheckIn = meetingStartDateTime.subtract(const Duration(minutes: 30));

        if (now.isBefore(earlyCheckIn)) {
          final minutesUntilOpen = earlyCheckIn.difference(now).inMinutes;
          statusMessage = 'Too early to check in. Please wait $minutesUntilOpen minutes.';
          canCheckIn = false;
        } else if (now.isAfter(earlyCheckIn) && now.isBefore(meetingStartDateTime)) {
          final minutesUntilStart = meetingStartDateTime.difference(now).inMinutes;
          statusMessage = 'You can check in now. Meeting starts in $minutesUntilStart minutes.';
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
      msg = statusMessage;
      isAttendanceOpen = canCheckIn;
      isMeetingPast = isPast;
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isMobile(BuildContext context) => MediaQuery.of(context).size.width < 768;

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: MediaQuery.of(context).size.width * 0.95,
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 10),
          _buildMeetingDetails(context),
          const SizedBox(height: 10),
          Expanded(child: _buildAttendanceSection(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Text(
      'Meeting Details',
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildMeetingDetails(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildDetailRow('Meeting', widget.meeting.agenda),
            _buildDetailRow('Venue', widget.meeting.venue),
            _buildDetailRow('Date', _formatDate(widget.meeting.meetingDate)),
            _buildDetailRow('Time', widget.meeting.startTime?.format(context) ?? 'N/A'),
            _buildDetailRow('Organizer', widget.meeting.createdByName ?? 'Unknown'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSection(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAttendanceHeader(context),
            const SizedBox(height: 8),
            if (isAttendanceOpen || isMeetingPast) ...[
              _buildSearchBar(context),
              const SizedBox(height: 16),
            ],
            Expanded(
              child: isAttendanceOpen
                  ? _buildActiveAttendanceView(context)
                  : _buildClosedAttendanceView(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceHeader(BuildContext context) {
    IconData icon;
    Color color;
    String title;

    if (isAttendanceOpen) {
      icon = Icons.how_to_reg;
      color = Colors.green;
      title = 'Mark Attendance';
    } else if (isMeetingPast) {
      icon = Icons.assignment_turned_in;
      color = Colors.blue;
      title = 'Attendance Record';
    } else {
      icon = Icons.schedule;
      color = Colors.orange;
      title = 'Attendance Closed';
    }

    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
        decoration: const InputDecoration(
          hintText: 'Search members...',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildActiveAttendanceView(BuildContext context) {
    return FutureBuilder<List<Object>>(
      future: Future.wait([_membersFuture, _presentMembersFuture]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('No data available'));
        }

        final members = snapshot.data![0] as List<Member>;
        final presentRecords = snapshot.data![1] as List<AttendanceRecord>;
        final presentMemberIds = presentRecords.map((r) => r.memberId).toSet();

        final filteredMembers = members.where((m) => 
          m.name.toLowerCase().contains(searchQuery)).toList();
        final filteredPresentRecords = presentRecords.where((r) => 
          r.memberName.toLowerCase().contains(searchQuery)).toList();

        if (_isMobile(context)) {
          return _buildMobileAttendanceView(
            filteredMembers, 
            filteredPresentRecords, 
            presentMemberIds
          );
        }

        return _buildDesktopAttendanceView(
          filteredMembers, 
          filteredPresentRecords, 
          presentMemberIds
        );
      },
    );
  }

  Widget _buildMobileAttendanceView(
    List<Member> members, 
    List<AttendanceRecord> presentRecords, 
    Set<int> presentMemberIds
  ) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.blue[700],
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Colors.blue[700],
            tabs: [
              Tab(text: 'All Members (${members.length})'),
              Tab(text: 'Present (${presentRecords.length})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildAllMembersList(members, presentMemberIds),
                _buildPresentMembersList(presentRecords, showTime: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopAttendanceView(
    List<Member> members, 
    List<AttendanceRecord> presentRecords, 
    Set<int> presentMemberIds
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('All Members', members.length, Colors.blue),
              const SizedBox(height: 8),
              Expanded(child: _buildAllMembersList(members, presentMemberIds)),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Present', presentRecords.length, Colors.green),
              const SizedBox(height: 8),
              Expanded(child: _buildPresentMembersList(presentRecords, showTime: true)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClosedAttendanceView(BuildContext context) {
    if (isMeetingPast) {
      return FutureBuilder<List<AttendanceRecord>>(
        future: _presentMembersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No attendance records found'));
          }

          final presentRecords = snapshot.data!.where((r) => 
            r.memberName.toLowerCase().contains(searchQuery)).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Final Attendance', presentRecords.length, Colors.blue),
              const SizedBox(height: 8),
              Expanded(child: _buildPresentMembersList(presentRecords, showTime: true)),
            ],
          );
        },
      );
    }

    return _buildStatusMessage();
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            title.contains('Present') ? Icons.check_circle : Icons.people,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            '$title ($count)',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllMembersList(List<Member> members, Set<int> presentMemberIds) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          final isPresent = presentMemberIds.contains(member.id);
          
          return _buildMemberListItem(
            name: member.name,
            isPresent: isPresent,
            canToggle: !isPresent,
            onToggle: !isPresent ? () => markPresent(member, widget.meeting) : null,
          );
        },
      ),
    );
  }

  Widget _buildPresentMembersList(List<AttendanceRecord> records, {bool showTime = false}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          return _buildPresentMemberItem(record, showTime: showTime);
        },
      ),
    );
  }

  Widget _buildMemberListItem({
    required String name,
    required bool isPresent,
    required bool canToggle,
    VoidCallback? onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: isPresent ? Colors.green[100] : Colors.grey[200],
          child: Icon(
            isPresent ? Icons.check : Icons.person,
            size: 18,
            color: isPresent ? Colors.green[700] : Colors.grey[600],
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isPresent ? Colors.green[700] : Colors.grey[800],
          ),
        ),
        trailing: canToggle
            ? IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: Colors.blue[600],
                onPressed: onToggle,
                tooltip: 'Mark Present',
              )
            : Icon(Icons.check_circle, color: Colors.green[600]),
      ),
    );
  }

  Widget _buildPresentMemberItem(AttendanceRecord record, {bool showTime = false}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.green[100]!, width: 0.5),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: Colors.green[100],
          child: Icon(Icons.check, size: 18, color: Colors.green[700]),
        ),
        title: Text(
          record.memberName,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.green[700],
          ),
        ),
        subtitle: showTime && record.arrivalTime != null
            ? Text(
                'Arrived: ${_formatTime(record.arrivalTime!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[600],
                ),
              )
            : null,
        trailing: Icon(Icons.verified, color: Colors.green[600], size: 20),
      ),
    );
  }

  Widget _buildStatusMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule, size: 48, color: Colors.orange[600]),
          const SizedBox(height: 16),
          Text(
            'Attendance Not Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.orange[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}