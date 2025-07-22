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
  late Meeting meeting;

  // User-specific data
  String _userAttendanceStatus = 'present';
  bool _hasPaidMeetingFee = false;
  bool _hasContributedMonthly = false;
  bool _hasFine = true;
  double _fineAmount = 500.00;
  double _userPaidMeetingFeeAmount = 0.00;
  double _userMonthlyContributionAmount = 0.00;
  int _presentMembersCount = 15;
  final double _totalMeetingFee = 200.00;
  final double _totalMonthlyContribution = 1000.00;
  late Future<MeetingDetails> _meetingDetailsFuture;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMeetingData();
    getMeetingDetails();
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
      _userAttendanceStatus = 'present';
      _hasPaidMeetingFee = false;
      _hasContributedMonthly = false;
      _hasFine = true;
      _fineAmount = 500.00;
      _userPaidMeetingFeeAmount = 0.00;
      _userMonthlyContributionAmount = 0.00;
      _presentMembersCount = 15;
    });
  }

  Future<Meeting?> _getTodayMeeting() async {
    try {
      final results = await comms.getRequests(endpoint: "meeting/today");

      if (results["rsp"]["success"]) {
        meeting = Meeting.fromJson(results["rsp"]["data"]);
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

  void getMeetingDetails() {
    _meetingDetailsFuture = comms
        .getRequests(endpoint: "meeting/details/${meeting.id}")
        .then((result) {
          if (result["rsp"]["success"]) {
            return MeetingDetails.fromJson(result["rsp"]["data"]);
          } else {
            throw Exception(result["rsp"]["message"]);
          }
        })
        .catchError((error) {
          showalert(
            success: false,
            context: context,
            title: "Error",
            subtitle: "Failed to load meeting details: $error",
          );
        });
  }

  void _showMpesaPaymentDialog(
    BuildContext context, {
    required String paymentType,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Pay $paymentType via M-Pesa',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount (KSH)',
                    hintText: 'e.g., 500',
                    prefixIcon: Icon(
                      Icons.attach_money_rounded,
                      color: colorScheme.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number (e.g., 2547XXXXXXXX)',
                    hintText: 'e.g., 2547XXXXXXXX',
                    prefixIcon: Icon(
                      Icons.phone_android_rounded,
                      color: colorScheme.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _amountController.clear();
                _phoneNumberController.clear();
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Cancel',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(_amountController.text);
                final phoneNumber = _phoneNumberController.text;

                if (amount != null && phoneNumber.isNotEmpty) {
                  showalert(
                    success: true,
                    context: context,
                    title: "M-Pesa Push Initiated",
                    subtitle:
                        "Request sent to $phoneNumber for KSH ${amount.toStringAsFixed(2)}. Check your phone.",
                  );
                  Navigator.of(dialogContext).pop();
                  _amountController.clear();
                  _phoneNumberController.clear();

                  setState(() {
                    if (paymentType == 'Meeting Fee') {
                      _hasPaidMeetingFee = true;
                      _userPaidMeetingFeeAmount = amount;
                    } else if (paymentType == 'Monthly Contribution') {
                      _hasContributedMonthly = true;
                      _userMonthlyContributionAmount = amount;
                    } else if (paymentType == 'Fine') {
                      _hasFine = false;
                      _fineAmount = 0.00;
                    }
                  });
                } else {
                  showalert(
                    success: false,
                    context: context,
                    title: "Missing Details",
                    subtitle:
                        "Please enter both amount and a valid phone number.",
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Pay Now',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        );
      },
    );
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
      body: FutureBuilder<Meeting?>(
        future: _meetingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            );
          } else if (snapshot.hasError) {
            return _buildErrorState(context);
          } else if (snapshot.hasData && snapshot.data != null) {
            final meeting = snapshot.data!;
            return _buildMeetingDetails(context, meeting, theme, colorScheme);
          } else {
            return _buildNoMeetingState(context);
          }
        },
      ),
    );
  }

  Widget _buildMeetingDetails(
    BuildContext context,
    Meeting meeting,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Meeting Header with Status
          _buildMeetingHeader(context, meeting, theme, colorScheme),

          // Payment Status Cards (Most Important - Top Priority)
          _buildPaymentStatusSection(context, theme, colorScheme),

          // Quick Actions (Join/Edit Meeting)
          if (meeting.status == 'scheduled' || meeting.status == 'ongoing')
            // _buildQuickActions(context, meeting, theme, colorScheme),
            // Meeting Essential Info
            _buildEssentialMeetingInfo(context, meeting, theme, colorScheme),

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
                '${_formatTimeOfDay(meeting.startTime)} - ${_formatTimeOfDay(meeting.endTime)}',
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
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    List<Widget> pendingPayments = [];

    if (!_hasPaidMeetingFee) {
      pendingPayments.add(
        _buildPaymentCard(
          context,
          title: 'Meeting Fee',
          amount: _totalMeetingFee,
          icon: Icons.event_note,
          color: AppColors.info,
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
        ),
      );
    }

    if (!_hasContributedMonthly) {
      pendingPayments.add(
        _buildPaymentCard(
          context,
          title: 'Monthly Contribution',
          amount: _totalMonthlyContribution,
          icon: Icons.savings,
          color: colorScheme.primary,
          onTap:
              () => _showMpesaPaymentDialog(
                context,
                paymentType: 'Monthly Contribution',
              ),
          theme: theme,
        ),
      );
    }

    if (_hasFine) {
      pendingPayments.add(
        _buildPaymentCard(
          context,
          title: 'Outstanding Fine',
          amount: _fineAmount,
          icon: Icons.warning_amber,
          color: AppColors.error,
          onTap: () => _showMpesaPaymentDialog(context, paymentType: 'Fine'),
          theme: theme,
          subtitle: 'Late arrival fee',
        ),
      );
    }

    if (pendingPayments.isEmpty) {
      return _buildAllPaidCard(context, theme, colorScheme);
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
            child: Row(
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
          ),
        ),
      ),
    );
  }

  Widget _buildAllPaidCard(
    BuildContext context,
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
                      'You\'re all set for today\'s meeting',
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

  // Widget _buildQuickActions(BuildContext context, Meeting meeting, ThemeData theme, ColorScheme colorScheme) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 20),
  //     child: Row(
  //       children: [
  //         Expanded(
  //           flex: 2,
  //           child: ElevatedButton.icon(
  //             onPressed: () {
  //               showalert(success: true, context: context, title: "Joining Meeting", subtitle: "Attempting to join the meeting...");
  //             },
  //             icon: Icon(Icons.videocam, color: colorScheme.onPrimary),
  //             label: Text('Join Meeting', style: TextStyle(color: colorScheme.onPrimary)),
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: colorScheme.primary,
  //               padding: const EdgeInsets.symmetric(vertical: 16),
  //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //             ),
  //           ),
  //         ),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: OutlinedButton.icon(
  //             onPressed: () {
  //               showalert(success: false, context: context, title: "Edit Meeting", subtitle: "Navigating to edit meeting page.");
  //             },
  //             icon: Icon(Icons.edit, color: colorScheme.primary),
  //             label: Text('Edit', style: TextStyle(color: colorScheme.primary)),
  //             style: OutlinedButton.styleFrom(
  //               side: BorderSide(color: colorScheme.primary),
  //               padding: const EdgeInsets.symmetric(vertical: 16),
  //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildEssentialMeetingInfo(
    BuildContext context,
    Meeting meeting,
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
                Icons.group,
                'Attendance',
                '$_presentMembersCount members present',
                theme,
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                context,
                Icons.person,
                'Organizer',
                meeting.createdByName!,
                theme,
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                context,
                Icons.account_circle,
                'Your Status',
                _userAttendanceStatus.toUpperCase(),
                theme,
              ),
            ],
          ),
        ),
      ),
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              color: colorScheme.onBackground.withOpacity(0.6),
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Connection Error',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load meeting details',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchMeetingData,
              icon: Icon(Icons.refresh_rounded),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy_outlined,
              color: colorScheme.onBackground.withOpacity(0.6),
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'No Meeting Today',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'There are no meetings scheduled for today',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchMeetingData,
              icon: Icon(Icons.refresh_rounded),
              label: Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return 'N/A';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('h:mm a').format(dt);
  }
}
