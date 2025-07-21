import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mbari/ADMIN/Create/CreateMeeting.dart';
import 'package:mbari/core/constants/constants.dart'; // Assuming 'comms' is defined here
import 'package:mbari/core/theme/AppColors.dart'; // Assuming custom AppColors are here
import 'package:mbari/core/utils/Alerts.dart'; // Assuming 'showalert' is defined here
import 'package:mbari/data/models/Meeting.dart';
import 'package:mbari/features/UserMeeting.dart/MpesaPayment.dart'; // Your Meeting class definition

// The MeetingDetailsPage and its State class from your previous code
// remain mostly the same, with additions within the _MeetingDetailsPageState.

class MeetingDetailsPage extends StatefulWidget {
  const MeetingDetailsPage({Key? key}) : super(key: key);

  @override
  State<MeetingDetailsPage> createState() => _MeetingDetailsPageState();
}

class _MeetingDetailsPageState extends State<MeetingDetailsPage> {
  Future<Meeting?>? _meetingFuture; // Changed to Meeting? to handle null case
  // String? msg; // No longer needed as we explicitly handle null for meetingFuture

  // Controllers for M-Pesa payment dialog fields
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  // Dummy variable to control the "You have not paid meeting fee" message visibility.
  // In a real application, this would be determined by backend data
  // (e.g., a field in the Meeting object or user's payment status).
  bool _userHasOutstandingFees = true;

  // Placeholder for a global 'meeting' variable that seems to be used elsewhere.
  // In a real app, you might pass this around or use a state management solution.
  // For this refactor, we'll keep it as a late variable to satisfy its usage.
  late Meeting meeting;

  @override
  void initState() {
    super.initState();
    _fetchMeetingData(); // Initiate the fetch when the widget is created
  }

