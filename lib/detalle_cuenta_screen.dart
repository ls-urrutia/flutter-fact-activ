import 'package:flutter/material.dart';
import 'package:act2/database_helper.dart'; // Import the DatabaseHelper
import 'main.dart';

class DetalleCuentaScreen extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String birthdate;
  final String address;
  final String password;
  final String userId;

  DetalleCuentaScreen({
    required this.name,
    required this.email,
    required this.phone,
    required this.birthdate,
    required this.address,
    required this.password,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle Cuenta', textAlign: TextAlign.center), // Center the title
        centerTitle: true, // Center the title in the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nombre: $name', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Correo Electrónico: $email', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Teléfono: $phone', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Fecha de Nacimiento: $birthdate', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Dirección: $address', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Contraseña: $password', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            Center( // Center the button
              child: ElevatedButton(
                onPressed: () {
                  _confirmDeletion(context);
                },
                child: Text('Eliminar Cuenta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 130, vertical: 30), // Adjust padding
                  textStyle: TextStyle(fontSize: 18), // Adjust font size
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeletion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Eliminación'),
          content: Text('¿Está seguro de que desea eliminar esta cuenta?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _deleteAccount(context);
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteAccount(BuildContext context) async {
    int id = int.parse(userId);

    bool success = await DatabaseHelper().deleteUserById(id);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cuenta eliminada con éxito')),
      );

      // Delay to allow the user to see the success message
      await Future.delayed(Duration(seconds: 1));

      // Navigate back to the ListadoScreen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ListadoScreen()),
        (Route<dynamic> route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar la cuenta')),
      );
    }
  }
}
