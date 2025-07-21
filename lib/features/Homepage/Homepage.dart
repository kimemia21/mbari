import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:mbari/core/constants/constants.dart';
import 'package:mbari/core/utils/Alerts.dart';
import 'package:mbari/data/models/Meeting.dart';
import 'package:mbari/features/UserMeeting.dart/UserMeeting.dart';
import 'package:mbari/features/deposit/deposit.dart';
import 'package:mbari/features/profile/Profile.dart';

class ChamaHomePage extends StatefulWidget {
  const ChamaHomePage({Key? key}) : super(key: key);

  @override
  State<ChamaHomePage> createState() => _ChamaHomePageState();
}

class _ChamaHomePageState extends State<ChamaHomePage> {
  int _currentIndex = 0;
  int _selectedNavIndex = 0; // Track the visual navigation index



  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(
        onPressed: (int p0) {
          print('Home Page onPressed: $p0');
          setState(() {
            _currentIndex = p0;
            _selectedNavIndex = p0;
          });
        },
      ),
     MeetingDetailsPage(), 
      const AddDepositPage(), // Deposit page at index 2
      const LoansPage(),
      const ProfilePage(),
    ];
  }

  void _handleDeposit() {
    HapticFeedback.vibrate();
    setState(() {
      _currentIndex = 2; // Navigate to AddDepositPage
      _selectedNavIndex = 2; // Highlight the deposit button
    });
  }

  void _onNavTap(int index) {
    HapticFeedback.selectionClick();

    if (index == 2) {
      // Deposit button pressed
      _handleDeposit();
      return;
    }

    setState(() {
      _selectedNavIndex = index;

      // Adjust _currentIndex based on the tapped navigation button
      if (index < 2) {
        _currentIndex = index;
      } else {
        _currentIndex = index; // Deposit is at 2, Loans at 3, Profile at 4
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        alignment: Alignment.bottomCenter,
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: EdgeInsets.zero,
        child: CurvedNavigationBar(
          index: _selectedNavIndex,
          height: 60,
          backgroundColor: theme.colorScheme.surface,
          color: theme.colorScheme.primary,
          buttonBackgroundColor: theme.colorScheme.primary,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 300),
          onTap: _onNavTap,
          items: const [
            Icon(Icons.home, size: 24),
            Icon(Icons.meeting_room_outlined, size: 24),
            Icon(Icons.add, size: 28), // Deposit
            Icon(Icons.account_balance, size: 24),
            Icon(Icons.settings, size: 24),
          ],
        ),
      ),
    );
  }
}


