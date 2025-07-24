import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mbari/ADMIN/Alerts/MeetingDetails.dart';
import 'package:mbari/core/constants/constants.dart';
import 'package:mbari/data/models/Meeting.dart';
import 'package:mbari/data/services/globalFetch.dart';

class UserMeetingPage extends StatefulWidget {
  @override
  _UserMeetingPageState createState() => _UserMeetingPageState();
}

class _UserMeetingPageState extends State<UserMeetingPage> {
  late Future<List<Meeting>> _meetingsFuture;

  @override
  void initState() {
    super.initState();
    _meetingsFuture = fetchMeetings();
  }

  Future<List<Meeting>> fetchMeetings() async {
    final response = await fetchGlobal<Meeting>(
      getRequests: (endpoint) => comms.getRequests(endpoint: endpoint),
      fromJson: (json) => Meeting.fromJson(json),
      endpoint: "meeting/my-chama/meetings",
    );
    return response;
  }

  bool get _isMobile => MediaQuery.of(context).size.width < 768;
  double get _horizontalPadding => _isMobile ? 16.0 : 32.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.all(_horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            SizedBox(height: _isMobile ? 16 : 32),
            Expanded(
              child: FutureBuilder<List<Meeting>>(
                future: _meetingsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: theme.primaryColor,
                      ),
                    );
                  }
                  
