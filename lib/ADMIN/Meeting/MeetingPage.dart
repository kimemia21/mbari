import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // Import for date formatting

// Assuming these are your network communication and data fetching utilities
// YOU WILL NEED TO REPLACE THESE WITH YOUR ACTUAL IMPLEMENTATIONS
import 'package:mbari/ADMIN/Create/CreateMeeting.dart'; // Assuming this is your create meeting form

// Placeholder for your comms and fetchGlobal.
// Replace with your actual imports and implementation.
// For demonstration, I'll create dummy versions.
class Comms {
  Future<dynamic> getRequests({required String endpoint}) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));
    if (endpoint == "meetings") {
      // Simulate API response for meetings
      return [
        {
          'id': '1',
          'chama_id': 'chama1',
          'meeting_date': '2025-07-22T10:00:00Z', // Upcoming
          'venue': 'Community Hall',
          'agenda': 'Discuss upcoming projects and budget review.',
          'status': 'scheduled',
          'start_time': '10:00',
          'end_time': '11:00',
          'created_by': 1,
        },
        {
          'id': '2',
          'chama_id': 'chama1',
          'meeting_date': '2025-07-15T09:00:00Z', // Today, starts in 15 mins (current time 6:20 AM)
          'venue': 'Chama Office',
          'agenda': 'Weekly sync-up and task assignment.',
          'status': 'scheduled',
          'start_time': '06:35', // Simulate starting in 15 mins from 6:20
          'end_time': '07:35',
          'created_by': 1,
        },
        {
          'id': '3',
          'chama_id': 'chama1',
          'meeting_date': '2025-07-14T14:00:00Z', // Completed
          'venue': 'Online - Google Meet',
          'agenda': 'Review Q2 financial performance.',
          'status': 'completed',
          'start_time': '14:00',
          'end_time': '15:00',
          'created_by': 2,
        },
        {
          'id': '4',
          'chama_id': 'chama1',
          'meeting_date': '2025-07-16T16:00:00Z', // Upcoming
          'venue': 'Cafeteria',
          'agenda': 'Brainstorming session for new initiatives.',
          'status': 'scheduled',
          'start_time': '16:00',
          'end_time': '17:00',
          'created_by': 1,
        },
        {
          'id': '5',
          'chama_id': 'chama1',
          'meeting_date': '2025-07-10T10:00:00Z', // Cancelled
          'venue': 'Community Center',
          'agenda': 'Cancelled meeting for renovation.',
          'status': 'cancelled',
          'start_time': '10:00',
          'end_time': '11:00',
          'created_by': 1,
        },
         {
          'id': '6',
          'chama_id': 'chama1',
          'meeting_date': '2025-07-15T05:00:00Z', // Today, already passed
          'venue': 'Boardroom',
          'agenda': 'Early morning strategy session.',
          'status': 'scheduled',
          'start_time': '05:00',
          'end_time': '06:00',
          'created_by': 1,
        },
      ];
    }
    return []; // Default empty response
  }
}

// --- Models (Updated as per your new Meeting class) ---
class Meeting {
  final String? id;
  final String chamaId;
  final DateTime meetingDate;
  final String venue;
  final String agenda; // Corresponds to description
  final String status;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final int created_by;

  // Additional fields from original Meeting model, for consistency
  final int expectedAttendees;
  int actualAttendees;
  bool isFinalized;

  Meeting({
    this.id,
    required this.chamaId,
    required this.meetingDate,
    required this.venue,
    required this.agenda,
    this.status = 'scheduled',
    this.startTime,
    this.endTime,
    required this.created_by,
    this.expectedAttendees = 0, // Default for new fields
    this.actualAttendees = 0,
    this.isFinalized = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'chama_id': chamaId,
      'meeting_date': meetingDate.toIso8601String(),
      'venue': venue,
      'agenda': agenda,
      'status': status,
      'start_time': startTime != null
          ? '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'end_time': endTime != null
          ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'created_by': created_by,
      // Include other fields for completeness if sending back to API
      'expected_attendees': expectedAttendees,
      'actual_attendees': actualAttendees,
      'is_finalized': isFinalized,
    };
  }

