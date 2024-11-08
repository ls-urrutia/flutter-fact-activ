import 'package:flutter/material.dart';
import './buscador_productos_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import './detalle_boleta_screen.dart';
import '../../models/boleta_item.dart';
import '../../controllers/database_helper.dart';

class BoletaExpressScreen extends StatefulWidget {
  final String? codigo;
  final String? descripcion;
  final double? precioUnitario;
  final int? cantidad;
  final bool activateListener;
  final Function(BoletaItem)? onItemSaved;
  final String? id;

  BoletaExpressScreen({
    this.codigo,
    this.descripcion,
    this.precioUnitario,
    this.cantidad,
    this.activateListener = false,
    this.onItemSaved,
    this.id,
  });

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

  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<BoletaItem> boletaItems = [];

  // Add a boolean to track form validity
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    codigoController.text = widget.codigo ?? '';
    descripcionController.text = widget.descripcion ?? '';

    // Set initial values for controllers
    precioUnitarioController.text = widget.precioUnitario?.toString() ?? '';
    cantidadController.text = widget.cantidad?.toString() ?? '';

    if (widget.activateListener) {
      precioUnitarioController.addListener(_updateTotal);
    }
    cantidadController.addListener(_updateTotal);

    _loadBoletaItems();

    // Add listeners to all controllers to check form validity
    codigoController.addListener(_checkFormValidity);
    descripcionController.addListener(_checkFormValidity);
    cantidadController.addListener(_checkFormValidity);
    precioUnitarioController.addListener(_checkFormValidity);