                  if (snapshot.hasError) {
                    return _buildErrorState(theme, snapshot.error.toString());
                  }
                  
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState(theme);
                  }

                  return _buildMeetingsContent(snapshot.data!, theme);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final titleStyle = theme.textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: _isMobile ? 28 : 32,
    );

    if (_isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Meetings', style: titleStyle),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _createMeeting(),
              icon: Icon(Icons.add),
              label: Text("Create Meeting"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Meetings', style: titleStyle),
        ElevatedButton.icon(
          onPressed: () => _createMeeting(),
          icon: Icon(Icons.add),
          label: Text("Create Meeting"),
        ),
      ],
    );
  }

  Widget _buildMeetingsContent(List<Meeting> meetings, ThemeData theme) {
    final now = DateTime.now();
    final upcomingMeetings = meetings
        .where((m) => m.meetingDate.isAfter(now) || m.status == 'scheduled')
        .toList()
      ..sort((a, b) => a.meetingDate.compareTo(b.meetingDate));
    
    final pastMeetings = meetings
        .where((m) => m.meetingDate.isBefore(now) && m.status != 'scheduled')
        .toList()
      ..sort((a, b) => b.meetingDate.compareTo(a.meetingDate));

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _meetingsFuture = fetchMeetings();
        });
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMeetingSection(
              'Upcoming Meetings', 
              upcomingMeetings, 
              true, 
              theme,
              Icons.upcoming,
            ),
            SizedBox(height: 32),
            _buildMeetingSection(
              'Past Meetings', 
              pastMeetings, 
              false, 
              theme,
              Icons.history,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetingSection(
    String title, 
    List<Meeting> meetings, 
    bool isUpcoming, 
    ThemeData theme,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon, 
              color: theme.primaryColor,
              size: _isMobile ? 20 : 24,
            ),
            SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: _isMobile ? 20 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${meetings.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        meetings.isEmpty 
          ? _buildEmptyMeetingsList(isUpcoming, theme)
          : _buildMeetingList(meetings, isUpcoming, theme),
      ],
    );
  }

  Widget _buildEmptyMeetingsList(bool isUpcoming, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            isUpcoming ? Icons.event_available : Icons.history,
            size: 48,
            color: theme.disabledColor,
          ),
          SizedBox(height: 16),
          Text(
            'No ${isUpcoming ? 'upcoming' : 'past'} meetings',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.disabledColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isUpcoming) ...[
            SizedBox(height: 8),
            Text(
              'Create your first meeting to get started',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.disabledColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMeetingList(List<Meeting> meetings, bool isUpcoming, ThemeData theme) {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: meetings.length,
      separatorBuilder: (context, index) => SizedBox(height: 12),
      itemBuilder: (context, index) => _buildMeetingCard(meetings[index], theme),
    );
  }

  Widget _buildMeetingCard(Meeting meeting, ThemeData theme) {
    final isToday = _isToday(meeting.meetingDate);
    final isUpcoming = meeting.meetingDate.isAfter(DateTime.now());
    final timeUntil = _getTimeUntilMeeting(meeting.meetingDate);

    return Card(
      elevation: 2,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isToday 
          ? BorderSide(color: theme.primaryColor, width: 2)
          : BorderSide(color: theme.dividerColor),
      ),
      child: InkWell(
        onTap: () => _showMeetingDetails(meeting),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateSection(meeting.meetingDate, theme, isToday),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildMeetingInfo(meeting, theme, timeUntil, isUpcoming),
                  ),
                  _buildStatusBadge(meeting.status, theme),
                ],
              ),
              if (meeting.venue.isNotEmpty) ...[
                SizedBox(height: 12),
                _buildVenueInfo(meeting.venue, theme),
              ],
              if (isUpcoming && timeUntil.isNotEmpty) ...[
                SizedBox(height: 8),
                _buildTimeUntilInfo(timeUntil, theme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSection(DateTime date, ThemeData theme, bool isToday) {
    return Container(
      width: 65,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: isToday 
          ? theme.primaryColor.withOpacity(0.1)
          : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: isToday 
          ? Border.all(color: theme.primaryColor.withOpacity(0.3))
          : null,
      ),
      child: Column(
        children: [
          Text(
            DateFormat('MMM').format(date).toUpperCase(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: isToday ? theme.primaryColor : theme.textTheme.bodySmall?.color,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 2),
          Text(
            DateFormat('dd').format(date),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isToday ? theme.primaryColor : theme.textTheme.headlineSmall?.color,
            ),
          ),
          Text(
            DateFormat('yyyy').format(date),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingInfo(Meeting meeting, ThemeData theme, String timeUntil, bool isUpcoming) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          meeting.agenda,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 6),
        if (meeting.startTime != null || meeting.endTime != null)
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: theme.textTheme.bodySmall?.color),
              SizedBox(width: 4),
              Text(
                _formatTimeRange(meeting.startTime, meeting.endTime),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.person, size: 16, color: theme.textTheme.bodySmall?.color),
            SizedBox(width: 4),
            Expanded(
              child: Text(
                'Created by ${meeting.createdByName ?? 'Unknown'}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (meeting.chamaName != null) ...[
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.group, size: 16, color: theme.textTheme.bodySmall?.color),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  meeting.chamaName!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildVenueInfo(String venue, ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, size: 16, color: theme.primaryColor),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              venue,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUntilInfo(String timeUntil, ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        timeUntil,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, ThemeData theme) {
    final statusInfo = _getStatusInfo(status);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: statusInfo['color'],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusInfo['icon'],
            size: 12,
            color: Colors.white,
          ),
          SizedBox(width: 4),
          Text(
            statusInfo['text'],
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color:Colors.red),
          SizedBox(height: 16),
          Text(
            'Error loading meetings',
            style: theme.textTheme.headlineSmall,
          ),
          SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _meetingsFuture = fetchMeetings();
              });
            },
            icon: Icon(Icons.refresh),
            label: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note, size: 64, color: theme.disabledColor),
          SizedBox(height: 16),
          Text(
            'No meetings found',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.disabledColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Create your first meeting to get started',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.disabledColor,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _createMeeting(),
            icon: Icon(Icons.add),
            label: Text('Create Meeting'),
          ),
        ],
      ),
    );
  }

  void _showMeetingDetails(Meeting meeting) {
    showModalBottomSheet(
      showDragHandle: true,
      enableDrag: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => MeetingDetailsContent(meeting: meeting),
    );
  }

  void _createMeeting() {
    // TODO: Navigate to create meeting page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Create meeting functionality coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return {
          'text': 'Completed',
          'color': Colors.green,
          'icon': Icons.check_circle,
        };
      case 'scheduled':
        return {
          'text': 'Scheduled',
          'color': Colors.blue,
          'icon': Icons.schedule,
        };
      case 'cancelled':
        return {
          'text': 'Cancelled',
          'color': Colors.red,
          'icon': Icons.cancel,
        };
      case 'in_progress':
        return {
          'text': 'In Progress',
          'color': Colors.orange,
          'icon': Icons.play_circle,
        };
      default:
        return {
          'text': status,
          'color': Colors.grey,
          'icon': Icons.help,
        };
    }
  }

  String _formatTimeRange(TimeOfDay? startTime, TimeOfDay? endTime) {
    if (startTime == null && endTime == null) return '';
    if (startTime != null && endTime != null) {
      return '${startTime.format(context)} - ${endTime.format(context)}';
    }
    if (startTime != null) return '${startTime.format(context)}';
    return 'Ends at ${endTime!.format(context)}';
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  String _getTimeUntilMeeting(DateTime meetingDate) {
    final now = DateTime.now();
    final difference = meetingDate.difference(now);
    
    if (difference.inDays > 0) {
      return 'In ${difference.inDays} day${difference.inDays == 1 ? '' : 's'}';
    } else if (difference.inHours > 0) {
      return 'In ${difference.inHours} hour${difference.inHours == 1 ? '' : 's'}';
    } else if (difference.inMinutes > 0) {
      return 'In ${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'}';
    } else if (difference.inMinutes > -60) {
      return 'Starting now';
    }
    return '';
  }
}