  @override
  void dispose() {
    _amountController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  /// Initiates the fetching of today's meeting details.
  /// Sets the `_meetingFuture` which the `FutureBuilder` observes.
  void _fetchMeetingData() {
    setState(() {
      _meetingFuture = _getTodayMeeting();
    });
  }

  /// Fetches today's meeting details from the API.
  /// Returns `null` if no meeting is found or on error, after showing an alert.
  /// Returns `Meeting` object on success.
  Future<Meeting?> _getTodayMeeting() async {
    try {
      final results = await comms.getRequests(endpoint: "meeting/today");

      if (results["rsp"]["success"]) {
        // Assume 'meeting' global variable needs to be set if used elsewhere
        meeting = Meeting.fromJson(results["rsp"]["data"]);
        showalert(
          success: true,
          context: context,
          title: "Success",
          subtitle: results["rsp"]["message"],
        );
        return meeting; // Return the fetched meeting
      } else {
        // No meeting found for today or API indicated failure
        final String message =
            results["rsp"]["message"] ?? "No meeting found for today.";
        showalert(
          success: false,
          context: context,
          title: "No Meeting Found",
          subtitle: message,
        );
        return null; // Explicitly return null if no meeting
      }
    } catch (e) {
      // Handle network or parsing errors
      final String errorMessage = "An error occurred: $e";
      showalert(
        success: false,
        context: context,
        title: "Error",
        subtitle: "Failed to load meeting: $errorMessage",
      );
      return null; // Return null on error
    }
  }

  /// Shows an M-Pesa payment dialog.
  void _showMpesaPaymentDialog(BuildContext context) {
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
            'Add Contribution via M-Pesa',
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
                // TODO: Implement M-Pesa SDK push logic here
                final amount = _amountController.text;
                final phoneNumber = _phoneNumberController.text;

                if (amount.isNotEmpty && phoneNumber.isNotEmpty) {
                  showalert(
                    success: true,
                    context: context,
                    title: "M-Pesa Push Initiated",
                    subtitle:
                        "Request sent to $phoneNumber for KSH $amount. Check your phone.",
                  );
                  Navigator.of(dialogContext).pop();
                  _amountController.clear();
                  _phoneNumberController.clear();

                  // Optionally, update the UI if contribution changes outstanding fees
                  setState(() {
                    _userHasOutstandingFees = false; // Simulate fee paid
                  });
                } else {
                  showalert(
                    success: false,
                    context: context,
                    title: "Missing Details",
                    subtitle: "Please enter both amount and phone number.",
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
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent to show background
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onBackground,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Meeting Details',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, // Center the title
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
            return _buildErrorOrNoMeetingState(
              context,
              icon: Icons.wifi_off_rounded,
              title: 'Connection Error',
              message:
                  'Failed to load meeting details. Please check your internet connection.',
              retryAction: _fetchMeetingData,
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            final meeting = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chama Name and Meeting Status Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          meeting.chamaName ?? 'Unknown Chama',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: colorScheme.onBackground,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            meeting.status,
                            colorScheme,
                          ).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          meeting.status.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _getStatusColor(meeting.status, colorScheme),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Organized by ${meeting.createdByName}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Meeting Overview Card
                  _buildDetailCard(
                    context,
                    children: [
                      _buildDetailRow(
                        context,
                        icon: Icons.calendar_today_outlined,
                        label: 'Date',
                        value: DateFormat(
                          'EEEE, MMM d, yyyy',
                        ).format(meeting.meetingDate),
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        context,
                        icon: Icons.access_time_outlined,
                        label: 'Time',
                        value:
                            '${_formatTimeOfDay(meeting.startTime)} - ${_formatTimeOfDay(meeting.endTime)}',
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        context,
                        icon: Icons.location_on_outlined,
                        label: 'Venue',
                        value: meeting.venue,
                        colorScheme: colorScheme,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Agenda Section
                  Text(
                    'Agenda',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailCard(
                    context,
                    children: [
                      Text(
                        meeting.agenda,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.9),
                          height: 1.5, // Line height for readability
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // NEW: "You have not paid meeting fee" section
                  if (_userHasOutstandingFees)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 20.0,
                      ), // Padding below it
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(
                            0.1,
                          ), // Light red background
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: AppColors.error.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: AppColors.error,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'You have not paid the meeting fee for this session.',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color:
                                      AppColors
                                          .error, // Using AppColors.error for text color
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // NEW: Add Contribution Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          showDragHandle: true,
                          enableDrag: true,
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return MpesaPaymentDialog();
                          },
                        );
                      },
                      icon: Icon(
                        Icons.add_circle_outline_rounded,
                        color: colorScheme.onPrimary,
                      ),
                      label: Text(
                        'Add Contribution',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onPrimary,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors
                                .successLight, // A distinct color for contributions
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // NEW: Pay Fine Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement pay fine logic
                        print('Paying fine...');
                        showalert(
                          success: true,
                          context: context,
                          title: "Pay Fine",
                          subtitle: "Fine payment initiated (mock).",
                        );
                      },
                      icon: Icon(
                        Icons.monetization_on_outlined,
                        color: colorScheme.primary,
                      ),
                      label: Text(
                        'Pay Fine',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: colorScheme.primary.withOpacity(0.6),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Existing Action Buttons (Join, Edit) - Adjust placement as needed
                  if (meeting.status == 'scheduled' ||
                      meeting.status == 'ongoing')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implement join meeting logic
                          print('Joining meeting...');
                        },
                        icon: Icon(
                          Icons.videocam_outlined,
                          color: colorScheme.onPrimary,
                        ),
                        label: Text(
                          'Join Meeting',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.onPrimary,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 6,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement edit meeting logic
                        print('Editing meeting...');
                      },
                      icon: Icon(
                        Icons.edit_outlined,
                        color: colorScheme.primary,
                      ),
                      label: Text(
                        'Edit Meeting',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: colorScheme.primary.withOpacity(0.6),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          } else {
            // No meeting found or data is null
            return _buildErrorOrNoMeetingState(
              context,
              icon: Icons.event_busy_outlined,
              title: 'No Meeting Scheduled',
              message: 'There are no meetings scheduled for today.',
              retryAction: _fetchMeetingData,
            );
          }
        },
      ),
    );
  }

  // --- Helper Widgets and Methods (from previous refactor) ---

  /// Helper widget to display error or no meeting state with a customizable message and action.
  Widget _buildErrorOrNoMeetingState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    required VoidCallback retryAction,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: colorScheme.onBackground.withOpacity(0.6),
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onBackground.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: retryAction,
              icon: Icon(Icons.refresh_rounded, color: colorScheme.onPrimary),
              label: Text(
                'Refresh',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onPrimary,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
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

  // Helper to format TimeOfDay
  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return 'N/A';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('h:mm a').format(dt);
  }

  // Helper to get status color
  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return AppColors.info; // Blue for scheduled
      case 'ongoing':
        return AppColors.success; // Green for ongoing
      case 'completed':
        return AppColors.textTertiary; // Muted for completed
      case 'cancelled':
        return AppColors.error; // Red for cancelled
      default:
        return colorScheme.onBackground;
    }
  }

  // Helper for consistent detail cards
  Widget _buildDetailCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  // Helper for individual detail rows
  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme colorScheme,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start, // Align icon and text at top
      children: [
        Icon(
          icon,
          color: colorScheme.primary.withOpacity(0.8),
          size: 24,
        ), // Branded icon color
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
