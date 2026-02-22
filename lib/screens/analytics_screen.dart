import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../widgets/dashboard_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

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
    final expenses = context.select<ExpenseProvider, List<Expense>>(
      (provider) => provider.expenses,
    );
    final categoryTotals = context.select<ExpenseProvider, Map<String, double>>(
      (provider) => provider.categoryTotals,
    );

    final monthlyData = _buildMonthlyTotals(expenses);
    final categoryData = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (errorMessage != null) ...[
                  DashboardCard(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
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
                DashboardCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Monthly Trend',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 220,
                        child: monthlyData.isEmpty
                            ? const Center(
                                child: Text(
                                  'No data yet',
                                  style: TextStyle(
                                    color: CupertinoColors.inactiveGray,
                                  ),
                                ),
                              )
                            : LineChart(
                                LineChartData(
                                  minY: 0,
                                  gridData: FlGridData(
                                    drawVerticalLine: false,
                                    horizontalInterval: _interval(monthlyData),
                                    getDrawingHorizontalLine: (_) =>
                                        const FlLine(
                                      color: Color(0xFF2C2C2E),
                                      strokeWidth: 1,
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  titlesData: FlTitlesData(
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    leftTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 1,
                                        reservedSize: 30,
                                        getTitlesWidget: (value, meta) {
                                          final index = value.toInt();
                                          if (index < 0 ||
                                              index >= monthlyData.length) {
                                            return const SizedBox.shrink();
                                          }
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                top: 8),
                                            child: Text(
                                              monthlyData[index].label,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: CupertinoColors
                                                    .inactiveGray,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  lineBarsData: [
                                    LineChartBarData(
                                      isCurved: true,
                                      barWidth: 3,
                                      color: CupertinoColors.systemBlue,
                                      dotData: const FlDotData(show: false),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: LinearGradient(
                                          colors: [
                                            CupertinoColors.systemBlue
                                                .withValues(alpha: 0.2),
                                            CupertinoColors.systemBlue
                                                .withValues(alpha: 0.02),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                      spots: List.generate(
                                        monthlyData.length,
                                        (index) => FlSpot(
                                          index.toDouble(),
                                          monthlyData[index].total,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                DashboardCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Category Spend (This Month)',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 240,
                        child: categoryData.isEmpty
                            ? const Center(
                                child: Text(
                                  'No data yet',
                                  style: TextStyle(
                                    color: CupertinoColors.inactiveGray,
                                  ),
                                ),
                              )
                            : BarChart(
                                BarChartData(
                                  minY: 0,
                                  gridData: FlGridData(
                                    drawVerticalLine: false,
                                    horizontalInterval:
                                        _barInterval(categoryData),
                                    getDrawingHorizontalLine: (_) =>
                                        const FlLine(
                                      color: Color(0xFF2C2C2E),
                                      strokeWidth: 1,
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  titlesData: FlTitlesData(
                                    topTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false),
                                    ),
                                    leftTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 34,
                                        getTitlesWidget: (value, meta) {
                                          final index = value.toInt();
                                          if (index < 0 ||
                                              index >= categoryData.length) {
                                            return const SizedBox.shrink();
                                          }
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                top: 8),
                                            child: Text(
                                              categoryData[index].key,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: CupertinoColors
                                                    .inactiveGray,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  barGroups: List.generate(
                                    categoryData.length,
                                    (index) {
                                      return BarChartGroupData(
                                        x: index,
                                        barRods: [
                                          BarChartRodData(
                                            toY: categoryData[index].value,
                                            width: 18,
                                            color: CupertinoColors
                                                .systemGreen,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                swapAnimationDuration:
                                    const Duration(milliseconds: 300),
                                swapAnimationCurve: Curves.easeOutCubic,
                              ),
                      ),
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

  List<_MonthlyTotal> _buildMonthlyTotals(List<Expense> expenses) {
    final now = DateTime.now();
    final formatter = DateFormat('MMM');
    final buckets = <DateTime, double>{};

    for (var i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      buckets[month] = 0;
    }

    for (final expense in expenses) {
      final monthKey =
          DateTime(expense.date.year, expense.date.month, 1);
      if (buckets.containsKey(monthKey)) {
        buckets[monthKey] = buckets[monthKey]! + expense.amount;
      }
    }

    final sorted = buckets.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return sorted
        .map(
          (e) =>
              _MonthlyTotal(label: formatter.format(e.key), total: e.value),
        )
        .toList();
  }

  double _interval(List<_MonthlyTotal> points) {
    final max = points.fold<double>(
      0,
      (current, p) => p.total > current ? p.total : current,
    );
    if (max <= 0) return 1;
    return max / 4;
  }

  double _barInterval(List<MapEntry<String, double>> points) {
    final max = points.fold<double>(
      0,
      (current, p) => p.value > current ? p.value : current,
    );
    if (max <= 0) return 1;
    return max / 4;
  }
}

class _MonthlyTotal {
  const _MonthlyTotal({required this.label, required this.total});

  final String label;
  final double total;
}