  factory Meeting.fromJson(Map<String, dynamic> json) {
    TimeOfDay? parseTime(String? timeStr) {
      if (timeStr == null || timeStr.isEmpty) return null;
      try {
        final parts = timeStr.split(':');
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      } catch (e) {
        print('Error parsing time string "$timeStr": $e');
        return null;
      }
    }

    return Meeting(
      id: json['id']?.toString(), // Ensure ID is string
      chamaId: json['chama_id'] ?? '',
      meetingDate: DateTime.parse(json['meeting_date']),
      venue: json['venue'] ?? 'N/A',
      agenda: json['agenda'] ?? 'No agenda provided.',
      status: json['status'] ?? 'scheduled',
      startTime: parseTime(json['start_time']),
      endTime: parseTime(json['end_time']),
      created_by: json["created_by"] ?? 0,
      // Populate new fields from JSON if available, otherwise use defaults
      expectedAttendees: json['expected_attendees'] ?? 0,
      actualAttendees: json['actual_attendees'] ?? 0,
      isFinalized: json['is_finalized'] ?? false,
    );
  }

  // Helper method to create a copy with updated fields
  Meeting copyWith({
    String? id,
    String? chamaId,
    DateTime? meetingDate,
    String? venue,
    String? agenda,
    String? status,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    int? created_by,
    int? expectedAttendees,
    int? actualAttendees,
    bool? isFinalized,
  }) {
    return Meeting(
      id: id ?? this.id,
      chamaId: chamaId ?? this.chamaId,
      meetingDate: meetingDate ?? this.meetingDate,
      venue: venue ?? this.venue,
      agenda: agenda ?? this.agenda,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      created_by: created_by ?? this.created_by,
      expectedAttendees: expectedAttendees ?? this.expectedAttendees,
      actualAttendees: actualAttendees ?? this.actualAttendees,
      isFinalized: isFinalized ?? this.isFinalized,
    );
  }
}

class MeetingAttendance {
  final String id;
  final String meetingId;
  final String memberId;
  final String memberName;
  bool isPresent; // Made mutable for attendance marking
  final DateTime? checkInTime;
  String? notes;

  MeetingAttendance({
    required this.id,
    required this.meetingId,
    required this.memberId,
    required this.memberName,
    this.isPresent = false, // Default to false
    this.checkInTime,
    this.notes,
  });
}

class MeetingFinancials {
  final String id;
  final String meetingId;
  final double totalContributions;
  final double totalExpenses;
  final double netAmount;
  final Map<String, double> memberContributions; // memberId -> contribution amount
  final List<Expense> expenses;
  final bool isFinalized;

  MeetingFinancials({
    required this.id,
    required this.meetingId,
    required this.totalContributions,
    required this.totalExpenses,
    required this.netAmount,
    required this.memberContributions,
    required this.expenses,
    required this.isFinalized,
  });
}

class Expense {
  final String id;
  final String description;
  final double amount;
  final String category;
  final DateTime date;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
  });
}

// --- Enhanced Meetings Page ---
class MeetingsPage extends StatefulWidget {
  @override
  _MeetingsPageState createState() => _MeetingsPageState();
}

