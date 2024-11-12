import 'package:flutter/material.dart';
import 'main_screen.dart'; // Correct path to MainScreen
import 'registro_screen.dart';
import '../controllers/database_helper.dart'; // Correct path to DatabaseHelper
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _login() async {
    final email = _usernameController.text;
    final password = _passwordController.text;

    // Store logged in user email in shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('loggedInUser', email);

    // Check for default admin credentials
    if (email == 'admin@facturacion.cl' && password == '123') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
      return;
    }

    final users = await DatabaseHelper().getUsers();

    print(users);

    final user = users.firstWhere(
      (user) => user['email'] == email && user['password'] == password,
      orElse: () => {},
    );

    if (user.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Credenciales incorrectas')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Facturacion.cl'),
        centerTitle: true,
        backgroundColor: Color(0xFF1A90D9),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Usuario',
                labelStyle: TextStyle(color: Colors.grey), // Change label color
                prefixIcon:
                    Icon(Icons.person, color: Colors.grey), // Change icon color
                border: UnderlineInputBorder(), // Change to underline
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Color(0xFF1A90D9)), // Change focused color
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Clave',
                labelStyle: TextStyle(color: Colors.grey), // Change label color
                prefixIcon: Icon(Icons.vpn_key,
                    color: Colors.grey), // Change icon color
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey, // Change icon color
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
                border: UnderlineInputBorder(), // Change to underline
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Color(0xFF1A90D9)), // Change focused color
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _login,
                child: Text('Ingresar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1A90D9),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegistroScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1A90D9),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: Text('Registrar nueva cuenta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
