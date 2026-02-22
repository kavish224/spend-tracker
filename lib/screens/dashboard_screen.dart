import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/expense_providers.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/donut_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 18),
            DashboardCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This Month Total',
                    style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatter.format(provider.monthlyTotal),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      height: 1,
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
                      color: const Color(0xFF202020),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Today's Spend",
                          style: TextStyle(color: Color(0xFFB3B3B3)),
                        ),
                        Text(
                          formatter.format(provider.todayTotal),
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
            DonutChart(
              title: 'Category Breakdown',
              data: provider.categoryTotals,
            ),
            const SizedBox(height: 18),
            DonutChart(
              title: 'Payment Method Breakdown',
              data: provider.paymentMethodTotals,
            ),
            const SizedBox(height: 18),
            DashboardCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 14),
                  if (provider.recentExpenses.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'No expenses yet',
                          style: TextStyle(color: Color(0xFF9A9A9A)),
                        ),
                      ),
                    )
                  else
                    ...provider.recentExpenses.asMap().entries.map((entry) {
                      final index = entry.key;
                      final expense = entry.value;
                      final isLast =
                          index == provider.recentExpenses.length - 1;
                      return Column(
                        children: [
                          _RecentExpenseRow(
                            category: expense.category,
                            paymentMethod: expense.paymentMethod,
                            amount: formatter.format(expense.amount),
                            date: DateFormat(
                              'dd MMM, hh:mm a',
                            ).format(expense.date),
                          ),
                          if (!isLast)
                            const Divider(
                              height: 18,
                              color: Color(0xFF232323),
                              thickness: 1,
                            ),
                        ],
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentExpenseRow extends StatelessWidget {
  const _RecentExpenseRow({
    required this.category,
    required this.paymentMethod,
    required this.amount,
    required this.date,
  });

  final String category;
  final String paymentMethod;
  final String amount;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF202020),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _categoryIcon(category),
            size: 19,
            color: const Color(0xFFD9D9D9),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                '$paymentMethod • $date',
                style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(10 * (1 - value), 0),
                child: child,
              ),
            );
          },
          child: Text(
            amount,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
      ],
    );
  }

  IconData _categoryIcon(String input) {
    final value = input.toLowerCase();
    if (value.contains('food') || value.contains('grocery')) {
      return Icons.restaurant_rounded;
    }
    if (value.contains('fuel') || value.contains('travel')) {
      return Icons.local_gas_station_rounded;
    }
    if (value.contains('rent') || value.contains('home')) {
      return Icons.home_rounded;
    }
    if (value.contains('shop')) {
      return Icons.shopping_bag_rounded;
    }
    return Icons.receipt_long_rounded;
  }
}