class TransactionsPage extends StatelessWidget {
  const TransactionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 100, color: Colors.green),
            SizedBox(height: 20),
            Text(
              'Transactions Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class LoansPage extends StatelessWidget {
  const LoansPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loans'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance, size: 100, color: Colors.orange),
            SizedBox(height: 20),
            Text(
              'Loans Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, size: 100, color: Colors.purple),
            SizedBox(height: 20),
            Text(
              'Settings Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final Function(int p0) onPressed;

  const HomePage({required this.onPressed});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

 bool isLoading = false;
  String msg = "";
bool meetingPresent = false;

  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    checkForMeeting();

  }





Future<void> checkForMeeting() async {
  try {
    setState(() {
      msg = "";
      isLoading = true; 
      meetingPresent = false; // Reset meeting presence
    });

    final results = await comms.getRequests(endpoint: "meeting/today");
    if (results["rsp"]["success"]) {
      meeting = Meeting.fromJson(results["rsp"]["data"]);
      print("=====================================${meeting.toJson()}====================================");
      setState(() {
        msg = "";
        isLoading = false; 
        meetingPresent = true;
      });
      showalert(
        success: true,
        context: context,
        title: "Success",
        subtitle: results["rsp"]["message"],
      );
    } else {
      setState(() {
        msg = results["rsp"]["message"];
        isLoading = false; 
        meetingPresent = false;
      });
      showalert(
        success: false,
        context: context,
        title: "No Meeting Found",
        subtitle: results["rsp"]["message"],
      );
    }
  } catch (e) {
    setState(() {
      msg = "An error occurred. Please try again.";
      isLoading = false; 
    });
  }
}

  @override
  void initState() {
    super.initState();
 
    
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background, // Use background for a softer base
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark, // Adjust based on your primary background
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.chamaName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground, // Use onBackground for text color
              ),
            ),
            Text(
              'Welcome back, ${user.name.split(' ')[0]}', // Personalized welcome
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 24, // Slightly larger avatar
              backgroundColor: colorScheme.primary.withOpacity(0.1), // Subtle background
              child: ClipOval( // Ensure the image is clipped to a circle
                child: Image.asset(
                  "assets/images/logofour.png",
                  fit: BoxFit.cover, // Cover to ensure image fills
                  width: 48, // Match radius * 2
                  height: 48,
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: checkForMeeting, 
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0), // Consistent padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chama Wallet Card (Prominent Balance Display - Refined)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 28), // More generous padding
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.9),
                      colorScheme.secondary, // More vibrant gradient end
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25), // More rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.35), // Stronger, more defined shadow
                      blurRadius: 25,
                      offset: const Offset(0, 12), // Deeper shadow
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Decorative circles - more subtle, perhaps slightly blurred
                    Positioned(
                      top: -40,
                      right: -40,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.onPrimary.withOpacity(0.05), // Lighter opacity
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: -30,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.onPrimary.withOpacity(0.08), // Lighter opacity
                        ),
                      ),
                    ),
                    // Card content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.wallet_rounded, // Slightly more modern icon
                                  color: colorScheme.onPrimary,
                                  size: 28, // Slightly larger icon
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Chama Wallet',
                                  style: theme.textTheme.titleLarge?.copyWith( // Larger title for prominence
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.visibility_outlined,
                                color: colorScheme.onPrimary.withOpacity(0.9),
                                size: 26,
                              ),
                              onPressed: () {
                                print('Toggle balance visibility');
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24), // Increased spacing
                        Text(
                          'KSh 45,750.00',
                          style: theme.textTheme.displaySmall?.copyWith( // Larger and bolder balance
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'MEMBER',
                                  style: theme.textTheme.labelMedium?.copyWith( // Slightly larger label
                                    color: colorScheme.onPrimary.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1.5, // More letter spacing
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.name,
                                  style: theme.textTheme.bodyLarge?.copyWith( // Larger value
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'JOINED',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: colorScheme.onPrimary.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '12 / 27', // Spaced out for readability
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36), // More vertical space
        
              // Ongoing Meeting Burner-like Widget (Refined)
              if (meetingPresent && meeting != null) ...[
               Container (
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
                  children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    Row(
                      children: [
                      Icon(Icons.event_note_rounded, color: colorScheme.primary, size: 30),
                      const SizedBox(width: 14),
                      Text(
                        'Meeting Today',
                        style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        ),
                      ),
                      ],
                    ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                        meeting.status.toString(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                      )
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildMeetingDetailRow(
                      context,
                      'Venue',
                      meeting.venue,
                      Icons.location_on_outlined,
                      colorScheme,
                    ),
                    const SizedBox(height: 12),
                    _buildMeetingDetailRow(
                      context,
                      'Agenda',
                      meeting.agenda,
                      Icons.list_alt_outlined,
                      colorScheme,
                    ),
                    const SizedBox(height: 12),
                    _buildMeetingDetailRow(
                      context,
                      'Starts',
                      meeting.startTime != null
                        ? meeting.startTime!.format(context)
                        : '--:--',
                      Icons.access_time_outlined,
                      colorScheme,
                    ),
                    const SizedBox(height: 12),
                    _buildMeetingDetailRow(
                      context,
                      'Ends',
                      meeting.endTime != null
                        ? meeting.endTime!.format(context)
                        : '--:--',
                      Icons.access_time_filled_outlined,
                      colorScheme,
                    ),
                    const SizedBox(height: 12),
                    _buildMeetingDetailRow(
                      context,
                      'Status',
                      meeting.status,
                      Icons.info_outline,
                      colorScheme,
                      isImportant: true,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
                      label: Text(
                        "View Meeting Details",
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
  onPressed: () => widget.onPressed(1)

                      ),
                    )
                    ],
                  ),
                  ),
              ] else ...[
                Container(
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
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.event_note_rounded, color: colorScheme.primary, size: 30),
                              const SizedBox(width: 14),
                              Text(
                                msg,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.refresh, color: colorScheme.primary, size: 26),
                            onPressed: checkForMeeting,
                          ),
                        ],
                      ),
               
                     
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 40), // More vertical space before next section
        
              // Quick Actions Grid (Refined)
              Text(
                'Your Chama Services', // More professional heading
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 18, // Increased spacing
                mainAxisSpacing: 18,
                children: [
                  _buildActionButton(context,
                      title: 'Meetings',
                      icon: Icons.meeting_room_outlined, // Specific, clean icon
                      onTap: () {
                        print('Navigate to Meetings');
                      }),
                  _buildActionButton(context,
                      title: 'Members',
                      icon: Icons.group_outlined,
                      onTap: () {
                        print('Navigate to Members');
                      }),
                  _buildActionButton(context,
                      title: 'My Statement',
                      icon: Icons.receipt_long_outlined,
                      onTap: () {
                        print('Navigate to My Statement');
                      }),
                  _buildActionButton(context,
                      title: 'Settings',
                      icon: Icons.settings_outlined,
                      onTap: () {
                        print('Navigate to Settings');
                      }),
                  _buildActionButton(context,
                      title: 'Profile',
                      icon: Icons.person_outline_rounded,
                      onTap: () {
                        print('Navigate to Profile');
                      }),
                   _buildActionButton(context,
                      title: 'Contributions',
                      icon: Icons.attach_money_outlined, // New action
                      onTap: () {
                        print('Navigate to Contributions');
                      }),
                ],
              ),
              const SizedBox(height: 40),
        
              // Recent Transactions Section (Refined)
              Text(
                'Latest Activity', // More engaging heading
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 20),
        
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface, // Use surface
                  borderRadius: BorderRadius.circular(20), // Consistent rounding
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.06), // Softer shadow
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  separatorBuilder:
                      (context, index) => Divider(
                        color: colorScheme.outline.withOpacity(0.1), // Lighter divider
                        height: 1,
                        indent: 20, // Match list tile padding
                        endIndent: 20,
                      ),
                  itemBuilder: (context, index) {
                    final items = [
                      {
                        'title': 'Monthly Contribution',
                        'subtitle': 'Received from John Doe',
                        'amount': '+KSh 5,000',
                        'icon': Icons.arrow_downward_rounded, // Rounded icons
                        'isPositive': true,
                      },
                      {
                        'title': 'Loan Repayment',
                        'subtitle': 'Paid to Chama Loan Fund',
                        'amount': '-KSh 2,000',
                        'icon': Icons.arrow_upward_rounded,
                        'isPositive': false,
                      },
                      {
                        'title': 'Emergency Fund',
                        'subtitle': 'Received from Jane Smith',
                        'amount': '+KSh 2,500',
                        'icon': Icons.arrow_downward_rounded,
                        'isPositive': true,
                      },
                    ];
                    final item = items[index];
                    return _buildTransactionTile(
                      context,
                      title: item['title'] as String,
                      subtitle: item['subtitle'] as String,
                      amount: item['amount'] as String,
                      icon: item['icon'] as IconData,
                      isPositive: item['isPositive'] as bool,
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    print('Navigate to All Transactions');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: colorScheme.primary.withOpacity(0.6), width: 1.5), // Slightly thicker border
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), // Consistent rounding
                    ),
                  ),
                  child: Text(
                    'View All Transactions',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }

  // Helper widget for transaction tiles (Refined)
  Widget _buildTransactionTile(
      BuildContext context, {
        required String title,
        required String subtitle,
        required String amount,
        required IconData icon,
        required bool isPositive,
      }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // More padding
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10), // Larger icon container
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.08), // Softer tint
              borderRadius: BorderRadius.circular(10), // Slightly more rounded
            ),
            child: Icon(icon, color: colorScheme.primary, size: 22), // Slightly larger icon
          ),
          const SizedBox(width: 16), // More space
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2), // Small spacing
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.8), // Softer subtitle
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isPositive ? Colors.green.shade600 : colorScheme.error, // Stronger green
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for action buttons in the grid (Refined)
  Widget _buildActionButton(
      BuildContext context, {
        required String title,
        required IconData icon,
        required VoidCallback onTap,
      }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18), // Larger borderRadius for smooth touch
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface, // Clean surface background
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.05), // Very subtle shadow
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: colorScheme.primary, size: 36), // Larger icons
            const SizedBox(height: 10), // More space
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for a single meeting detail row (Refined)
  Widget _buildMeetingDetailRow(
      BuildContext context,
      String label,
      String value,
      IconData icon,
      ColorScheme colorScheme, {
        bool isImportant = false,
      }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically
      children: [
        Icon(icon, color: colorScheme.onSurface.withOpacity(0.6), size: 20), // Softer icon color
        const SizedBox(width: 14),
        Text(
          '$label:',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.7),
            fontWeight: isImportant ? FontWeight.w600 : FontWeight.normal, // Slightly less bold for normal
          ),
        ),
        const SizedBox(width: 8),
        Expanded( // Ensures text wraps if long
          child: Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith( // Larger value text
              color: colorScheme.onSurface,
              fontWeight: isImportant ? FontWeight.bold : FontWeight.w500,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}