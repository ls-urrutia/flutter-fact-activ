import 'package:flutter/material.dart';
import '../widgets/user_statistics_chart.dart';
import '../controllers/database_helper.dart'; // Correct path to DatabaseHelper
import '../widgets/app_drawer.dart';

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
    try {
      final users = await DatabaseHelper().getUsers();
      setState(() {
        _users = users;
      });
      print('Users loaded: $_users');
    } catch (e) {
      print('Error loading users: $e');
      // Optionally, show a SnackBar or some UI feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Estadísticas Usuarios')),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Distribución de usuarios por rango etario',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              UserStatisticsChart(users: _users),
            ],
          ),
        ),
      ),
    );
  }
}
