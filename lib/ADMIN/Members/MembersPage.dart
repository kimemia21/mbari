import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mbari/data/models/Member.dart';


class MembersPage extends StatefulWidget {
  @override
  _MembersPageState createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Member> _members = [
    Member(
      id: '1',
      name: 'John Doe',
      phone: '+254712345678',
      contributedAmount: 15000,
      debts: 2500,
      attendance: 85,
      joinDate: DateTime(2024, 1, 15),
      isActive: true,
    ),
    Member(
      id: '2',
      name: 'Jane Smith',
      phone: '+254723456789',
      contributedAmount: 22000,
      debts: 0,
      attendance: 95,
      joinDate: DateTime(2024, 2, 10),
      isActive: true,
    ),
    Member(
      id: '3',
      name: 'Peter Kimani',
      phone: '+254734567890',
      contributedAmount: 8500,
      debts: 5000,
      attendance: 65,
      joinDate: DateTime(2024, 3, 5),
      isActive: false,
    ),
    Member(
      id: '4',
      name: 'Alice Johnson',
      phone: '+254701234567',
      contributedAmount: 10000,
      debts: 0,
      attendance: 90,
      joinDate: DateTime(2024, 4, 1),
      isActive: true,
    ),
    Member(
      id: '5',
      name: 'David Brown',
      phone: '+254745678901',
      contributedAmount: 5000,
      debts: 1500,
      attendance: 70,
      joinDate: DateTime(2024, 5, 20),
      isActive: true,
    ),
  ];

  List<Member> _filteredMembers = [];

  @override
  void initState() {
    super.initState();
    _filteredMembers = _members;
  }

