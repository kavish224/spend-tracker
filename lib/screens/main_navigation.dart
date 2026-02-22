import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import 'accounts_screen.dart';
import 'add_expense_sheet.dart';
import 'analytics_screen.dart';
import 'dashboard_screen.dart';

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  static const List<_TabItem> _tabs = [
    _TabItem(title: 'Dashboard', icon: CupertinoIcons.square_grid_2x2_fill),
    _TabItem(title: 'Analytics', icon: CupertinoIcons.chart_bar_fill),
    _TabItem(title: 'Accounts', icon: CupertinoIcons.creditcard_fill),
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
        final isAdding = context.select<ExpenseProvider, bool>(
          (p) => p.isAdding,
        );
        Widget screen;
        String title;
        bool showAddButton;
        switch (index) {
          case 0:
            screen = const DashboardScreen();
            title = 'Dashboard';
            showAddButton = true;
            break;
          case 1:
            screen = const AnalyticsScreen();
            title = 'Analytics';
            showAddButton = false;
            break;
          case 2:
            screen = const AccountsScreen();
            title = 'Accounts';
            showAddButton = false;
            break;
          default:
            screen = const DashboardScreen();
            title = 'Dashboard';
            showAddButton = true;
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
            trailing: showAddButton
                ? CupertinoButton(
                    padding: const EdgeInsets.only(right: 8),
                    onPressed: isAdding
                        ? null
                        : () => _presentAddExpense(context),
                    child: isAdding
                        ? const CupertinoActivityIndicator()
                        : const Icon(CupertinoIcons.add_circled_solid),
                  )
                : null,
          ),
          child: SafeArea(
            top: false,
            child: screen,
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

class _TabItem {
  const _TabItem({required this.title, required this.icon});
  final String title;
  final IconData icon;
}