class _MeetingsPageState extends State<MeetingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  late Future<List<Meeting>> _meetingsFuture; // Future to hold API call result

  // List to store all meetings fetched from the API
  List<Meeting> _allMeetings = [];
  List<Meeting> _filteredMeetings = [];
  String _selectedFilter = 'today'; // Default to today's meetings

  // Sample members for attendance (you'd fetch these from an API too)
  final List<Map<String, String>> _chamaMembers = [
    {'id': 'member1', 'name': 'Alice Johnson'},
    {'id': 'member2', 'name': 'Bob Williams'},
    {'id': 'member3', 'name': 'Charlie Brown'},
    {'id': 'member4', 'name': 'Diana Prince'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);
    _meetingsFuture = fetchMeetings(); // Initial API call

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final filters = ['today', 'upcoming', 'completed', 'cancelled'];
        _selectedFilter = filters[_tabController.index];
        _filterMeetings(); // Apply filter based on new tab
      }
    });

    // Listen to search controller changes
    _searchController.addListener(_filterMeetings);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_filterMeetings);
    _searchController.dispose();
    super.dispose();
  }

  // Function to fetch meetings from the API
  Future<List<Meeting>> fetchMeetings() async {
    try {
      final response = await fetchGlobal<Meeting>(
        getRequests: (endpoint) => comms.getRequests(endpoint: endpoint),
        fromJson: (json) => Meeting.fromJson(json),
        endpoint: "meetings",
      );
      setState(() {
        _allMeetings = response;
        _filterMeetings(); // Apply initial filter after data load
      });
      return response;
    } catch (e) {
      print('Error fetching meetings: $e');
      // Re-throw or handle error appropriately
      throw Exception('Failed to load meetings: $e');
    }
  }

  // Call this to refresh the meetings list, e.g., after creating/editing/deleting
  void _refreshMeetings() {
    setState(() {
      _meetingsFuture = fetchMeetings(); // Re-fetch meetings
    });
  }

  void _filterMeetings() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);

      _filteredMeetings = _allMeetings.where((meeting) {
        final matchesSearch = meeting.agenda.toLowerCase().contains(query) ||
            meeting.venue.toLowerCase().contains(query);

        switch (_selectedFilter) {
          case 'today':
            // Meeting is considered 'today' if its scheduled date is today
            // and it hasn't been completed or cancelled.
            // Also, consider meetings that might span across midnight (start yesterday, end today)
            final meetingStartDateTime = DateTime(meeting.meetingDate.year, meeting.meetingDate.month, meeting.meetingDate.day, meeting.startTime?.hour ?? 0, meeting.startTime?.minute ?? 0);
            final meetingEndDateTime = DateTime(meeting.meetingDate.year, meeting.meetingDate.month, meeting.meetingDate.day, meeting.endTime?.hour ?? 23, meeting.endTime?.minute ?? 59);

            return matchesSearch &&
                (meetingStartDateTime.isBefore(endOfToday) && meetingEndDateTime.isAfter(startOfToday)) &&
                meeting.status != 'cancelled' &&
                meeting.status != 'completed';
          case 'upcoming':
            // Upcoming meetings are those scheduled for after today and are not cancelled
            return matchesSearch &&
                meeting.meetingDate.isAfter(endOfToday) &&
                meeting.status == 'scheduled'; // Use 'scheduled' for consistency
          case 'completed':
            return matchesSearch && meeting.status == 'completed';
          case 'cancelled':
            return matchesSearch && meeting.status == 'cancelled';
          default:
            return matchesSearch;
        }
      }).toList();

      // Sort meetings for "Today" and "Upcoming" by time
      if (_selectedFilter == 'today' || _selectedFilter == 'upcoming') {
        _filteredMeetings.sort((a, b) {
          // Combine date and time for accurate sorting
          DateTime aFullTime = DateTime(a.meetingDate.year, a.meetingDate.month,
              a.meetingDate.day, a.startTime?.hour ?? 0, a.startTime?.minute ?? 0);
          DateTime bFullTime = DateTime(b.meetingDate.year, b.meetingDate.month,
              b.meetingDate.day, b.startTime?.hour ?? 0, b.startTime?.minute ?? 0);
          return aFullTime.compareTo(bFullTime);
        });
      }
    });
  }

  // --- UI Building Methods ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      floatingActionButton: !isDesktop
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateMeetingDialog(context),
              icon: Icon(Icons.add),
              label: Text('Create Meeting'),
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
            )
          : null,
      body: Padding(
        padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with search and create button
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search meetings...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: theme.iconTheme.color,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: theme.cardColor,
                      ),
                    ),
                  ),
                ),
                if (isDesktop) ...[
                  SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateMeetingDialog(context),
                    icon: Icon(Icons.add),
                    label: Text('Create Meeting'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 24),

            // Statistics Cards
            _buildStatsSection(theme, isDesktop),
            SizedBox(height: 24),

            // Filter Tabs
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'Today'),
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Completed'),
                  Tab(text: 'Cancelled'),
                ],
                indicatorColor: theme.primaryColor,
                labelColor: theme.primaryColor,
                unselectedLabelColor: theme.textTheme.bodyMedium?.color,
              ),
            ),
            SizedBox(height: 16),

            // Meetings List wrapped in FutureBuilder
            Expanded(
              child: FutureBuilder<List<Meeting>>(
                future: _meetingsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(color: Colors.red),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No meetings available.',
                        style: theme.textTheme.titleMedium,
                      ),
                    );
                  } else {
                    // Data is loaded, display the TabBarView
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildMeetingsList(theme, isDesktop, 'today'),
                        _buildMeetingsList(theme, isDesktop, 'upcoming'),
                        _buildMeetingsList(theme, isDesktop, 'completed'),
                        _buildMeetingsList(theme, isDesktop, 'cancelled'),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme, bool isDesktop) {
    final upcomingCount =
        _allMeetings.where((m) => m.status == 'scheduled').length;
    final completedCount =
        _allMeetings.where((m) => m.status == 'completed').length;
    final totalAttendees = _allMeetings.fold(
      0,
      (sum, m) => sum + m.actualAttendees,
    );
    final avgAttendance = completedCount > 0
        ? (_allMeetings
                    .where(
                        (m) => m.status == 'completed' && m.expectedAttendees > 0)
                    .fold(
                      0.0,
                      (sum, m) =>
                          sum + (m.actualAttendees / m.expectedAttendees),
                    ) /
                completedCount *
                100)
        : 0.0;

    final stats = [
      {
        'title': 'Total Meetings',
        'value': '${_allMeetings.length}',
        'icon': Icons.event,
        'color': theme.primaryColor,
      },
      {
        'title': 'Upcoming',
        'value': '$upcomingCount',
        'icon': Icons.schedule,
        'color': Colors.orange,
      },
      {
        'title': 'Completed',
        'value': '$completedCount',
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
      {
        'title': 'Avg Attendance',
        'value': '${avgAttendance.toStringAsFixed(1)}%',
        'icon': Icons.people,
        'color': Colors.blue,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isDesktop ? 1.5 : 1.2,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                stat['icon'] as IconData,
                size: 32,
                color: stat['color'] as Color,
              ),
              SizedBox(height: 8),
              Text(
                stat['value'] as String,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: stat['color'] as Color,
                ),
              ),
              SizedBox(height: 4),
              Text(
                stat['title'] as String,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMeetingsList(ThemeData theme, bool isDesktop, String tabStatus) {
    // This list is already filtered by _filterMeetings and corresponds to the current tab
    final List<Meeting> meetingsForTab = _filteredMeetings.where((meeting) {
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);

      switch (tabStatus) {
        case 'today':
          final meetingStartDateTime = DateTime(meeting.meetingDate.year, meeting.meetingDate.month, meeting.meetingDate.day, meeting.startTime?.hour ?? 0, meeting.startTime?.minute ?? 0);
          final meetingEndDateTime = DateTime(meeting.meetingDate.year, meeting.meetingDate.month, meeting.meetingDate.day, meeting.endTime?.hour ?? 23, meeting.endTime?.minute ?? 59);
          return (meetingStartDateTime.isBefore(endOfToday) && meetingEndDateTime.isAfter(startOfToday)) &&
              meeting.status != 'cancelled' &&
              meeting.status != 'completed';
        case 'upcoming':
          return meeting.meetingDate.isAfter(endOfToday) &&
              meeting.status == 'scheduled';
        case 'completed':
          return meeting.status == 'completed';
        case 'cancelled':
          return meeting.status == 'cancelled';
        default:
          return false;
      }
    }).toList();


    if (meetingsForTab.isEmpty) {
      return Center(
        child: Text(
          'No meetings found for this category.',
          style: theme.textTheme.titleMedium,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        itemCount: meetingsForTab.length,
        itemBuilder: (context, index) {
          final meeting = meetingsForTab[index];
          return _buildMeetingCard(meeting, theme, isDesktop);
        },
      ),
    );
  }

  Widget _buildMeetingCard(Meeting meeting, ThemeData theme, bool isDesktop) {
    final statusColor = meeting.status == 'scheduled'
        ? Colors.orange
        : meeting.status == 'completed'
            ? Colors.green
            : Colors.red;

    final now = DateTime.now();
    final meetingStartDateTime = DateTime(meeting.meetingDate.year,
        meeting.meetingDate.month, meeting.meetingDate.day,
        meeting.startTime?.hour ?? 0, meeting.startTime?.minute ?? 0);
    final meetingEndDateTime = DateTime(meeting.meetingDate.year,
        meeting.meetingDate.month, meeting.meetingDate.day,
        meeting.endTime?.hour ?? 23, meeting.endTime?.minute ?? 59);


    // Check if the meeting is actionable for attendance/fees:
    // It must be 'scheduled', its start time is now or in the next 30 minutes,
    // and its end time is still in the future or within the last 30 minutes.
    final isActionableForAttendance = meeting.status == 'scheduled' &&
        meetingStartDateTime.isBefore(now.add(Duration(minutes: 30))) &&
        meetingEndDateTime.isAfter(now.subtract(Duration(minutes: 30)));


    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _viewMeetingDetails(meeting, isActionableForAttendance),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: statusColor.withOpacity(0.2),
                    child: Icon(
                      _getStatusIcon(meeting.status),
                      color: statusColor,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meeting.agenda, // Using agenda as title
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        // You can add more detailed description here if needed
                        // Text(
                        //   meeting.description, // If you want to keep original description
                        //   style: theme.textTheme.bodyMedium?.copyWith(
                        //     color: theme.textTheme.bodySmall?.color,
                        //   ),
                        //   maxLines: 2,
                        //   overflow: TextOverflow.ellipsis,
                        // ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 16, color: theme.iconTheme.color),
                            SizedBox(width: 4),
                            Text(
                              DateFormat('MMM dd, yyyy').format(meeting.meetingDate),
                              style: theme.textTheme.bodySmall,
                            ),
                            if (meeting.startTime != null && meeting.endTime != null) ...[
                              SizedBox(width: 12),
                              Icon(Icons.access_time,
                                  size: 16, color: theme.iconTheme.color),
                              SizedBox(width: 4),
                              Text(
                                '${meeting.startTime!.format(context)} - ${meeting.endTime!.format(context)}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 16, color: theme.iconTheme.color),
                            SizedBox(width: 4),
                            Text(
                              meeting.venue,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      meeting.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              if (isActionableForAttendance) ...[
                Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCompactActionButton(
                      'Mark Attendance',
                      Icons.how_to_reg,
                      () => _manageAttendance(meeting),
                      Colors.green,
                      theme,
                    ),
                    _buildCompactActionButton(
                      'Collect Fees',
                      Icons.payments,
                      () => _manageFinancials(meeting),
                      Colors.blue,
                      theme,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactActionButton(String label, IconData icon,
      VoidCallback onTap, Color color, ThemeData theme) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateMeetingDialog(BuildContext context) {
    showModalBottomSheet(
      showDragHandle: true,
      enableDrag: true,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return CreateMeetingForm(
       
        );
      },
    );
  }

  void _viewMeetingDetails(Meeting meeting, bool isActionable) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(meeting.agenda), // Using agenda as title
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  meeting.agenda, // Detailed agenda
                  style: theme.textTheme.bodyLarge,
                ),
                SizedBox(height: 16),
                _buildDetailRow(
                  'Date',
                  DateFormat('EEEE, MMM dd, yyyy').format(meeting.meetingDate),
                  Icons.calendar_today,
                  theme,
                ),
                if (meeting.startTime != null && meeting.endTime != null)
                  _buildDetailRow(
                    'Time',
                    '${meeting.startTime!.format(context)} - ${meeting.endTime!.format(context)}',
                    Icons.access_time,
                    theme,
                  ),
                _buildDetailRow(
                  'Venue',
                  meeting.venue,
                  Icons.location_on,
                  theme,
                ),
                _buildDetailRow(
                  'Expected Attendees',
                  '${meeting.expectedAttendees}',
                  Icons.people,
                  theme,
                ),
                _buildDetailRow(
                  'Status',
                  meeting.status.toUpperCase(),
                  _getStatusIcon(meeting.status),
                  Theme.of(context)
                ),
                SizedBox(height: 20),
                if (isActionable) ...[
                  Text(
                    'Admin Actions:',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          _manageAttendance(meeting);
                        },
                        icon: Icon(Icons.how_to_reg),
                        label: Text('Mark Attendance'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          _manageFinancials(meeting);
                        },
                        icon: Icon(Icons.payments),
                        label: Text('Collect Fees'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
                // Add other actions like Edit/Cancel if relevant for the detailed view
                if (meeting.status == 'scheduled' && !isActionable) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _editMeeting(meeting);
                        },
                        icon: Icon(Icons.edit),
                        label: Text('Edit Meeting'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondary,
                            foregroundColor: Colors.white),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _cancelMeeting(meeting);
                        },
                        icon: Icon(Icons.cancel),
                        label: Text('Cancel Meeting'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(
      String label, String value, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.primaryColor),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled': // Renamed from 'upcoming' in your new model
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'scheduled':
        return Icons.schedule;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  void _manageAttendance(Meeting meeting) {
    List<MeetingAttendance> attendanceRecords = _chamaMembers.map((member) {
      // In a real app, you'd fetch existing attendance for this meeting and member
      return MeetingAttendance(
        id: '${meeting.id}-${member['id']}',
        meetingId: meeting.id!,
        memberId: member['id']!,
        memberName: member['name']!,
        isPresent: false, // Default or pre-populate from fetched data
      );
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Mark Attendance for ${meeting.agenda}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: attendanceRecords.length,
                      itemBuilder: (context, index) {
                        final record = attendanceRecords[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 4.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    record.memberName,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                Switch(
                                  value: record.isPresent,
                                  onChanged: (bool value) {
                                    setModalState(() {
                                      record.isPresent = value;
                                      if (value) {
                                        // Simulate recording check-in time
                                        // record.checkInTime = DateTime.now();
                                      }
                                    });
                                    // In a real app, update this on your backend
                                    print(
                                        '${record.memberName} is now ${record.isPresent ? 'Present' : 'Absent'}');
                                  },
                                ),
                                Text(record.isPresent ? 'Present' : 'Absent'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Logic to save attendance records to API
                      print('Attendance saved for ${meeting.agenda}');
                      // After saving, you might want to refresh the meeting list
                      // _refreshMeetings();
                      Navigator.pop(context);
                    },
                    child: Text('Save Attendance'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _manageFinancials(Meeting meeting) {
    Map<String, double> memberContributions = {};
    _chamaMembers.forEach((member) {
      memberContributions[member['id']!] = 0.0; // Default no contribution
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Collect Fees for ${meeting.agenda}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _chamaMembers.length,
                      itemBuilder: (context, index) {
                        final member = _chamaMembers[index];
                        final memberId = member['id']!;
                        final memberName = member['name']!;
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 4.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    memberName,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d+\.?\d{0,2}')),
                                    ],
                                    decoration: InputDecoration(
                                      hintText: '0.00',
                                      prefixText: 'Ksh ',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                    onChanged: (value) {
                                      setModalState(() {
                                        memberContributions[memberId] =
                                            double.tryParse(value) ?? 0.0;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Logic to save financial records to API
                      double totalCollected = memberContributions.values
                          .fold(0.0, (sum, amount) => sum + amount);
                      print(
                          'Fees collected for ${meeting.agenda}: Ksh ${totalCollected.toStringAsFixed(2)}');
                      memberContributions.forEach((memberId, amount) {
                        if (amount > 0) {
                          print(
                              '${_chamaMembers.firstWhere((m) => m['id'] == memberId)['name']}: Ksh ${amount.toStringAsFixed(2)}');
                        }
                      });
                      // After saving, you might want to refresh the meeting list
                      // _refreshMeetings();
                      Navigator.pop(context);
                    },
                    child: Text('Save Contributions'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _editMeeting(Meeting meeting) {
    // Navigate to a dedicated edit meeting page or show a dialog
    print('Edit meeting: ${meeting.agenda}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit functionality for ${meeting.agenda}')),
    );
    // You would typically show a form similar to CreateMeetingForm,
    // pre-filled with meeting data, and call _refreshMeetings on success.
  }

  void _cancelMeeting(Meeting meeting) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Meeting'),
        content: Text(
          'Are you sure you want to cancel "${meeting.agenda}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              // In a real app, call your API to update the meeting status to 'cancelled'
              // Then refresh the local data
              print('Attempting to cancel meeting: ${meeting.id}');
              // Simulate API call success
              setState(() {
                final index = _allMeetings.indexWhere((m) => m.id == meeting.id);
                if (index != -1) {
                  _allMeetings[index] = _allMeetings[index].copyWith(status: 'cancelled');
                  _filterMeetings(); // Re-filter after status update
                }
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Meeting cancelled successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}