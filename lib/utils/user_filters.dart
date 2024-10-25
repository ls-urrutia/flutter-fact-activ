import 'package:flutter/material.dart';

// Define los rangos de edad
final List<Map<String, dynamic>> ageRanges = [
  {'min': 18, 'max': 28, 'label': '18-28', 'color': Colors.blue},
  {'min': 29, 'max': 40, 'label': '29-40', 'color': Colors.green},
  {'min': 41, 'max': 60, 'label': '41-60', 'color': Colors.orange},
  {'min': 61, 'max': 120, 'label': '60+', 'color': Colors.red},
];

// Función para filtrar usuarios por edad
List<Map<String, dynamic>> filterUsersByAge(List<Map<String, dynamic>> users, int minAge, int maxAge) {
  return users.where((user) {
    DateTime birthdate = DateTime.parse(user['birthdate']);
    int age = DateTime.now().year - birthdate.year;
    return age >= minAge && age <= maxAge;
  }).toList();
}

// Función para obtener la distribución de edades
Map<String, int> getAgeDistribution(List<Map<String, dynamic>> users) {
  Map<String, int> distribution = {};
  for (var range in ageRanges) {
    distribution[range['label'] as String] = 0;
  }

  for (var user in users) {
    DateTime birthdate = DateTime.parse(user['birthdate']);
    int age = DateTime.now().year - birthdate.year;
    for (var range in ageRanges) {
      if (age >= range['min'] && age <= range['max']) {
        distribution[range['label'] as String] = 
            (distribution[range['label'] as String] ?? 0) + 1;
        break;
      }
    }
  }

  return distribution;
}
