import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mbari/ADMIN/Create/CreateMeeting.dart';
import 'package:mbari/core/constants/constants.dart';
import 'package:mbari/core/theme/AppColors.dart';
import 'package:mbari/core/utils/Alerts.dart';
import 'package:mbari/data/models/Meeting.dart';
import 'package:mbari/data/models/UserMeetingStats.dart';
import 'package:mbari/features/UserMeeting.dart/MpesaPayment.dart';

class MeetingDetailsPage extends StatefulWidget {
  const MeetingDetailsPage({Key? key}) : super(key: key);

  @override
  State<MeetingDetailsPage> createState() => _MeetingDetailsPageState();
}

class _MeetingDetailsPageState extends State<MeetingDetailsPage> {
  Future<Meeting?>? _meetingFuture;
  late Future<MeetingDetails> _meetingDetailsFuture;

  // Meeting fee and contribution standards (could be from settings/config)
  final double _standardMeetingFee = user.meetingFee;
  final double _standardMonthlyContribution = user.monthlyContribution;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMeetingData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  void _fetchMeetingData() {
    setState(() {
      _meetingFuture = _getTodayMeeting();
    });
  }

  Future<Meeting?> _getTodayMeeting() async {
    try {
      final results = await comms.getRequests(endpoint: "meeting/today");

      if (results["rsp"]["success"]) {
        meeting = Meeting.fromJson(results["rsp"]["data"]);
        // Initialize meeting details future after getting meeting
        _meetingDetailsFuture = _getMeetingDetails();
        showalert(
          success: true,
          context: context,
          title: "Success",
          subtitle: results["rsp"]["message"],
        );
        return meeting;
      } else {
        final String message =
            results["rsp"]["message"] ?? "No meeting found for today.";
        showalert(
          success: false,
          context: context,
          title: "No Meeting Found",
          subtitle: message,
        );
        return null;
      }
    } catch (e) {
      final String errorMessage = "An error occurred: $e";
      showalert(
        success: false,
        context: context,
        title: "Error",
        subtitle: "Failed to load meeting: $errorMessage",
      );
      return null;
    }
  }

  Future<MeetingDetails> _getMeetingDetails() async {
    try {
      final result = await comms.getRequests(
        endpoint: "meeting/member/${meeting.id}",
      );
      if (result["rsp"]["success"]) {
        return MeetingDetails.fromJson(result["rsp"]["data"]);
      } else {
        throw Exception(result["rsp"]["message"]);
      }
    } catch (error) {
      showalert(
        success: false,
        context: context,
        title: "Error",
        subtitle: "Failed to load meeting details: $error",
      );
      rethrow;
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onBackground,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Today\'s Meeting',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _fetchMeetingData();
          _getMeetingDetails();
        },

        child: FutureBuilder<Meeting?>(
          future: _meetingFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return _buildErrorState(context);
            } else if (snapshot.hasData && snapshot.data != null) {
              final meeting = snapshot.data!;
              return _buildMeetingDetailsWithFuture(
                context,
                meeting,
                theme,
                colorScheme,
              );
            } else {
              return _buildNoMeetingState(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildMeetingDetailsWithFuture(
    BuildContext context,
    Meeting meeting,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return FutureBuilder<MeetingDetails>(
      future: _meetingDetailsFuture,
      builder: (context, detailsSnapshot) {
        if (detailsSnapshot.connectionState == ConnectionState.waiting) {
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildMeetingHeader(context, meeting, theme, colorScheme),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (detailsSnapshot.hasError) {
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildMeetingHeader(context, meeting, theme, colorScheme),
                _buildErrorState(context),
              ],
            ),
          );
        } else if (detailsSnapshot.hasData) {
          final meetingDetails = detailsSnapshot.data!;
          return _buildMeetingDetails(
            context,
            meeting,
            meetingDetails,
            theme,
            colorScheme,
          );
        } else {
          return _buildErrorState(context);
        }
      },
    );
  }

  Widget _buildMeetingDetails(
    BuildContext context,
    Meeting meeting,
    MeetingDetails meetingDetails,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Meeting Header with Status
          _buildMeetingHeader(context, meeting, theme, colorScheme),

          // Payment Status Cards (Most Important - Top Priority)
          _buildPaymentStatusSection(
            context,
            meetingDetails,
            theme,
            colorScheme,
          ),

          // Meeting Essential Info
          _buildEssentialMeetingInfo(
            context,
            meeting,
            meetingDetails,
            theme,
            colorScheme,
          ),

          // Additional Details (Collapsible or Secondary)
          _buildAdditionalDetails(context, meeting, theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildMeetingHeader(
    BuildContext context,
    Meeting meeting,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  user.chamaName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  meeting.status.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: colorScheme.onPrimary.withOpacity(0.9),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${_formatTimeOfDay(meeting.startTime!)} - ${_formatTimeOfDay(meeting.endTime!)}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onPrimary.withOpacity(0.9),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.location_on,
                color: colorScheme.onPrimary.withOpacity(0.9),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  meeting.venue,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onPrimary.withOpacity(0.9),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusSection(
    BuildContext context,
    MeetingDetails meetingDetails,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    List<Widget> pendingPayments = [];

    // Check if meeting fee is fully paid
    bool hasPaidMeetingFee =
        meetingDetails.meetingFees.total >= _standardMeetingFee;
    if (!hasPaidMeetingFee) {
      double remaining =
          _standardMeetingFee - meetingDetails.meetingFees.total.toDouble();
      pendingPayments.add(
        _buildPaymentCard(
          context,
          title: 'Meeting Fee',
          amount: remaining,
          paidAmount: meetingDetails.meetingFees.total.toDouble(),
          totalAmount: _standardMeetingFee,
          icon: Icons.event_note,
          color: AppColors.info,
          onTap:
              (){},
          theme: theme,
        ),
      );
    }

    // Check if monthly contribution is fully paid
    bool hasContributedMonthly =
        meetingDetails.contributions.total >= _standardMonthlyContribution;
    if (!hasContributedMonthly) {
      double remaining =
          _standardMonthlyContribution -
          meetingDetails.contributions.total.toDouble();
      pendingPayments.add(
        _buildPaymentCard(
          context,
          title: 'Monthly Contribution',
          amount: remaining,
          paidAmount: meetingDetails.contributions.total.toDouble(),
          totalAmount: _standardMonthlyContribution,
          icon: Icons.savings,
          color: colorScheme.primary,
          onTap:
              () =>showModalBottomSheet(
                showDragHandle: true,
                enableDrag: true,
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return MpesaPaymentDialog(
                    onPaymentSuccess: (status) {
                      if (status) {
                        // Refresh contributions after successful payment
                        setState(() {
                          _fetchMeetingData();
                          _getMeetingDetails();
                        });
                      }
                    },
                  );
                },
              ),
          theme: theme,
        ),
      );
    }

    // Check if there are outstanding fines
    bool hasFines = meetingDetails.summary.outstandingFines > 0;
    if (hasFines) {
      pendingPayments.add(
        _buildPaymentCard(
          context,
          title: 'Outstanding Fine',
          amount: meetingDetails.summary.outstandingFines.toDouble(),
          icon: Icons.warning_amber,
          color: AppColors.error,
          onTap:
              () => showModalBottomSheet(
                showDragHandle: true,
                enableDrag: true,
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return MpesaPaymentDialog();
                },
              ),
          theme: theme,
          subtitle: 'Total outstanding fines',
        ),
      );
    }

    if (pendingPayments.isEmpty) {
      return _buildAllPaidCard(context, meetingDetails, theme, colorScheme);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Required',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onBackground,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...pendingPayments,
        ],
      ),
    );
  }

