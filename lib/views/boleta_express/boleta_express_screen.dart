import 'package:flutter/material.dart';
import './buscador_productos_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import './detalle_boleta_screen.dart';
import '../../models/boleta_item.dart';
import '../../controllers/database_helper.dart';
import 'dart:async';
import '../main_screen.dart';  // Add this import at the top


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

  // Add debouncing
  Timer? _debounceTimer;

  Timer? _totalCalculationTimer;

  @override
  void initState() {
    super.initState();
    codigoController.text = widget.codigo ?? '';
    descripcionController.text = widget.descripcion ?? '';
    precioUnitarioController.text = widget.precioUnitario?.toString() ?? '';
    cantidadController.text = widget.cantidad?.toString() ?? '';

    // Add listeners for total calculation with micro-delay
    if (widget.activateListener) {
      precioUnitarioController.addListener(_scheduleTotalUpdate);
    }
    cantidadController.addListener(_scheduleTotalUpdate);

    // Form validation with longer debounce
    codigoController.addListener(_debouncedCheckFormValidity);
    descripcionController.addListener(_debouncedCheckFormValidity);

    _loadBoletaItems();
    Future.microtask(() {
      _updateTotal();
      _checkFormValidity();
    });
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

  void _debouncedCheckFormValidity() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) _checkFormValidity();
    });
  }

  void _scheduleTotalUpdate() {
    if (_totalCalculationTimer?.isActive ?? false) _totalCalculationTimer!.cancel();
    _totalCalculationTimer = Timer(const Duration(milliseconds: 100), () {
      if (mounted) {
        _updateTotal();
        _checkFormValidity();
      }
    });
  }

  void _updateTotal() {
    if (!mounted) return;
    
    if (cantidadController.text.isEmpty || precioUnitarioController.text.isEmpty) {
      valorTotalController.text = '';
      return;
    }

    final cantidad = int.tryParse(cantidadController.text);
    final precioUnitario = double.tryParse(precioUnitarioController.text);

    if (cantidad != null && precioUnitario != null) {
      final total = cantidad * precioUnitario;
      valorTotalController.text = total.toStringAsFixed(0);
    } else {
      valorTotalController.text = '';
    }

    if (widget.activateListener && precioUnitario != null) {
      precioUnitarioController.text = precioUnitario % 1 == 0 
          ? precioUnitario.toStringAsFixed(0) 
          : precioUnitario.toString();

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
    _totalCalculationTimer?.cancel();
    _debounceTimer?.cancel();
    
    if (widget.activateListener) {
      precioUnitarioController.removeListener(_scheduleTotalUpdate);
    }
    cantidadController.removeListener(_scheduleTotalUpdate);
    
    codigoController.removeListener(_debouncedCheckFormValidity);
    descripcionController.removeListener(_debouncedCheckFormValidity);
    cantidadController.removeListener(_debouncedCheckFormValidity);
    precioUnitarioController.removeListener(_debouncedCheckFormValidity);

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
    if (!mounted) return;
    
    final codigo = codigoController.text;
    final descripcion = descripcionController.text;
    final cantidad = int.tryParse(cantidadController.text);
    final precioUnitario = double.tryParse(precioUnitarioController.text);
    
    setState(() {
      _isFormValid = codigo.isNotEmpty &&
          descripcion.isNotEmpty &&
          cantidad != null &&
          cantidad > 0 &&
          precioUnitario != null &&
          precioUnitario > 0 &&
          valorTotalController.text.isNotEmpty;
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            // If we're editing (have an id), just go back
            if (widget.id != null) {
              Navigator.pop(context);
              return;
            }
            
            // Otherwise, clear database and go to main screen
            final items = await _dbHelper.getBoletaItems();
            for (var item in items) {
              await _dbHelper.deleteBoletaItem(item.id!);
            }
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => MainScreen(),
              ),
              (Route<dynamic> route) => false,
            );
          },
        ),
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
