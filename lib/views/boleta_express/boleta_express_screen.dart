import 'package:flutter/material.dart';
import './buscador_productos_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class BoletaExpressScreen extends StatefulWidget {
  @override
  _BoletaExpressScreenState createState() => _BoletaExpressScreenState();
}

class _BoletaExpressScreenState extends State<BoletaExpressScreen> {
  final TextEditingController codigoController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();
  final TextEditingController precioUnitarioController =
      TextEditingController();
  final TextEditingController valorTotalController = TextEditingController();

  bool get isFormValid {
    return codigoController.text.isNotEmpty &&
        descripcionController.text.isNotEmpty &&
        cantidadController.text.isNotEmpty &&
        precioUnitarioController.text.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    codigoController.addListener(_onFieldChanged);
    descripcionController.addListener(_onFieldChanged);
    cantidadController.addListener(_onFieldChanged);
    precioUnitarioController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {
      // This will rebuild the widget and update the button state
    });
  }

  void clearForm() {
    codigoController.clear();
    descripcionController.clear();
    cantidadController.clear();
    precioUnitarioController.clear();
    valorTotalController.clear();
  }

  @override
  void dispose() {
    codigoController.dispose();
    descripcionController.dispose();
    cantidadController.dispose();
    precioUnitarioController.dispose();
    valorTotalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Boleta Express'),
        centerTitle: true,
        backgroundColor: Color(0xFF1A90D9),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              // Help action
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Agregar Detalle',
                  style: TextStyle(
                    fontSize: 24,
                    color: Color(0xFF1A90D9),
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Step indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_circle_left_outlined,
                      color: Colors.grey[300], size: 24),
                  SizedBox(width: 8),
                  Icon(Icons.circle,
                      color: Color(0xFF1A90D9),
                      size: 24), // Light blue filled circle
                  SizedBox(width: 8),
                  Icon(Icons.circle,
                      color: Color(0xFF1A90D9).withOpacity(0.2),
                      size: 24), // Solid blue filled circle
                  SizedBox(width: 8),
                  Icon(Icons.arrow_circle_right_outlined,
                      color: Colors.grey[300], size: 24),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.search_outlined,
                            color: Colors.blue, size: 30),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BuscadorProductosScreen(),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 16),
                      Icon(Icons.star_outline, color: Colors.blue, size: 30),
                      SizedBox(width: 16),
                      Icon(MdiIcons.barcode, color: Colors.blue, size: 30),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.blue, size: 30),
                    onPressed: clearForm,
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextField(
                controller: codigoController,
                readOnly: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BuscadorProductosScreen(),
                    ),
                  );
                },
                decoration: InputDecoration(
                  labelText: 'Código',
                  filled: true,
                  fillColor: Colors.grey[300],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: descripcionController,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  filled: true,
                  fillColor: Color(0xFFE3F2FD),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: cantidadController,
                      decoration: InputDecoration(
                        labelText: 'Cantidad',
                        filled: true,
                        fillColor: Color(0xFFE3F2FD),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[400]!),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue, width: 2.0),
                      ),
                      child: Icon(
                        Icons.arrow_downward,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue, width: 2.0),
                      ),
                      child: Icon(
                        Icons.arrow_upward,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              SizedBox(height: 8),
              TextField(
                controller: precioUnitarioController,
                decoration: InputDecoration(
                  labelText: 'Precio Unitario',
                  filled: true,
                  fillColor: Color(0xFFE3F2FD),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Valor Total',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.blue,
                          width: 2.0,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: TextField(
                        controller: valorTotalController,
                        enabled: false,
                        decoration: InputDecoration(
                          enabled: false,
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          filled: true,
                          fillColor: Colors.grey[300],
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text('Aceptar'),
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
            ],
          ),
        ),
      ),
    );
  }
}
