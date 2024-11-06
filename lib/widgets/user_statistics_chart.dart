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
    int totalUsers =
        ageDistribution.values.fold(0, (sum, count) => sum + count);

    // Create empty sections if there's no data
    List<PieChartSectionData> sections = totalUsers == 0
        ? ageRanges
            .map((range) => PieChartSectionData(
                  value: 1, // Equal values for empty chart
                  title: '',
                  color: (range['color'] as Color)
                      .withOpacity(0.3), // Faded colors
                  radius: 100,
                ))
            .toList()
        : ageDistribution.entries.map((entry) {
            var range = ageRanges.firstWhere((r) => r['label'] == entry.key);
            return PieChartSectionData(
              value: entry.value.toDouble(),
              title:
                  '${entry.key}\n${entry.value} (${((entry.value / totalUsers) * 100).round()}%)',
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
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: diameter * 0.1,
                      sectionsSpace: 2,
                      pieTouchData: PieTouchData(enabled: false),
                    ),
                  ),
                  if (totalUsers == 0)
                    Center(
                      child: Text(
                        'Información Insuficiente',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: ageRanges.map((range) {
                    int value = totalUsers > 0
                        ? (ageDistribution[range['label']] ?? 0)
                        : 0;
                    int percentage = totalUsers > 0
                        ? ((value / totalUsers) * 100).round()
                        : 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            color: totalUsers > 0
                                ? range['color'] as Color
                                : (range['color'] as Color).withOpacity(0.3),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '${range['label']}: $value ${totalUsers > 0 ? "($percentage%)" : ""}',
                            style: TextStyle(
                              fontSize: 14,
                              color: totalUsers > 0
                                  ? Colors.black
                                  : Colors.grey[600],
                            ),
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
        }

        Map<String, int> countryDistribution = snapshot.data ?? {};
        int totalUsers =
            countryDistribution.values.fold(0, (sum, count) => sum + count);

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
            if (totalUsers == 0)
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'No hay datos de países disponibles',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              ...countryDistribution.entries.map((entry) {
                int percentage = ((entry.value / totalUsers) * 100).round();
                String countryCode =
                    countryNameToCode[entry.key]?.toLowerCase() ?? 'xx';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Flag.fromString(
                        countryCode,
                        height: 24,
                        width: 24,
                        fit: BoxFit.fill,
                        borderRadius: 4,
                      ),
                      SizedBox(width: 8),
                      Text('${entry.key}: ${entry.value} ($percentage%)'),
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
  final response =
      await http.get(Uri.parse('https://restcountries.com/v3.1/all'));

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