    // Calculate initial total after setting the values
    Future.microtask(_updateTotal);
  }

  Future<void> _loadBoletaItems() async {
    final items = await _dbHelper.getBoletaItems();
    setState(() {
      boletaItems = items;
    });
  }

  Future<void> _saveBoletaItem() async {
    try {
      final newItem = BoletaItem(
        id: widget.id != null ? int.tryParse(widget.id!) : null,
        codigo: codigoController.text,
        descripcion: descripcionController.text,
        cantidad: int.tryParse(cantidadController.text) ?? 0,
        precioUnitario: double.tryParse(precioUnitarioController.text) ?? 0.0,
        valorTotal: double.tryParse(valorTotalController.text) ?? 0.0,
      );

      if (widget.id != null) {
        // Update existing item
        await _dbHelper.updateBoletaItem(newItem);
      } else {
        // Insert new item
        await _dbHelper.insertBoletaItem(newItem);
      }

      if (widget.onItemSaved != null) {
        widget.onItemSaved!(newItem);
      }
      await _loadBoletaItems();
    } catch (e) {
      print('Error saving boleta item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el item')),
      );
    }
  }

  void _updateTotal() {
    // Only show total if both fields have valid values
    if (cantidadController.text.isEmpty ||
        precioUnitarioController.text.isEmpty) {
      valorTotalController.text =
          ''; // Clear the total if either field is empty
      return;
    }

    // Parse cantidad and precioUnitario
    final cantidad = int.tryParse(cantidadController.text);
    final precioUnitario = double.tryParse(precioUnitarioController.text);

    // Only calculate and show total if both values are valid
    if (cantidad != null && precioUnitario != null) {
      final total = cantidad * precioUnitario;
      valorTotalController.text = total.toStringAsFixed(0); // No decimals
    } else {
      valorTotalController.text =
          ''; // Clear the total if either value is invalid
    }

    // Optional: Format precioUnitario for display
    if (widget.activateListener && precioUnitario != null) {
      if (precioUnitario % 1 == 0) {
        precioUnitarioController.text = precioUnitario.toStringAsFixed(0);
      } else {
        precioUnitarioController.text = precioUnitario.toString();
      }

      // Ensure the cursor stays at the end of the text
      precioUnitarioController.selection = TextSelection.fromPosition(
        TextPosition(offset: precioUnitarioController.text.length),
      );
    }
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
    // Remove listeners before disposing
    if (widget.activateListener) {
      precioUnitarioController.removeListener(_updateTotal);
    }
    codigoController.removeListener(_checkFormValidity);
    descripcionController.removeListener(_checkFormValidity);
    cantidadController.removeListener(_checkFormValidity);
    precioUnitarioController.removeListener(_checkFormValidity);

    // Dispose controllers
    Future.microtask(() {
      codigoController.dispose();
      descripcionController.dispose();
      cantidadController.dispose();
      precioUnitarioController.dispose();
      valorTotalController.dispose();
    });

    super.dispose();
  }

  void _onSomeEvent() {
    setState(() {
      // Update your state here
    });
  }

  // Add method to check form validity
  void _checkFormValidity() {
    setState(() {
      _isFormValid = codigoController.text.isNotEmpty &&
          descripcionController.text.isNotEmpty &&
          cantidadController.text.isNotEmpty &&
          precioUnitarioController.text.isNotEmpty &&
          (double.tryParse(precioUnitarioController.text) ?? 0) > 0 &&
          (int.tryParse(cantidadController.text) ?? 0) > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Boleta Express',
          style: TextStyle(fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF1A90D9),
        actions: [],
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
                    fontSize: 18,
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
                      color: Colors.grey[300], size: 26),
                  SizedBox(width: 8),
                  Icon(Icons.circle,
                      color: Color(0xFF1A90D9),
                      size: 20), // Light blue filled circle
                  SizedBox(width: 4),
                  Icon(Icons.circle,
                      color: Color(0xFF1A90D9).withOpacity(0.2),
                      size: 20), // Solid blue filled circle
                  SizedBox(width: 4),
                  Icon(Icons.arrow_circle_right_outlined,
                      color: Colors.grey[300], size: 26),
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
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Código',
                  hintText: 'Código',
                  hintStyle:
                      TextStyle(color: const Color(0xFF757c81), fontSize: 14),
                  labelStyle:
                      TextStyle(color: const Color(0xFF757c81), fontSize: 14),
                  filled: true,
                  fillColor: Colors.grey[300],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BuscadorProductosScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: 8),
              TextField(
                controller: descripcionController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Descripción',
                  hintStyle:
                      TextStyle(color: const Color(0xFF757c81), fontSize: 14),
                  labelStyle:
                      TextStyle(color: const Color(0xFF757c81), fontSize: 14),
                  filled: true,
                  fillColor: Colors.lightBlue[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: cantidadController,
                      style: TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Cantidad',
                        hintText: 'Cantidad',
                        hintStyle: TextStyle(
                            color: const Color(0xFF757c81), fontSize: 14),
                        labelStyle: TextStyle(
                            color: const Color(0xFF757c81), fontSize: 14),
                        filled: true,
                        fillColor: Colors.lightBlue[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      keyboardType: TextInputType.number,
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
                        size: 14,
                      ),
                    ),
                    onPressed: () {
                      int currentValue =
                          int.tryParse(cantidadController.text) ?? 1;
                      if (currentValue > 1) {
                        cantidadController.text = (currentValue - 1).toString();
                      }
                    },
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
                        size: 14,
                      ),
                    ),
                    onPressed: () {
                      int currentValue =
                          int.tryParse(cantidadController.text) ?? 1;
                      cantidadController.text = (currentValue + 1).toString();
                    },
                  ),
                ],
              ),
              SizedBox(height: 8),
              TextField(
                controller: precioUnitarioController,
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Precio Unitario',
                  hintText: 'Precio Unitario',
                  hintStyle:
                      TextStyle(color: const Color(0xFF757c81), fontSize: 14),
                  labelStyle:
                      TextStyle(color: const Color(0xFF757c81), fontSize: 14),
                  filled: true,
                  fillColor: Colors.lightBlue[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                keyboardType: TextInputType.number, // Ensure numeric input
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
                          filled: true,
                          fillColor: Colors.grey[300],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isFormValid
                      ? () {
                          _saveBoletaItem().then((_) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetalleBoletaScreen(
                                  codigo: codigoController.text,
                                  cantidad:
                                      int.tryParse(cantidadController.text) ??
                                          1,
                                  precioUnitario: double.tryParse(
                                          precioUnitarioController.text) ??
                                      0.0,
                                  valorTotal: double.tryParse(
                                          valorTotalController.text) ??
                                      0.0,
                                ),
                              ),
                            );
                          });
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isFormValid ? Color(0xFF1A90D9) : Colors.grey[300],
                    foregroundColor: Colors.white, // Text color when enabled
                    disabledForegroundColor:
                        Colors.white, // Text color when disabled
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    'Aceptar',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
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
