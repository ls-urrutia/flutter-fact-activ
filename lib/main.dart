import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'database_helper.dart';
import 'detalle_cuenta_screen.dart'; 
import 'login_screen.dart'; // Import the login screen
import 'screens/user_statistics_screen.dart'; // Añade esta línea


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

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Facturacion.cl',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500, // Adjust font weight
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            ListTile(
              title: Text('Inicio'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Creación Cuenta'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => CreacionCuentaScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Listado'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ListadoScreen()),
                );
              },
            ),
            // Añade esta nueva ListTile para la pantalla de estadísticas
            ListTile(
              title: Text('Estadísticas de Usuarios'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserStatisticsScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF52C5F2), // Background color
              borderRadius: BorderRadius.circular(12), // Rounded corners
            ),
            margin: EdgeInsets.only(top: 4, bottom: 1, left: 1, right: 1), // Different top and bottom margins
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              title: Text(
                'Creación Cuenta',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold, // Make text bold
                ),
              ),
              trailing: Icon(Icons.chevron_right, color: Colors.white),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreacionCuentaScreen()),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF808080), // Background color
              borderRadius: BorderRadius.circular(12), // Rounded corners
            ),
            margin: EdgeInsets.only(top: 1, bottom: 1, left: 1, right: 1), // Different top and bottom margins
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              title: Text(
                'Listado',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold, // Make text bold
                ),
              ),
              trailing: Icon(Icons.chevron_right, color: Colors.white),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListadoScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CreacionCuentaScreen extends StatefulWidget {
  @override
  _CreacionCuentaScreenState createState() => _CreacionCuentaScreenState();
}

class _CreacionCuentaScreenState extends State<CreacionCuentaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isApiButtonDisabled = false;
  bool _isRegisterButtonEnabled = false;
  bool _isRegistering = false; // New variable to track registration state

  Future<void> _fetchFromApi() async {
    setState(() {
      _isApiButtonDisabled = true;
    });

    try {
      final response = await http.get(Uri.parse('https://randomuser.me/api/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = data['results'][0];
        _nameController.text = '${user['name']['first']} ${user['name']['last']}';
        _emailController.text = user['email'];
        _addressController.text = user['location']['street']['name'];
        _dobController.text = user['dob']['date'].substring(0, 10);
        _phoneController.text = _sanitizePhoneNumber(user['phone']);
        _passwordController.text = user['login']['password'];
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        _isApiButtonDisabled = false;
      });
    }
  }

  String _sanitizePhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }

  void _validateForm() {
    setState(() {
      _isRegisterButtonEnabled = _formKey.currentState?.validate() ?? false;
    });
  }

  void _registerUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      final user = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'birthdate': _dobController.text,
        'address': _addressController.text,
        'password': _passwordController.text,
      };

      await DatabaseHelper().insertUser(user);

      // Debugging: Print to console
      print('User registered: $user');

      // Refresh the screen
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreacionCuentaScreen()),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Creación Cuenta',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18, // Adjust font size as needed
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, // Center the title
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Open the drawer
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            ListTile(
              title: Text('Inicio'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()), // Redirect to MainScreen
                );
              },
            ),
            ListTile(
              title: Text('Creación Cuenta'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => CreacionCuentaScreen()), // Redirect to CreacionCuentaScreen
                );
              },
            ),
            ListTile(
              title: Text('Listado'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ListadoScreen()), // Redirect to ListadoScreen
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          onChanged: _validateForm,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre Completo',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su nombre';
                  }
                  if (!RegExp(r'^[\p{L}\s]{2,50}$', unicode: true).hasMatch(value)) {
                    return 'Solo letras y espacios, 2-50 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su correo electrónico';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Formato de correo inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su dirección';
                  }
                  if (value.length < 5 || value.length > 100) {
                    return 'Longitud: 5-100 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _dobController,
                decoration: const InputDecoration(
                  labelText: 'Fecha Nacimiento',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su fecha de nacimiento';
                  }
                  DateTime? dob = DateTime.tryParse(value);
                  if (dob == null || dob.isAfter(DateTime.now())) {
                    return 'Debe ser una fecha pasada';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Número de Teléfono',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su número de teléfono';
                  }
                  if (!RegExp(r'^\d{10,15}$').hasMatch(value)) {
                    return 'Solo números, longitud: 10-15 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su contraseña';
                  }
                  if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$').hasMatch(value)) {
                    return 'Requiere mayúsculas, minusculas, número y carácter especial';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isRegisterButtonEnabled && !_isRegistering
                    ? () {
                        setState(() {
                          _isRegistering = true; // Disable button
                        });
                        _registerUser();
                      }
                    : null,
                child: const Text('Registrar Usuario'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isApiButtonDisabled ? null : _fetchFromApi,
                child: const Text('Obtener Desde API'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ListadoScreen extends StatefulWidget {
  @override
  _ListadoScreenState createState() => _ListadoScreenState();
}

class _ListadoScreenState extends State<ListadoScreen> {
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(_filterUsers);
  }

  Future<void> _fetchUsers() async {
    final users = await DatabaseHelper().getUsers();
    setState(() {
      _users = users;
      _filteredUsers = users;
    });
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        return user['name'].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Listado',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            ListTile(
              title: Text('Inicio'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Creación Cuenta'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => CreacionCuentaScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Listado'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ListadoScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Nombre',
                hintStyle: TextStyle(color: Colors.grey), // Cambia el color aquí
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.0), // Only horizontal margins
                  color: index % 2 == 0 ? Color(0xFFE0F7FA) : Color(0xFFF4FCFF), // Alterna entre dos colores
                  child: ListTile(
                    title: Text(
                      user['name'],
                      style: TextStyle(color: Colors.black),
                    ),
                    subtitle: Text(
                      '${user['phone']} ${user['email']}',
                      style: TextStyle(color: Colors.black54),
                    ),
                    trailing: Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalleCuentaScreen(
                            name: user['name'],
                            email: user['email'],
                            phone: user['phone'],
                            birthdate: user['birthdate'],
                            address: user['address'],
                            password: user['password'],
                            userId: user['id'].toString(),
                          ),
                        ),
                      );

                      if (result == true) {
                        _fetchUsers(); // Refresh the list
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}










