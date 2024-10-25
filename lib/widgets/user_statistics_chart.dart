import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../utils/user_filters.dart';
import 'package:flag/flag.dart';

class UserStatisticsChart extends StatelessWidget {
  final List<Map<String, dynamic>> users;

  UserStatisticsChart({required this.users});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAgeDistributionChart(),
        SizedBox(height: 40),
        _buildCountryDistributionChart(),
      ],
    );
  }

  Widget _buildAgeDistributionChart() {
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

  Widget _buildCountryDistributionChart() {
    return FutureBuilder<Map<String, int>>(
      future: getCountryDistribution(users),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error al cargar datos'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No hay datos disponibles'));
        }

        Map<String, int> countryDistribution = snapshot.data!;
        int totalUsers = countryDistribution.values.fold(0, (sum, count) => sum + count);

        var sortedEntries = countryDistribution.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribución de usuarios por país',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ...sortedEntries.map((entry) {
              int percentage = ((entry.value / totalUsers) * 100).round();
              String countryCode = countryNameToCode[entry.key]?.toLowerCase() ?? 'xx';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Flag.fromString(
                      countryCode,
                      height: 24,
                      width: 24,
                      fit: BoxFit.fill,
                    ),
                    SizedBox(width: 8),
                    Text('${entry.key}: ${entry.value} (${percentage}%)'),
                  ],
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}

Map<String, String> countryNameToCode = {
  'Finland': 'FI',
  'United States': 'US',
  'Latvia': 'LV',
  'Netherlands': 'NL',
  'Denmark': 'DK',
  'France': 'FR',
  'Spain': 'ES',
  'China': 'CN',
  'Ireland': 'IE',
  'Ukraine': 'UA',
  'Chile': 'CL',
  'Argentina': 'AR',
};
