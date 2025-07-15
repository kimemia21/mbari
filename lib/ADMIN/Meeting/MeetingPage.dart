import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mbari/ADMIN/Alerts/MeetingDetails.dart';
import 'package:mbari/ADMIN/Create/CreateMeeting.dart';
import 'package:mbari/core/constants/constants.dart';
import 'package:mbari/data/models/Meeting.dart';
import 'package:mbari/data/services/globalFetch.dart';

class MeetingPage extends StatefulWidget {
  @override
  _MeetingPageState createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> {
  late Future<List<Meeting>> _meetingsFuture;

  List<Map<String, dynamic>> members = [
    {"id": 1, "name": "John Doe", "status": "absent"},
    {"id": 2, "name": "Jane Smith", "status": "present"},
  ];

  @override
  void initState() {
    super.initState();
    _meetingsFuture = fetchMeetings();
  }

  Future<List<Meeting>> fetchMeetings() async {
    final response = await fetchGlobal<Meeting>(
      getRequests: (endpoint) => comms.getRequests(endpoint: endpoint),
      fromJson: (json) => Meeting.fromJson(json),
      endpoint: "meeting/chama/${user.chamaId}",
    );
    return response;
  }

  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  bool _isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1024;
  }

  double _getHorizontalPadding(BuildContext context) {
    if (_isMobile(context)) return 16;
    if (_isTablet(context)) return 24;
    return 32;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(_getHorizontalPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(height: _isMobile(context) ? 16 : 32),
            Expanded(
              child: FutureBuilder<List<Meeting>>(
                future: _meetingsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No meetings found'));
                  }

                  final meetings = snapshot.data!;
                  final now = DateTime.now();
                  final upcomingMeetings =
                      meetings
                          .where(
                            (m) =>
                                m.meetingDate.isAfter(now) ||
                                m.status == 'scheduled',
                          )
                          .toList();
                  final pastMeetings =
                      meetings
                          .where(
                            (m) =>
                                m.meetingDate.isBefore(now) ||
                                m.status == 'completed',
                          )
                          .toList();

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Upcoming Meetings', context),
                        SizedBox(height: 16),
                        MeetingDataTable(
                          meetings: upcomingMeetings,
                          isUpcoming: true,
                          isMobile: _isMobile(context),
                        ),
                        SizedBox(height: _isMobile(context) ? 24 : 32),
                        _buildSectionTitle('Past Meetings', context),
                        SizedBox(height: 16),
                        MeetingDataTable(
                          meetings: pastMeetings,
                          isUpcoming: false,
                          isMobile: _isMobile(context),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    if (_isMobile(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meetings',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  () => _showCreateMeetingModal(context, (po) {
                    if (po) {
                      setState(() {
                        _meetingsFuture = fetchMeetings();
                      });
                    }
                  }),
              child: Text("Create Meeting"),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Meetings',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        TextButton(
          onPressed:
              () => _showCreateMeetingModal(context, (po) {
                if (po) {
                  setState(() {
                    _meetingsFuture = fetchMeetings();
                  });
                }
              }),
          child: Text("Create Meeting"),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: _isMobile(context) ? 20 : 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  void _showCreateMeetingModal(
    BuildContext context,
    void Function(bool) callBack,
  ) {
    showModalBottomSheet(
      showDragHandle: true,
      enableDrag: true,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return CreateMeetingForm(
          onMeetingCreated: (p0) {
            callBack(true);
          },
        );
      },
    );
  }
}

class MeetingDataTable extends StatelessWidget {
  final List<Meeting> meetings;
  final bool isUpcoming;
  final bool isMobile;

  const MeetingDataTable({
    Key? key,
    required this.meetings,
    required this.isUpcoming,
    required this.isMobile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (meetings.isEmpty) {
      return Container(
        padding: EdgeInsets.all(isMobile ? 24 : 32),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'No ${isUpcoming ? 'upcoming' : 'past'} meetings',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ),
      );
    }

    if (isMobile) {
      return _buildMobileList(context);
    }

    return _buildDesktopTable(context);
  }

  Widget _buildMobileList(BuildContext context) {
    return Column(
      children:
          meetings.map((meeting) {
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showMeetingDetails(context, meeting),
                          child: Text(
                            meeting.agenda,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(meeting.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(meeting.status),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(meeting.meetingDate),
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      if (meeting.startTime != null) ...[
                        SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${meeting.startTime!.format(context)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        'Created by ${meeting.createdByName!}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildDesktopTable(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width - 64,
            ),
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
              headingTextStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black,
              ),
              dataTextStyle: TextStyle(fontSize: 14, color: Colors.black),
              columnSpacing: 24,
              horizontalMargin: 16,
              dividerThickness: 1,
              columns: [
                DataColumn(label: Container(width: 120, child: Text('Date'))),
                DataColumn(label: Expanded(child: Text('Title'))),
                DataColumn(label: Container(width: 100, child: Text('Status'))),
                DataColumn(
                  label: Container(width: 150, child: Text('Created By')),
                ),
              ],
              rows:
                  meetings.map((meeting) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Container(
                            width: 120,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(meeting.meetingDate),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                if (meeting.startTime != null)
                                  Text(
                                    '${meeting.startTime!.format(context)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        DataCell(
                          GestureDetector(
                            onTap: () => _showMeetingDetails(context, meeting),
                            child: Text(
                              meeting.agenda,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: 100,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(meeting.status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getStatusText(meeting.status),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            width: 150,
                            child: Text(
                              meeting.createdByName!,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _showMeetingDetails(BuildContext context, Meeting meeting) {
    showModalBottomSheet(
      showDragHandle: true,
      enableDrag: true,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return MeetingDetailsContent(meeting: meeting);
      },
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'scheduled':
        return 'Scheduled';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'scheduled':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
