import 'package:flutter/material.dart';
import 'controllers/database_helper.dart';
import 'views/login_screen.dart'; // Import the login screen
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the database
  await DatabaseHelper().database;

  // Call to delete the database (if needed)
  await DatabaseHelper()
      .deleteUserDatabase(); // Add this line to delete the database

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
          titleTextStyle: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF52C5F2),
            foregroundColor: Colors.white,
            textStyle:
                TextStyle(fontWeight: FontWeight.bold), // Make button text bold
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(
                vertical: 22, horizontal: 32), // Increase horizontal padding
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle:
              TextStyle(color: Colors.grey), // Set label text color to grey
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
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('es', 'ES'),
      ],
    );
  }
}
