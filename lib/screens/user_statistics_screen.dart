import 'package:flutter/material.dart';
import '../widgets/user_statistics_chart.dart';
import '../database_helper.dart'; // Asegúrate de importar DatabaseHelper

class UserStatisticsScreen extends StatefulWidget {
  @override
  _UserStatisticsScreenState createState() => _UserStatisticsScreenState();
}

class _UserStatisticsScreenState extends State<UserStatisticsScreen> {
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await DatabaseHelper().getUsers();
    setState(() {
      _users = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Estadísticas de Usuarios')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Text(
              'Distribución de edad por usuarios',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: UserStatisticsChart(users: _users),
          ),
        ],
      ),
    );
  }
}
