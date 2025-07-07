import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class ChamaHomePage extends StatefulWidget {
  const ChamaHomePage({Key? key}) : super(key: key);

  @override
  State<ChamaHomePage> createState() => _ChamaHomePageState();
}

class _ChamaHomePageState extends State<ChamaHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const TransactionsPage(),
    const LoansPage(),
    const SettingsPage(),
  ];

  void _handleDeposit() {
    // Handle deposit action here
    // Navigate to deposit page or show deposit dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Make Deposit'),
        content: const Text('Deposit functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 60,
        backgroundColor: colorScheme.surface,
        color: colorScheme.primary,
        buttonBackgroundColor: colorScheme.primary,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          if (index == 2) {
            // Middle button (index 2) is the deposit button
            _handleDeposit();
          } else {
            // Adjust index for other pages since deposit button is in the middle
            int pageIndex = index > 2 ? index - 1 : index;
            setState(() {
              _currentIndex = pageIndex;
            });
          }
        },
        items: [
          Icon(
            Icons.home,
            size: 24,
            color: colorScheme.onPrimary,
          ),
          Icon(
            Icons.receipt_long,
            size: 24,
            color: colorScheme.onPrimary,
          ),
          Icon(
            Icons.add,
            size: 28,
            color: colorScheme.onPrimary,
          ),
          Icon(
            Icons.account_balance,
            size: 24,
            color: colorScheme.onPrimary,
          ),
          Icon(
            Icons.settings,
            size: 24,
            color: colorScheme.onPrimary,
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning, John',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              'Welcome back to your chama',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: colorScheme.primary,
              child: Text(
                'J',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chama Wallet Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
              decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                colorScheme.primary,
                colorScheme.primary.withOpacity(0.85),
                colorScheme.secondary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                color: colorScheme.primary.withOpacity(0.25),
                blurRadius: 18,
                offset: const Offset(0, 8),
                ),
              ],
              ),
              child: Stack(
              children: [
                // Decorative circles
                Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.onPrimary.withOpacity(0.07),
                  ),
                ),
                ),
                Positioned(
                bottom: -20,
                left: -20,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.onPrimary.withOpacity(0.10),
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
                      Icons.account_balance_wallet_rounded,
                      color: colorScheme.onPrimary,
                      size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                      'Wallet',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                      ),
                    ],
                    ),
                    Icon(
                    Icons.visibility_outlined,
                    color: colorScheme.onPrimary.withOpacity(0.85),
                    size: 22,
                    ),
                  ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                  'KSh 45,750.00',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                  children: [
                    // Card chip
                    Container(
                    width: 38,
                    height: 28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: colorScheme.onPrimary.withOpacity(0.25),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                      width: 22,
                      height: 16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: colorScheme.onPrimary.withOpacity(0.5),
                      ),
                      ),
                    ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                    '••••  ••••  ••••',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onPrimary.withOpacity(0.8),
                      letterSpacing: 3,
                      fontWeight: FontWeight.w500,
                    ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                    '1234',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                    ),
                  ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                      'USER NAME',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimary.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                      'John Doe',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      ),
                    ],
                    ),
                    Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                      'JOINED DATE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimary.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                      '12/27',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      ),
                    ],
                    ),
                    // Card brand (e.g., Mastercard/Visa)
                    Container(
                    width: 38,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white.withOpacity(0.15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                        ),
                      ),
                      ],
                    ),
                    ),
                  ],
                  ),
                ],
                ),
              ],
              ),
            ),
            const SizedBox(height: 32),

            // Recent Deposits Section
            Text(
              'Recent Deposits',
              style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Modern ListView for Recent Deposits
            Container(
              decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              ),
              child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 2,
              separatorBuilder: (context, index) => Divider(
                color: colorScheme.outline.withOpacity(0.15),
                height: 1,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final items = [
                {
                  'title': 'Monthly Contribution',
                  'subtitle': 'Due 15-2024',
                  'amount': '+KSh 5,000',
                  'icon': Icons.calendar_today,
                  'isPositive': true,
                },
                {
                  'title': 'Emergency Fund',
                  'subtitle': 'Fund',
                  'amount': '+KSh 2,500',
                  'icon': Icons.security,
                  'isPositive': true,
                },
                ];
                final item = items[index];
                return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: _buildTransactionTile(
                  context,
                  title: item['title'] as String,
                  subtitle: item['subtitle'] as String,
                  amount: item['amount'] as String,
                  icon: item['icon'] as IconData,
                  isPositive: item['isPositive'] as bool,
                ),
                );
              },
              ),
            ),
            const SizedBox(height: 24),

      
          ],
        ),
      ),
    );
  }

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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
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
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isPositive ? Colors.green : colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: colorScheme.primary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder pages for other navigation tabs
class TransactionsPage extends StatelessWidget {
  const TransactionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Transactions',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: const Center(
        child: Text('Transactions Page'),
      ),
    );
  }
}

class LoansPage extends StatelessWidget {
  const LoansPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Loans',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: const Center(
        child: Text('Loans Page'),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Settings',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: const Center(
        child: Text('Settings Page'),
      ),
    );
  }
}