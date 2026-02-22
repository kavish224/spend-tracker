import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/donut_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<ExpenseProvider, bool>(
      (provider) => provider.isLoading,
    );
    final isEmpty = context.select<ExpenseProvider, bool>(
      (provider) => provider.expenses.isEmpty,
    );
    final errorMessage = context.select<ExpenseProvider, String?>(
      (provider) => provider.errorMessage,
    );
    final monthlyTotal = context.select<ExpenseProvider, double>(
      (provider) => provider.monthlyTotal,
    );
    final todayTotal = context.select<ExpenseProvider, double>(
      (provider) => provider.todayTotal,
    );
    final categoryTotals = context.select<ExpenseProvider, Map<String, double>>(
      (provider) => provider.categoryTotals,
    );
    final paymentMethodTotals = context
        .select<ExpenseProvider, Map<String, double>>(
          (provider) => provider.paymentMethodTotals,
        );
    final recentExpenses = context.select<ExpenseProvider, List<Expense>>(
      (provider) => provider.recentExpenses,
    );
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    if (isLoading && isEmpty) {
      return const Center(
        child: CupertinoActivityIndicator(radius: 12),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverSafeArea(
          top: false,
          sliver: SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                DashboardCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'This Month Total',
                        style: TextStyle(
                          color: CupertinoColors.inactiveGray,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatter.format(monthlyTotal),
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.tertiarySystemFill,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Today's Spend",
                              style: TextStyle(
                                color: CupertinoColors.secondaryLabel,
                              ),
                            ),
                            Text(
                              formatter.format(todayTotal),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (errorMessage != null) ...[
                  DashboardCard(
                    child: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.exclamationmark_circle_fill,
                          color: CupertinoColors.systemRed,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            errorMessage,
                            style: const TextStyle(
                              color: CupertinoColors.systemRed,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () =>
                              context.read<ExpenseProvider>().fetchExpenses(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
                DonutChart(title: 'Category Breakdown', data: categoryTotals),
                const SizedBox(height: 18),
                DonutChart(
                  title: 'Payment Method Breakdown',
                  data: paymentMethodTotals,
                ),
                const SizedBox(height: 18),
                DashboardCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (recentExpenses.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              'No expenses yet',
                              style: TextStyle(
                                color: CupertinoColors.inactiveGray,
                              ),
                            ),
                          ),
                        )
                      else
                        ...recentExpenses.asMap().entries.map((entry) {
                          final index = entry.key;
                          final expense = entry.value;
                          final isLast = index == recentExpenses.length - 1;
                          return Column(
                            children: [
                              _RecentExpenseTile(
                                expense: expense,
                                formatter: formatter,
                                onDelete: expense.id != null
                                    ? () => _deleteExpense(context, expense.id!)
                                    : null,
                              ),
                              if (!isLast)
                                Divider(
                                  height: 1,
                                  indent: 0,
                                  endIndent: 0,
                                ),
                            ],
                          );
                        }),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ),
      ],
    );
  }

  void _deleteExpense(BuildContext context, int id) {
    final provider = context.read<ExpenseProvider>();
    provider.deleteExpense(id);
  }
}

class _RecentExpenseTile extends StatelessWidget {
  const _RecentExpenseTile({
    required this.expense,
    required this.formatter,
    this.onDelete,
  });

  final Expense expense;
  final NumberFormat formatter;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey<int>(expense.id ?? 0),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: CupertinoColors.systemRed,
        child: const Icon(
          CupertinoIcons.delete_solid,
          color: CupertinoColors.white,
          size: 22,
        ),
      ),
      confirmDismiss: (direction) async {
        if (onDelete == null) return false;
        return await showCupertinoDialog<bool>(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Delete expense?'),
            content: Text(
              '${expense.category} — ${formatter.format(expense.amount)}',
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete?.call(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: CupertinoColors.tertiarySystemFill,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _categoryIcon(expense.category),
                size: 18,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.category,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${expense.paymentMethod} • ${DateFormat('dd MMM, hh:mm a').format(expense.date)}',
                    style: const TextStyle(
                      color: CupertinoColors.secondaryLabel,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              formatter.format(expense.amount),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(String input) {
    final value = input.toLowerCase();
    if (value.contains('food') || value.contains('grocery')) {
      return CupertinoIcons.cart_fill;
    }
    if (value.contains('fuel') || value.contains('travel')) {
      return CupertinoIcons.car_fill;
    }
    if (value.contains('rent') || value.contains('home')) {
      return CupertinoIcons.house_fill;
    }
    if (value.contains('shop')) {
      return CupertinoIcons.bag_fill;
    }
    return CupertinoIcons.doc_text_fill;
  }
}
