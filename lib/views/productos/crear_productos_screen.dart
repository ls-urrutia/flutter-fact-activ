import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/product.dart';
import '../../controllers/database_helper.dart';
import '../../widgets/app_drawer.dart';
import '../main_screen.dart';
import 'listado_productos_screen.dart';

class CrearProductosScreen extends StatefulWidget {
  @override
  _CrearProductosScreenState createState() => _CrearProductosScreenState();
}

class _CrearProductosScreenState extends State<CrearProductosScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _stockController = TextEditingController();
  final _precioController = TextEditingController();
  final _bodegaController = TextEditingController();
  bool _activo = true;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    _bodegaController.text = 'CASA MATRIZ';
  }

  Future<void> _initializeDatabase() async {
    try {
      final isOpen = await DatabaseHelper().isDatabaseOpen();
      print('Database is open: $isOpen');
      
      // Check if products table exists
      bool tableExists = await DatabaseHelper().checkIfTableExists('products');
      print('Products table exists: $tableExists');
      
      // Get all tables
      List<String> tables = await DatabaseHelper().getAllTables();
      print('All tables in database: $tables');
    } catch (e) {
      print('Error initializing database: $e');
    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      try {
        print('Creating product with values:');
        print('Código: ${_codigoController.text}');
        print('Stock: ${_stockController.text}');
        print('Descripción: ${_descripcionController.text}');
        print('Precio: ${_precioController.text}');
        print('Bodega: ${_bodegaController.text}');
        print('Activo: $_activo');

        final product = Product(
          codigo: _codigoController.text,
          stock: int.parse(_stockController.text),
          descripcion: _descripcionController.text,
          precio: double.parse(_precioController.text),
          bodega: _bodegaController.text,
          activo: _activo,
        );

        await DatabaseHelper().insertProduct(product);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto guardado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          _clearForm();
        }
      } catch (e, stackTrace) {
        print('Error saving product: $e');
        print('Stack trace: $stackTrace');
        
        if (mounted) {
          String errorMessage = 'Error al guardar el producto';
          if (e.toString().contains('UNIQUE constraint failed')) {
            errorMessage = 'Ya existe un producto con este código';
          } else if (e.toString().contains('database_closed')) {
            errorMessage = 'Error de conexión con la base de datos. Intente nuevamente';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  void _clearForm() {
    _codigoController.clear();
    _descripcionController.clear();
    _stockController.clear();
    _precioController.clear();
    _bodegaController.clear();
    setState(() {
      _activo = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Crear Producto',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF1A90D9),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _codigoController,
                    decoration: InputDecoration(
                      labelText: 'Código',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el código';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _descripcionController,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese la descripción';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _stockController,
                    decoration: InputDecoration(
                      labelText: 'Stock',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el stock';
                      }
                      if (int.tryParse(value) == null) {
                        return 'El stock debe ser un número';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _precioController,
                    decoration: InputDecoration(
                      labelText: 'Precio',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el precio';
                      }
                      if (int.tryParse(value) == null) {
                        return 'El precio debe ser un número';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _bodegaController,
                    decoration: InputDecoration(
                      labelText: 'Bodega',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    enabled: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese la bodega';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  SwitchListTile(
                    title: Text('Activo'),
                    value: _activo,
                    onChanged: (bool value) {
                      setState(() {
                        _activo = value;
                      });
                    },
                    activeColor: Colors.white,
                    activeTrackColor: Color(0xFF1A90D9),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey,
                  ),
                  SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1A90D9),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Guardar Producto',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ListadoProductosScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF52C5F2),
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Ver Listado Productos',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MainScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFA0A090),
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Inicio',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