  Widget _buildPaymentCard(
    BuildContext context, {
    required String title,
    required double amount,
    double? paidAmount,
    double? totalAmount,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required ThemeData theme,
    String? subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          if (paidAmount != null && totalAmount != null)
                            Text(
                              'Paid: KSH ${paidAmount.toStringAsFixed(2)} of ${totalAmount.toStringAsFixed(2)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'KSH ${amount.toStringAsFixed(2)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'PAY NOW',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Progress bar for partial payments
                if (paidAmount != null && totalAmount != null && paidAmount > 0)
                  Column(
                    children: [
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: paidAmount / totalAmount,
                        backgroundColor: color.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAllPaidCard(
    BuildContext context,
    MeetingDetails meetingDetails,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Card(
        elevation: 2,
        color: AppColors.successLight.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Payments Complete!',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Total contributed: KSH ${meetingDetails.summary.totalFinancialActivity}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEssentialMeetingInfo(
    BuildContext context,
    Meeting meeting,
    MeetingDetails meetingDetails,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Meeting Overview',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoRow(
                context,
                Icons.calendar_today,
                'Date',
                DateFormat('EEEE, MMM d, yyyy').format(meeting.meetingDate),
                theme,
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                context,
                Icons.person,
                'Organizer',
                meeting.createdByName ?? 'N/A',
                theme,
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                context,
                Icons.account_circle,
                'Your Status',
                meetingDetails.attendance.status.toUpperCase(),
                theme,
              ),
              if (meetingDetails.attendance.checkInTime != null) ...[
                const SizedBox(height: 16),
                _buildInfoRow(
                  context,
                  Icons.login,
                  'Check-in Time',
                  DateFormat(
                    'h:mm a',
                  ).format(meetingDetails.attendance.checkInTime!),
                  theme,
                ),
              ],
              const SizedBox(height: 20),
              Text(
                'Financial Summary',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildFinancialSummaryRow(
                'Meeting Fees Paid',
                'KSH ${meetingDetails.meetingFees.total}',
                Icons.event_note,
                theme,
              ),
              const SizedBox(height: 8),
              _buildFinancialSummaryRow(
                'Contributions Made',
                'KSH ${meetingDetails.contributions.total}',
                Icons.savings,
                theme,
              ),
              const SizedBox(height: 8),
              _buildFinancialSummaryRow(
                'Outstanding Fines',
                'KSH ${meetingDetails.summary.outstandingFines}',
                Icons.warning_amber,
                theme,
                color:
                    meetingDetails.summary.outstandingFines > 0
                        ? AppColors.error
                        : AppColors.success,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialSummaryRow(
    String label,
    String value,
    IconData icon,
    ThemeData theme, {
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color ?? theme.colorScheme.primary, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalDetails(
    BuildContext context,
    Meeting meeting,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Agenda Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ExpansionTile(
              leading: Icon(Icons.assignment, color: colorScheme.primary),
              title: Text(
                'Meeting Agenda',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    meeting.agenda,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Past Minutes Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: Icon(Icons.description, color: colorScheme.primary),
              title: Text(
                'Previous Meeting Minutes',
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Text('View minutes from last meeting'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                showalert(
                  success: true,
                  context: context,
                  title: "View Minutes",
                  subtitle: "Opening minutes link: ${meeting.agenda}",
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to load meeting details. Please try again.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _fetchMeetingData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoMeetingState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              'No Meeting Today',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'There are no scheduled meetings for today. Check back later or contact your group administrator.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _fetchMeetingData();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                if (false) // Assuming admin check
                  OutlinedButton.icon(
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const CreateMeetingPage(),
                      //   ),
                      // );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Meeting'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt);
  }
}