  void _filterMembers(String query) {
    setState(() {
      _filteredMembers = _members
          .where((member) =>
              member.name.toLowerCase().contains(query.toLowerCase()) ||
              member.phone.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      // Conditionally show FloatingActionButton for mobile "Add Member"
      floatingActionButton: !isDesktop
          ? FloatingActionButton.extended(
              onPressed: () => _showAddMemberDialog(context),
              icon: Icon(Icons.add),
              label: Text('Add Member'),
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
            )
          : null,
      body: Padding(
        padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with search and add button (desktop)
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
                      onChanged: _filterMembers,
                      decoration: InputDecoration(
                        hintText: 'Search members...',
                        prefixIcon:
                            Icon(Icons.search, color: theme.iconTheme.color),
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
                // Show "Add Member" button in header only on desktop
                if (isDesktop) ...[
                  SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showAddMemberDialog(context),
                    icon: Icon(Icons.add),
                    label: Text('Add Member'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: isDesktop ? 16 : 12,
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

            // Members List
            Expanded(
              child: _buildMembersList(theme, isDesktop),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme, bool isDesktop) {
    final stats = [
      {
        'title': 'Total Members',
        'value': '${_members.length}',
        'icon': Icons.people
      },
      {
        'title': 'Active Members',
        'value': '${_members.where((m) => m.isActive).length}',
        'icon': Icons.check_circle
      },
      {
        'title': 'Total Contributions',
        'value': 'KSh ${_members.fold(0.0, (sum, m) => sum + m.contributedAmount)}',
        'icon': Icons.account_balance_wallet
      },
      {
        'title': 'Total Debts',
        'value': 'KSh ${_members.fold(0.0, (sum, m) => sum + m.debts)}',
        'icon': Icons.warning
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2, // 4 columns on desktop, 2 on mobile
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isDesktop ? 1.5 : 1.2, // Adjust aspect ratio
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
                color: theme.primaryColor,
              ),
              SizedBox(height: 8),
              Text(
                stat['value'] as String,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
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

  Widget _buildMembersList(ThemeData theme, bool isDesktop) {
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
        itemCount: _filteredMembers.length,
        itemBuilder: (context, index) {
          final member = _filteredMembers[index];
          return _buildMemberCard(member, theme, isDesktop);
        },
      ),
    );
  }

  Widget _buildMemberCard(Member member, ThemeData theme, bool isDesktop) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: member.isActive ? theme.primaryColor : Colors.grey,
          child: Text(
            member.name.substring(0, 2).toUpperCase(),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          member.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          member.phone,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: member.isActive
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                member.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  color: member.isActive ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.expand_more),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align content to start
              children: [
                // Info cards: stack vertically on mobile, side-by-side on desktop
                isDesktop
                    ? Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              'Contributed',
                              'KSh ${member.contributedAmount}',
                              Icons.account_balance_wallet,
                              Colors.green,
                              theme,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              'Debts',
                              'KSh ${member.debts}',
                              Icons.warning,
                              Colors.red,
                              theme,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildInfoCard(
                            'Contributed',
                            'KSh ${member.contributedAmount}',
                            Icons.account_balance_wallet,
                            Colors.green,
                            theme,
                          ),
                          SizedBox(height: 12),
                          _buildInfoCard(
                            'Debts',
                            'KSh ${member.debts}',
                            Icons.warning,
                            Colors.red,
                            theme,
                          ),
                        ],
                      ),
                SizedBox(height: 12),
                isDesktop
                    ? Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              'Attendance',
                              '${member.attendance}%',
                              Icons.calendar_today,
                              Colors.blue,
                              theme,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              'Phone',
                              member.phone,
                              Icons.phone,
                              Colors.orange,
                              theme,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildInfoCard(
                            'Attendance',
                            '${member.attendance}%',
                            Icons.calendar_today,
                            Colors.blue,
                            theme,
                          ),
                          SizedBox(height: 12),
                          _buildInfoCard(
                            'Phone',
                            member.phone,
                            Icons.phone,
                            Colors.orange,
                            theme,
                          ),
                        ],
                      ),
                SizedBox(height: 16),
                // Action buttons: wrap on mobile, spaceEvenly on desktop
                isDesktop
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            'Reset Password',
                            Icons.lock_reset,
                            () => _resetPassword(member),
                            theme.primaryColor,
                            theme,
                          ),
                          _buildActionButton(
                            member.isActive ? 'Deactivate' : 'Activate',
                            member.isActive ? Icons.block : Icons.check_circle,
                            () => _toggleMemberStatus(member),
                            member.isActive ? Colors.orange : Colors.green,
                            theme,
                          ),
                          _buildActionButton(
                            'Remove',
                            Icons.delete,
                            () => _removeMember(member),
                            Colors.red,
                            theme,
                          ),
                        ],
                      )
                    : Wrap(
                        spacing: 8.0, // horizontal space between children
                        runSpacing: 8.0, // vertical space between lines
                        alignment: WrapAlignment.center, // center align buttons
                        children: [
                          _buildActionButton(
                            'Reset Password',
                            Icons.lock_reset,
                            () => _resetPassword(member),
                            theme.primaryColor,
                            theme,
                          ),
                          _buildActionButton(
                            member.isActive ? 'Deactivate' : 'Activate',
                            member.isActive ? Icons.block : Icons.check_circle,
                            () => _toggleMemberStatus(member),
                            member.isActive ? Colors.orange : Colors.green,
                            theme,
                          ),
                          _buildActionButton(
                            'Remove',
                            Icons.delete,
                            () => _removeMember(member),
                            Colors.red,
                            theme,
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      String title, String value, IconData icon, Color color, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap,
      Color color, ThemeData theme) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    final theme = Theme.of(context);
    final nameController = TextEditingController();
    final phoneController = TextEditingController(); // Only phone is in Member model

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Member'),
        content: SingleChildScrollView( // Added SingleChildScrollView for smaller screens
          child: Container(
            width: MediaQuery.of(context).size.width * (MediaQuery.of(context).size.width > 600 ? 0.4 : 0.8), // Adjust dialog width
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  keyboardType: TextInputType.phone, // Suggest phone keyboard
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Only allow digits
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                setState(() {
                  _members.add(Member(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    phone: phoneController.text,
                    contributedAmount: 0,
                    debts: 0,
                    attendance: 0,
                    joinDate: DateTime.now(),
                    isActive: true,
                  ));
                  _filteredMembers = _members;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Member added successfully!')),
                );
              } else {
                 ScaffoldMessenger.of(context).showSnackBar( // Provide feedback for empty fields
                  SnackBar(content: Text('Please fill in all fields.')),
                );
              }
            },
            child: Text('Add Member'),
          ),
        ],
      ),
    );
  }

  void _resetPassword(Member member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Password'),
        content: Text('Are you sure you want to reset password for ${member.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Password reset for ${member.name}')),
              );
            },
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _toggleMemberStatus(Member member) {
    setState(() {
      member.isActive = !member.isActive;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('${member.name} ${member.isActive ? "activated" : "deactivated"}')),
    );
  }

  void _removeMember(Member member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Member'),
        content: Text('Are you sure you want to remove ${member.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _members.removeWhere((m) => m.id == member.id);
                _filteredMembers = _members;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${member.name} removed successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Remove'),
          ),
        ],
      ),
    );
  }
}
