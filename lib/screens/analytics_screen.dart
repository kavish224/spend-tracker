import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../widgets/dashboard_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final monthlyData = _buildMonthlyTotals(provider.expenses);
    final categoryData = provider.categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (provider.isLoading && provider.expenses.isEmpty) {
      return const SafeArea(child: Center(child: CircularProgressIndicator()));
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analytics',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 18),
            if (provider.errorMessage != null) ...[
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
                        provider.errorMessage!,
                        style: const TextStyle(color: Color(0xFFFFB4AE)),
                      ),
                    ),
                    TextButton(
                      onPressed: provider.fetchExpenses,
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: monthlyData.isEmpty
                        ? const Center(
                            child: Text(
                              'No data yet',
                              style: TextStyle(color: Color(0xFF9A9A9A)),
                            ),
                          )
                        : LineChart(
                            LineChartData(
                              minY: 0,
                              gridData: FlGridData(
                                drawVerticalLine: false,
                                horizontalInterval: _interval(monthlyData),
                                getDrawingHorizontalLine: (_) => const FlLine(
                                  color: Color(0xFF242424),
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
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          monthlyData[index].label,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF9A9A9A),
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
                                  color: const Color(0xFF58A6FF),
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0x3358A6FF),
                                        Color(0x0558A6FF),
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
                            duration: const Duration(milliseconds: 450),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 240,
                    child: categoryData.isEmpty
                        ? const Center(
                            child: Text(
                              'No data yet',
                              style: TextStyle(color: Color(0xFF9A9A9A)),
                            ),
                          )
                        : BarChart(
                            BarChartData(
                              minY: 0,
                              gridData: FlGridData(
                                drawVerticalLine: false,
                                horizontalInterval: _barInterval(categoryData),
                                getDrawingHorizontalLine: (_) => const FlLine(
                                  color: Color(0xFF242424),
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
                                    reservedSize: 34,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index < 0 ||
                                          index >= categoryData.length) {
                                        return const SizedBox.shrink();
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          categoryData[index].key,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF9A9A9A),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              barGroups: List.generate(categoryData.length, (
                                index,
                              ) {
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: categoryData[index].value,
                                      width: 18,
                                      color: const Color(0xFF5EE6A8),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ],
                                );
                              }),
                            ),
                            swapAnimationDuration: const Duration(
                              milliseconds: 450,
                            ),
                            swapAnimationCurve: Curves.easeOutCubic,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
      final monthKey = DateTime(expense.date.year, expense.date.month, 1);
      if (buckets.containsKey(monthKey)) {
        buckets[monthKey] = buckets[monthKey]! + expense.amount;
      }
    }

    return buckets.entries
        .map(
          (e) => _MonthlyTotal(label: formatter.format(e.key), total: e.value),
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
