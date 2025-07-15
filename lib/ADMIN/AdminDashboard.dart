import 'package:flutter/material.dart';
import 'package:mbari/ADMIN/Create/CreateMeeting.dart';
import 'package:mbari/ADMIN/Meeting/MeetingPage.dart';
import 'package:mbari/ADMIN/Members/MembersPage.dart';
import 'package:mbari/core/constants/constants.dart';
import 'package:sidebarx/sidebarx.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Controller for the SidebarX, initialized with extended: true for desktop-first approach.
  // Its 'extended' state will be dynamically managed based on screen width.
  final _controller = SidebarXController(selectedIndex: 0, extended: true);
  bool isBalanceBlurred = false;

  // Sample data for the dashboard cards
  final int totalMembers = 25;
  final double accountBalance = 125000.50;
  final int debtOwners = 5;
  final int totalMeetings = 12;

  // Global key for the ScaffoldState, essential for controlling the Drawer (e.g., opening it).
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // Determine if the screen is considered "small" (e.g., mobile or narrow tablet)
    final isSmallScreen = MediaQuery.of(context).size.width < 800;

    // Dynamically update the SidebarXController's 'extended' property
    // This ensures that when the window is resized (e.g., on desktop),
    // the sidebar automatically expands or collapses as needed.
    _controller.setExtended(MediaQuery.of(context).size.width >= 800);

    return Scaffold(
      key: _scaffoldKey, // Assign the global key to the Scaffold
      backgroundColor: Theme.of(context).colorScheme.surface,
      // Conditionally render the SidebarX as a Drawer if it's a small screen.
      // For larger screens, the drawer will be null as the sidebar is part of the main body.
      drawer: isSmallScreen ? _buildSidebarX(context, isSmallScreen) : null,
      // Conditionally render an AppBar for small screens.
      // This AppBar will contain the menu icon to open the drawer and the page title.
      appBar:
          isSmallScreen
              ? AppBar(
                backgroundColor: Theme.of(context).colorScheme.surface,
                elevation: 0, // Remove shadow from AppBar
                leading: IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () {
                    // Open the drawer when the menu icon is pressed
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
                title: Text(
                  _getPageTitle(), // Display the current page title
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 22,
                  ),
                ),
                actions: [
                  // Action icons for the AppBar on small screens
                  _buildAppBarAction(Icons.notifications),
                  const SizedBox(width: 12),
                  _buildAppBarAction(Icons.admin_panel_settings),
                  const SizedBox(width: 12), // Add some spacing
                ],
              )
              : null, // No AppBar needed for large screens as the custom header handles it

      body: Row(
        children: [
          // Only show SidebarX directly in the Row if it's not a small screen.
          // On small screens, it's handled by the 'drawer' property.
          if (!isSmallScreen) _buildSidebarX(context, isSmallScreen),
          Expanded(
            child: Column(
              children: [
                // The custom AppBar for the main content area is only shown
                // if it's not a small screen (as the Scaffold's AppBar takes over on mobile).
                if (!isSmallScreen) _buildAppBar(),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      // The main content area changes based on the selected sidebar item
                      return _buildMainContent();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build the SidebarX widget, used for both main sidebar and drawer.
  Widget _buildSidebarX(BuildContext context, bool isSmallScreen) {
    return SidebarX(
      controller: _controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        hoverColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        textStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        selectedTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        itemTextPadding: const EdgeInsets.only(left: 16),
        selectedItemTextPadding: const EdgeInsets.only(left: 16),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.transparent,
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          size: 20,
        ),
        selectedIconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
      ),
      extendedTheme: SidebarXTheme(
        width: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ),
      footerDivider: Divider(
        color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        height: 1,
      ),
      headerBuilder: (context, extended) {
        return SizedBox(
          height: 100,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                extended
                    ? Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.group,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Chama Admin',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Management Portal',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                    : Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.group,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 24,
                      ),
                    ),
          ),
        );
      },
      items: [
        SidebarXItem(
          icon: Icons.dashboard,
          label: 'Dashboard',
          onTap: () {
            _onItemTapped(0);
            // Close the drawer automatically on mobile after an item is tapped
            if (isSmallScreen) {
              Navigator.of(context).pop();
            }
          },
        ),
        SidebarXItem(
          icon: Icons.people,
          label: 'Members',
          onTap: () {
            _onItemTapped(1);
            if (isSmallScreen) {
              Navigator.of(context).pop();
            }
          },
        ),
        SidebarXItem(
          icon: Icons.event,
          label: 'Meetings',
          onTap: () {
            _onItemTapped(2);
            if (isSmallScreen) {
              Navigator.of(context).pop();
            }
          },
        ),
        SidebarXItem(
          icon: Icons.analytics,
          label: 'Analytics',
          onTap: () {
            _onItemTapped(3);
            if (isSmallScreen) {
              Navigator.of(context).pop();
            }
          },
        ),
        SidebarXItem(
          icon: Icons.account_balance,
          label: 'Finances',
          onTap: () {
            _onItemTapped(4);
            if (isSmallScreen) {
              Navigator.of(context).pop();
            }
          },
        ),
        SidebarXItem(
          icon: Icons.settings,
          label: 'Settings',
          onTap: () {
            _onItemTapped(5);
            if (isSmallScreen) {
              Navigator.of(context).pop();
            }
          },
        ),
      ],
      footerBuilder: (context, extended) {
        return Container(
          padding: const EdgeInsets.all(16),
          child:
              extended
                  ? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: Icon(
                            Icons.admin_panel_settings,
                            size: 18,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: TextStyle(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                RoleToString(user.role),
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                      .withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                  : CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 18,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
        );
      },
    );
  }

  // Handles the selection of sidebar items
  void _onItemTapped(int index) {
    setState(() {
      _controller.selectIndex(index);
    });
  }

  // Builds the custom AppBar for the main content area (visible on larger screens)
  Widget _buildAppBar() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            _getPageTitle(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 22,
            ),
          ),
          const Spacer(), // Pushes action icons to the right
          _buildAppBarAction(Icons.notifications),
          const SizedBox(width: 12),
          _buildAppBarAction(Icons.admin_panel_settings),
        ],
      ),
    );
  }

  // Helper widget for the AppBar action icons
  Widget _buildAppBarAction(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Theme.of(context).colorScheme.primary),
    );
  }

  // Determines the title of the current page based on selected sidebar index
  String _getPageTitle() {
    switch (_controller.selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Members';
      case 2:
        return 'Meetings';
      case 3:
        return 'Analytics';
      case 4:
        return 'Finances';
      case 5:
        return 'Settings';
      default:
        return 'Dashboard';
    }
  }

  // Renders the main content based on the selected sidebar item
  Widget _buildMainContent() {
    switch (_controller.selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return _buildMembersContent();
      case 2:
        return _buildMeetingsContent();
      case 3:
        return _buildAnalyticsContent();
      case 4:
        return _buildFinancesContent();
      case 5:
        return _buildSettingsContent();
      default:
        return _buildDashboardContent();
    }
  }

  // Builds the content for the Dashboard page
  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section
          Container(
            padding: EdgeInsets.all(
              MediaQuery.of(context).size.width < 600 ? 16 : 24,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(
                MediaQuery.of(context).size.width < 600 ? 12 : 16,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, ${user.name}',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize:
                              MediaQuery.of(context).size.width < 600 ? 24 : 28,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width < 600 ? 4 : 8,
                      ),
                      Text(
                        'Here\'s an overview of your chama activities',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimary.withOpacity(0.9),
                          fontSize:
                              MediaQuery.of(context).size.width < 600 ? 14 : 16,
                        ),
                      ),
                    ],
                  ),
                ),
                // Show waving hand icon only on larger screens
                if (MediaQuery.of(context).size.width > 600)
                  Icon(
                    Icons.waving_hand,
                    size: 48,
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimary.withOpacity(0.8),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats cards section
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isMobile = width < 600;
              // Determine the number of columns based on available width
              final crossAxisCount =
                  width > 1200
                      ? 4
                      : width > 800
                      ? 3
                      : width > 600
                      ? 2
                      : 1;

              return GridView.count(
                shrinkWrap: true, // Take only as much space as needed
                physics:
                    const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: isMobile ? 12 : 16,
                crossAxisSpacing: isMobile ? 12 : 16,
                childAspectRatio:
                    isMobile ? 2.2 : 1.5, // Adjust aspect ratio for mobile
                children: [
                  _buildStatCard(
                    'Total Members',
                    totalMembers.toString(),
                    Icons.people,
                    Theme.of(context).colorScheme.primary,
                    'Active members in chama',
                    '+3 this month',
                  ),
                  _buildAccountBalanceCard(), // Dedicated card for account balance
                  _buildStatCard(
                    'Debt Owners',
                    debtOwners.toString(),
                    Icons.warning,
                    Theme.of(context).colorScheme.error,
                    'Members with outstanding debts',
                    '-2 from last month',
                  ),
                  _buildStatCard(
                    'Total Meetings',
                    totalMeetings.toString(),
                    Icons.event,
                    Theme.of(context).colorScheme.tertiary,
                    'Meetings held this year',
                    'Next: Dec 20, 2024',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // Quick actions section
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isMobile = width < 600;
              // Determine the number of columns for quick actions
              final crossAxisCount =
                  width > 800
                      ? 3
                      : width > 600
                      ? 2
                      : 1;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: isMobile ? 12 : 16,
                crossAxisSpacing: isMobile ? 12 : 16,
                childAspectRatio:
                    isMobile ? 3.5 : 2.5, // Adjust aspect ratio for mobile
                children: [
                  _buildActionCard(
                    'Create New Meeting',
                    'Schedule a new chama meeting',
                    Icons.add_circle,
                    Theme.of(context).colorScheme.primary,
                    () {
  showModalBottomSheet(
   showDragHandle: true,
  enableDrag: true,
  context: context,
  isScrollControlled: true,  builder: (context) {
    return CreateMeetingForm();
   },
 );
                    },
                  ), // Empty onTap for now
                  _buildActionCard(
                    'Add Member',
                    'Add a new member to the chama',
                    Icons.person_add,
                    Theme.of(context).colorScheme.secondary,
                    () {},
                  ), // Empty onTap for now
                  _buildActionCard(
                    'View Analytics',
                    'View detailed meeting analytics',
                    Icons.analytics,
                    Theme.of(context).colorScheme.tertiary,
                    () => _controller.selectIndex(
                      3,
                    ), // Navigate to Analytics page
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Placeholder content for Members page
  Widget _buildMembersContent() {
    return Center(child: MembersPage());
  }

  // Placeholder content for Meetings page
  Widget _buildMeetingsContent() {
    return  Expanded(
      
      child:MeetingPage()
    );
    
  }

  // Placeholder content for Analytics page
  Widget _buildAnalyticsContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Analytics Page',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Analytics and reporting functionality will be implemented here',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Placeholder content for Finances page
  Widget _buildFinancesContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Finances Page',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Financial management functionality will be implemented here',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Placeholder content for Settings page
  Widget _buildSettingsContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Settings Page',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Settings and configuration functionality will be implemented here',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Builds a generic statistic card
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String description,
    String trend,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 6 : 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: isMobile ? 18 : 20),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 6 : 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trend,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: isMobile ? 28 : 32,
                ),
              ),
              SizedBox(height: isMobile ? 2 : 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                  fontSize: isMobile ? 13 : 14,
                ),
              ),
              if (isMobile) SizedBox(height: 4),
              if (isMobile)
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Builds the account balance card with blur toggle functionality
  Widget _buildAccountBalanceCard() {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 6 : 8),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: Theme.of(context).colorScheme.secondary,
                  size: isMobile ? 18 : 20,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 6 : 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '+12.5%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                        fontSize: isMobile ? 12 : 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: isMobile ? 6 : 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isBalanceBlurred = !isBalanceBlurred;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(isMobile ? 4 : 6),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        isBalanceBlurred
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                        size: isMobile ? 16 : 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isBalanceBlurred
                    ? 'KES ●●●●●●' // Blurred representation
                    : 'KES ${accountBalance.toStringAsFixed(2)}', // Actual balance
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: isMobile ? 28 : 32,
                ),
              ),
              SizedBox(height: isMobile ? 2 : 4),
              Text(
                'Account Balance',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                  fontSize: isMobile ? 13 : 14,
                ),
              ),
              if (isMobile) const SizedBox(height: 4),
              if (isMobile)
                Text(
                  'Current total balance in chama account',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Builds a generic action card
  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Card(
      elevation: 0, // No shadow for the card itself
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: onTap, // Callback when the card is tapped
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: isMobile ? 24 : 28),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: isMobile ? 16 : 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isMobile ? 4 : 6),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                        fontSize: isMobile ? 12 : 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: isMobile ? 16 : 18,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
