import 'package:flutter/material.dart';
import '../views/main_screen.dart';
import '../views/user_statistics_screen.dart';
import '../views/creacion_cuenta_screen.dart';
import '../views/listado_screen.dart';
import '../views/login_screen.dart'; // Import the login screen
import '../views/boleta_express/boleta_express_screen.dart'; // Add this import
import '../views/productos/crear_productos_screen.dart';  // Add this import
import '../views/productos/listado_productos_screen.dart';  // Add this import
import '../views/libro_ventas/libro_ventas_screen.dart';

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
            title: Text('Libro de Ventas'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LibroVentasScreen()),
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
            title: Text('Boleta Express'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BoletaExpressScreen()),
              );
            },
          ),
          ListTile(
            title: Text('Crear Producto'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CrearProductosScreen()),
              );
            },
          ),
          ListTile(
            title: Text('Listado de Productos'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListadoProductosScreen()),
              );
            },
          ),
          ListTile(
            title: Text('Libro de Ventas'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LibroVentasScreen()),
              );
            },
          ),
          ListTile(
            title: Text('Cerrar Sesión'),
            trailing: Icon(Icons.exit_to_app),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
