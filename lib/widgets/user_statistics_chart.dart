import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../utils/user_filters.dart';

class UserStatisticsChart extends StatelessWidget {
  final List<Map<String, dynamic>> users;

  UserStatisticsChart({required this.users});

  @override
  Widget build(BuildContext context) {
    Map<String, int> ageDistribution = getAgeDistribution(users);
    int totalUsers = ageDistribution.values.fold(0, (sum, count) => sum + count);

    List<PieChartSectionData> sections = ageDistribution.entries.map((entry) {
      var range = ageRanges.firstWhere((r) => r['label'] == entry.key);
      int percentage = ((entry.value / totalUsers) * 100).round();
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${entry.key}\n${entry.value} (${percentage}%)',
        color: range['color'] as Color,
        radius: 100,
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titlePositionPercentageOffset: 0.55,
      );
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double diameter = constraints.maxWidth * 0.8;
        return Column(
          children: [
            Container(
              width: diameter,
              height: diameter,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: diameter * 0.1,
                  sectionsSpace: 2,
                  pieTouchData: PieTouchData(enabled: false),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Leyenda centrada con cuadrados alineados
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: ageDistribution.entries.map((entry) {
                    var range = ageRanges.firstWhere((r) => r['label'] == entry.key);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            color: range['color'] as Color,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '${entry.key}: ${entry.value} (${((entry.value / totalUsers) * 100).round()}%)',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
