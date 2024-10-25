import 'package:flutter/material.dart';
import '../views/main_screen.dart';
import '../views/user_statistics_screen.dart';
import '../views/creacion_cuenta_screen.dart';
import '../views/listado_screen.dart';
import '../views/login_screen.dart'; // Import the login screen

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
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
              Navigator.push(
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListadoScreen()),
              );
            },
          ),
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
          ListTile(
            title: Text('Cerrar Sesión'),
            trailing: Icon(Icons.exit_to_app),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
