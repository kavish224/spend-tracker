import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'dashboard_card.dart';

class DonutChart extends StatelessWidget {
  const DonutChart({super.key, required this.title, required this.data});

  final String title;
  final Map<String, double> data;

  static const List<Color> _palette = [
    CupertinoColors.systemBlue,
    CupertinoColors.systemGreen,
    CupertinoColors.systemOrange,
    CupertinoColors.systemRed,
    CupertinoColors.systemPurple,
    CupertinoColors.systemTeal,
  ];

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<double>(0, (sum, e) => sum + e.value);

    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            const SizedBox(
              height: 170,
              child: Center(
                child: Text(
                  'No data yet',
                  style: TextStyle(color: CupertinoColors.inactiveGray),
                ),
              ),
            )
          else
            SizedBox(
              height: 190,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        startDegreeOffset: -90,
                        sections: List.generate(entries.length, (index) {
                          final entry = entries[index];
                          return PieChartSectionData(
                            value: entry.value,
                            title: '',
                            radius: 52,
                            color: _palette[index % _palette.length],
                          );
                        }),
                      ),
                      swapAnimationDuration:
                          const Duration(milliseconds: 300),
                      swapAnimationCurve: Curves.easeOutCubic,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: entries.length > 4 ? 4 : entries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        final percent = total == 0
                            ? 0.0
                            : (entry.value / total) * 100;

                        return Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _palette[index % _palette.length],
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                entry.key,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${percent.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: CupertinoColors.secondaryLabel,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
