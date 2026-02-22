import 'package:flutter/material.dart';
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
      return const SafeArea(child: Center(child: CircularProgressIndicator()));
    }

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
                    formatter.format(monthlyTotal),
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
                      Icons.error_outline_rounded,
                      color: Color(0xFFFF7B72),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Color(0xFFFFB4AE)),
                      ),
                    ),
                    TextButton(
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 14),
                  if (recentExpenses.isEmpty)
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
                    ...recentExpenses.asMap().entries.map((entry) {
                      final index = entry.key;
                      final expense = entry.value;
                      final isLast = index == recentExpenses.length - 1;
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
        Text(
          amount,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
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
