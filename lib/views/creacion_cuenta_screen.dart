import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../controllers/database_helper.dart';
import '../widgets/app_drawer.dart';

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
  bool _isRegistering = false;

  Future<void> _fetchFromApi() async {
    setState(() {
      _isApiButtonDisabled = true;
    });

    try {
      final response = await http.get(Uri.parse('https://randomuser.me/api/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = data['results'][0];
        _nameController.text =
            '${user['name']['first']} ${user['name']['last']}';
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

      print('User registered: $user');

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
            fontSize: 18,
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
      drawer: AppDrawer(),
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
                  if (!RegExp(r'^[\p{L}\s]{2,50}$', unicode: true)
                      .hasMatch(value)) {
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
                  if (!RegExp(
                          r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$')
                      .hasMatch(value)) {
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
                          _isRegistering = true;
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
