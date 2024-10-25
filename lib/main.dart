import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'controllers/database_helper.dart';
import 'views/detalle_cuenta_screen.dart'; 
import 'views/login_screen.dart'; // Import the login screen
import 'views/user_statistics_screen.dart'; // Añade esta línea
import 'widgets/app_drawer.dart';
import 'views/main_screen.dart'; // Import the main screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the database
  await DatabaseHelper().database;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Proyecto Flutter',
      theme: ThemeData(
        primaryColor: Color(0xFF1A90D9),
        appBarTheme: AppBarTheme(
          color: Color(0xFF1A90D9),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF52C5F2),
            foregroundColor: Colors.white,
            textStyle: TextStyle(fontWeight: FontWeight.bold), // Make button text bold
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(vertical: 22, horizontal: 32), // Increase horizontal padding
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.grey), // Set label text color to grey
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFF1A90D9), width: 2),
          ),
        ),
      ),
      home: LoginScreen(),
    );
  }
}
