import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import 'creacion_cuenta_screen.dart';
import 'listado_screen.dart';
import 'user_statistics_screen.dart';

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
      drawer: AppDrawer(),
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
              color: Color(0xFF808080), // Color gris oscuro para Listado
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.only(top: 1, bottom: 1, left: 1, right: 1),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              title: Text(
                'Listado',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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
          // Botón para Estadísticas de Usuarios con color gris más suave
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFA9A9A9), // Gris más suave (DarkGray)
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.only(top: 1, bottom: 1, left: 1, right: 1),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              title: Text(
                'Estadísticas de Usuarios',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Icon(Icons.chevron_right, color: Colors.white),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserStatisticsScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleCreacionCuenta(BuildContext context) {
    // Implement the logic for creating an account
    print('Creación Cuenta tapped');
  }

  void _handleListado(BuildContext context) {
    // Implement the logic for showing the list
    print('Listado tapped');
  }
}
