import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import 'accounts_screen.dart';
import 'add_expense_sheet.dart';
import 'analytics_screen.dart';
import 'dashboard_screen.dart';

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  static const List<_TabItem> _tabs = [
    _TabItem(title: 'Dashboard', icon: Icons.dashboard_rounded),
    _TabItem(title: 'Analytics', icon: Icons.insights_rounded),
    _TabItem(title: 'Accounts', icon: Icons.account_balance_wallet_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: const Color(0xFF1C1C1E),
        activeColor: CupertinoColors.systemBlue,
        inactiveColor: CupertinoColors.inactiveGray,
        items: [
          for (final tab in _tabs)
            BottomNavigationBarItem(
              icon: Icon(tab.icon),
              label: tab.title,
            ),
        ],
      ),
      tabBuilder: (context, index) {
        Widget screen;
        String title;
        switch (index) {
          case 0:
            screen = const DashboardScreen();
            title = 'Dashboard';
            break;
          case 1:
            screen = const AnalyticsScreen();
            title = 'Analytics';
            break;
          case 2:
            screen = const AccountsScreen();
            title = 'Accounts';
            break;
          default:
            screen = const DashboardScreen();
            title = 'Dashboard';
        }
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            backgroundColor: const Color(0xFF1C1C1E),
            border: null,
            middle: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: SafeArea(
                  top: false,
                  child: screen,
                ),
              ),
              _AddExpenseFab(presentAdd: () => _presentAddExpense(context)),
            ],
          ),
        );
      },
    );
  }

  void _presentAddExpense(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => const AddExpenseSheet(),
    );
  }
}

class _AddExpenseFab extends StatelessWidget {
  const _AddExpenseFab({required this.presentAdd});

  final VoidCallback presentAdd;

  @override
  Widget build(BuildContext context) {
    final isAdding = context.select<ExpenseProvider, bool>((p) => p.isAdding);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        child: SizedBox(
          height: 52,
          width: double.infinity,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            color: CupertinoColors.systemBlue,
            borderRadius: BorderRadius.circular(14),
            onPressed: isAdding ? null : presentAdd,
            child: isAdding
                ? const CupertinoActivityIndicator(
                    color: CupertinoColors.white,
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_rounded,
                        color: CupertinoColors.white,
                        size: 22,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Add Expense',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  const _TabItem({required this.title, required this.icon});
  final String title;
  final IconData icon;
}
