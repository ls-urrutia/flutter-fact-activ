import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../utils/user_filters.dart';
import 'package:flag/flag.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserStatisticsChart extends StatefulWidget {
  final List<Map<String, dynamic>> users;

  UserStatisticsChart({required this.users});

  @override
  _UserStatisticsChartState createState() => _UserStatisticsChartState();
}

class _UserStatisticsChartState extends State<UserStatisticsChart> {
  Map<String, String> countryNameToCode = {};

  @override
  void initState() {
    super.initState();
    _loadCountryCodes();
  }

  Future<void> _loadCountryCodes() async {
    try {
      Map<String, String> codes = await fetchCountryCodes();
      setState(() {
        countryNameToCode = codes;
      });
    } catch (e) {
      print('Error loading country codes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure countryNameToCode is loaded before using it
    if (countryNameToCode.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _buildAgeDistributionChart(),
        SizedBox(height: 40),
        _buildCountryDistributionChart(),
      ],
    );
  }

  Widget _buildAgeDistributionChart() {
    Map<String, int> ageDistribution = getAgeDistribution(widget.users);
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
      future: getCountryDistribution(widget.users),
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

Future<Map<String, String>> fetchCountryCodes() async {
  final response = await http.get(Uri.parse('https://restcountries.com/v3.1/all'));

  if (response.statusCode == 200) {
    List<dynamic> countries = json.decode(response.body);
    Map<String, String> countryNameToCode = {};

    for (var country in countries) {
      String name = country['name']['common'];
      String code = country['cca2'];
      countryNameToCode[name] = code;
    }

    return countryNameToCode;
  } else {
    throw Exception('Failed to load country data');
  }
}
