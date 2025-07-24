import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mbari/core/constants/constants.dart';
import 'package:mbari/data/models/Member.dart';
import 'package:mbari/data/models/MembersStats.dart';

class MembersPage extends StatefulWidget {
  @override
  _MembersPageState createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late Future<MembersAdmin> _membersFuture;
  late AnimationController _animationController;
  String _searchQuery = '';
  String _selectedFilter = 'All';
  
  final List<String> _filterOptions = ['All', 'Active', 'Inactive'];

  @override
  void initState() {
    super.initState();
    _membersFuture = _fetchMembersStats();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<MembersAdmin> _fetchMembersStats() async {
    final response = await comms.getRequests(endpoint: "members/admin/members");
    if (response["rsp"]["success"]) {
      return MembersAdmin.fromJson(response["rsp"]["data"]);
    } else {
      throw Exception('Failed to load members stats');
    }
  }

  void _refreshData() {
    setState(() {
      _membersFuture = _fetchMembersStats();
    });
    _animationController.reset();
    _animationController.forward();
  }

  List<MemberStats> _filterMembers(List<MemberStats> members) {
    List<MemberStats> filtered = members;
    
    // Apply status filter
    if (_selectedFilter != 'All') {
      filtered = filtered.where((member) {
        final isActive = member.memberStatus.toLowerCase() == 'active';
        return _selectedFilter == 'Active' ? isActive : !isActive;
      }).toList();
    }
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((member) =>
        member.memberName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        member.memberPhone.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 768 && screenWidth <= 1200;
    final isMobile = screenWidth <= 768;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar.large(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Members Management',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            actions: [
              if (isDesktop) ...[
                _buildFilterChips(),
                SizedBox(width: 16),
                _buildActionButton(
                  icon: Icons.refresh_rounded,
                  onPressed: _refreshData,
                  tooltip: 'Refresh',
                ),
                SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.add_rounded,
                  onPressed: () => _showAddMemberDialog(context),
                  tooltip: 'Add Member',
                  isPrimary: true,
                ),
                SizedBox(width: 16),
              ],
            ],
          ),
          
          // Search and Filters Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isDesktop ? 32 : 16,
                0,
                isDesktop ? 32 : 16,
                24,
              ),
              child: Column(
                children: [
                  _buildSearchSection(isDesktop, isMobile),
                  if (!isDesktop) ...[
                    SizedBox(height: 16),
                    _buildMobileActions(),
                  ],
                ],
              ),
            ),
          ),
          
          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : 16,
              ),
              child: FutureBuilder<MembersAdmin>(
                future: _membersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  }
                  if (snapshot.hasError) {
                    return _buildErrorState(snapshot.error.toString());
                  }
                  if (!snapshot.hasData) {
                    return _buildEmptyState();
                  }

                  final membersAdmin = snapshot.data!;
                  final filteredMembers = _filterMembers(membersAdmin.memberStats.cast<MemberStats>());

                  return AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _animationController,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeOutCubic,
                          )),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatsSection(membersAdmin, isDesktop, isTablet),
                              SizedBox(height: 32),
                              _buildMembersSection(filteredMembers, isDesktop, isTablet),
                              SizedBox(height: 100), // Bottom padding
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: !isDesktop ? _buildMobileFAB() : null,
    );
  }

  Widget _buildSearchSection(bool isDesktop, bool isMobile) {
    return Container(
      constraints: BoxConstraints(maxWidth: isDesktop ? 600 : double.infinity),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search members by name or phone...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[600]),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: isMobile ? 16 : 20,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Row(
      children: _filterOptions.map((filter) {
        final isSelected = _selectedFilter == filter;
        return Padding(
          padding: EdgeInsets.only(right: 8),
          child: FilterChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() => _selectedFilter = filter);
              }
            },
            selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            checkmarkColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileActions() {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filterOptions.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedFilter = filter);
                      }
                    },
                    selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        IconButton.filled(
          onPressed: _refreshData,
          icon: Icon(Icons.refresh_rounded),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    bool isPrimary = false,
  }) {
    return isPrimary
        ? FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text('Add Member'),
          )
        : IconButton.filled(
            onPressed: onPressed,
            icon: Icon(icon),
            tooltip: tooltip,
          );
  }

  Widget _buildMobileFAB() {
    return FloatingActionButton.extended(
      onPressed: () => _showAddMemberDialog(context),
      icon: Icon(Icons.add_rounded),
      label: Text('Add Member'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );
  }

  Widget _buildStatsSection(MembersAdmin data, bool isDesktop, bool isTablet) {
    final stats = [
      {
        'title': 'Total Members',
        'value': '${data.totalMembers}',
        'icon': Icons.people_rounded,
        'color': Colors.blue,
        'trend': '+5 this month'
      },
      {
        'title': 'Active Members',
        'value': '${data.activeMembers}',
        'icon': Icons.check_circle_rounded,
        'color': Colors.green,
        'trend': '+2 this week'
      },
      {
        'title': 'Total Contributions',
        'value': 'KSh ${data.totalContributions}',
        'icon': Icons.account_balance_wallet_rounded,
        'color': Colors.orange,
        'trend': '+15% vs last month'
      },
      {
        'title': 'Outstanding Debts',
        'value': 'KSh ${data.memberStats.cast<MemberStats>().fold(0.0, (sum, m) => sum + m.outstandingDebt).toStringAsFixed(0)}',
        'icon': Icons.trending_down_rounded,
        'color': Colors.red,
        'trend': '-3% vs last month'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount;
            double childAspectRatio;
            
            if (isDesktop) {
              crossAxisCount = 4;
              childAspectRatio = 1.2;
            } else if (isTablet) {
              crossAxisCount = 2;
              childAspectRatio = 1.4;
            } else {
              crossAxisCount = 1;
              childAspectRatio = 3.0;
            }
            
            return GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: stats.length,
              itemBuilder: (context, index) => _buildModernStatCard(stats[index]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildModernStatCard(Map<String, dynamic> stat) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (stat['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    stat['icon'],
                    size: 20,
                    color: stat['color'],
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    stat['trend'],
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              stat['value'],
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 4),
            Text(
              stat['title'],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersSection(List<MemberStats> members, bool isDesktop, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Members (${members.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            if (isDesktop)
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.download_rounded),
                label: Text('Export'),
              ),
          ],
        ),
        SizedBox(height: 16),
        if (members.isEmpty)
          _buildEmptyMembersState()
        else if (isDesktop)
          _buildDesktopMembersList(members)
        else
          _buildMobileMembersList(members),
      ],
    );
  }

  Widget _buildDesktopMembersList(List<MemberStats> members) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Column(
        children: [
          _buildTableHeader(),
          ...members.asMap().entries.map((entry) {
            return _buildTableRow(entry.value, entry.key);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    final headers = ['Member', 'Contact', 'Status', 'Contribution', 'Debt', 'Attendance', 'Actions'];
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: headers.map((header) {
          return Expanded(
            flex: header == 'Member' ? 2 : 1,
            child: Text(
              header,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTableRow(MemberStats member, int index) {
    final isActive = member.memberStatus.toLowerCase() == 'active';
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: index < 10 ? Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ) : null,
      ),
      child: Row(
        children: [
          // Member Info
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isActive ? Colors.green[100] : Colors.grey[300],
                  child: Text(
                    member.memberName.substring(0, 2).toUpperCase(),
                    style: TextStyle(
                      color: isActive ? Colors.green[700] : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.memberName,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        member.memberRole,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Contact
          Expanded(
            child: Text(member.memberPhone),
          ),
          
          // Status
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                member.memberStatus,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? Colors.green[700] : Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          // Contribution
          Expanded(
            child: Text('KSh ${member.totalContributed.toStringAsFixed(0)}'),
          ),
          
          // Debt
          Expanded(
            child: Text(
              'KSh ${member.outstandingDebt.toStringAsFixed(0)}',
              style: TextStyle(
                color: member.outstandingDebt > 0 ? Colors.red : Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          // Attendance
          Expanded(
            child: Text('${member.attendancePercentage.toStringAsFixed(1)}%'),
          ),
          
          // Actions
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.more_vert_rounded),
                  onPressed: () => _showMemberActions(member),
                  tooltip: 'More actions',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileMembersList(List<MemberStats> members) {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: members.length,
      separatorBuilder: (context, index) => SizedBox(height: 12),
      itemBuilder: (context, index) => _buildMobileMemberCard(members[index]),
    );
  }

  Widget _buildMobileMemberCard(MemberStats member) {
    final isActive = member.memberStatus.toLowerCase() == 'active';
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: isActive ? Colors.green[100] : Colors.grey[300],
                  child: Text(
                    member.memberName.substring(0, 2).toUpperCase(),
                    style: TextStyle(
                      color: isActive ? Colors.green[700] : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.memberName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        member.memberPhone,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    member.memberStatus,
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? Colors.green[700] : Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                _buildMemberStat(
                  'Contributed',
                  'KSh ${member.totalContributed.toStringAsFixed(0)}',
                  Icons.wallet,
                  Colors.green,
                ),
                _buildMemberStat(
                  'Debt',
                  'KSh ${member.outstandingDebt.toStringAsFixed(0)}',
                  Icons.trending_down,
                  Colors.red,
                ),
                _buildMemberStat(
                  'Attendance',
                  '${member.attendancePercentage.toStringAsFixed(1)}%',
                  Icons.calendar_today,
                  Colors.blue,
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _resetPassword(member),
                    icon: Icon(Icons.lock_reset_rounded),
                    label: Text('Reset Password'),
                  ),
                ),
                SizedBox(width: 8),
                IconButton.outlined(
                  onPressed: () => _showMemberActions(member),
                  icon: Icon(Icons.more_vert_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberStat(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text(
              'Loading members...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red[300],
            ),
            SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _refreshData,
              icon: Icon(Icons.refresh_rounded),
              label: Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 24),
            Text(
              'No members found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Start by adding your first member',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showAddMemberDialog(context),
              icon: Icon(Icons.add_rounded),
              label: Text('Add Member'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMembersState() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 48,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'No members match your criteria',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Try adjusting your search or filters',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add New Member'),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.person_rounded),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.phone_rounded),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Member added successfully!'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
                _refreshData();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.warning_rounded, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Please fill in all fields.'),
                      ],
                    ),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            child: Text('Add Member'),
          ),
        ],
      ),
    );
  }

  void _showMemberActions(MemberStats member) {
    final isActive = member.memberStatus.toLowerCase() == 'active';
    
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isActive ? Colors.green[100] : Colors.grey[300],
                  child: Text(
                    member.memberName.substring(0, 2).toUpperCase(),
                    style: TextStyle(
                      color: isActive ? Colors.green[700] : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.memberName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        member.memberPhone,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            _buildActionTile(
              icon: Icons.lock_reset_rounded,
              title: 'Reset Password',
              subtitle: 'Send new password to member',
              onTap: () {
                Navigator.pop(context);
                _resetPassword(member);
              },
            ),
            _buildActionTile(
              icon: isActive ? Icons.block_rounded : Icons.check_circle_rounded,
              title: isActive ? 'Deactivate Member' : 'Activate Member',
              subtitle: isActive ? 'Suspend member access' : 'Restore member access',
              onTap: () {
                Navigator.pop(context);
                _toggleMemberStatus(member);
              },
            ),
            _buildActionTile(
              icon: Icons.delete_rounded,
              title: 'Remove Member',
              subtitle: 'Permanently delete member',
              onTap: () {
                Navigator.pop(context);
                _removeMember(member);
              },
              isDestructive: true,
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive 
              ? Colors.red.withOpacity(0.1)
              : Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive 
              ? Colors.red
              : Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.grey[400],
      ),
    );
  }

  void _resetPassword(MemberStats member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.lock_reset_rounded, color: Colors.blue),
            SizedBox(width: 12),
            Text('Reset Password'),
          ],
        ),
        content: Text('Are you sure you want to reset the password for ${member.memberName}? A new temporary password will be sent to their phone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.white),
                      SizedBox(width: 12),
                      Expanded(child: Text('Password reset for ${member.memberName}')),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: Text('Reset Password'),
          ),
        ],
      ),
    );
  }

  void _toggleMemberStatus(MemberStats member) {
    final isActive = member.memberStatus.toLowerCase() == 'active';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isActive ? Icons.block_rounded : Icons.check_circle_rounded,
              color: isActive ? Colors.orange : Colors.green,
            ),
            SizedBox(width: 12),
            Text(isActive ? 'Deactivate Member' : 'Activate Member'),
          ],
        ),
        content: Text(
          isActive 
              ? 'Are you sure you want to deactivate ${member.memberName}? They will lose access to the system.'
              : 'Are you sure you want to activate ${member.memberName}? They will regain access to the system.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.white),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${member.memberName} has been ${isActive ? 'deactivated' : 'activated'}',
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
              _refreshData();
            },
            style: FilledButton.styleFrom(
              backgroundColor: isActive ? Colors.orange : Colors.green,
            ),
            child: Text(isActive ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );
  }

  void _removeMember(MemberStats member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red),
            SizedBox(width: 12),
            Text('Remove Member'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to permanently remove ${member.memberName}?'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_rounded, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone. All member data will be permanently deleted.',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.delete_rounded, color: Colors.white),
                      SizedBox(width: 12),
                      Expanded(child: Text('${member.memberName} has been removed')),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
              _refreshData();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Remove Member'),
          ),
        ],
      ),
    );
  }
}