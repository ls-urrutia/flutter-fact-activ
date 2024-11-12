import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../controllers/database_helper.dart';
import 'productos_filtrados_screen.dart';
import 'package:flutter/services.dart';

class BuscadorProductosScreen extends StatefulWidget {
  @override
  _BuscadorProductosScreenState createState() =>
      _BuscadorProductosScreenState();
}

class _BuscadorProductosScreenState extends State<BuscadorProductosScreen> {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  final TextEditingController codigoController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  bool? _activeFilter;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final dbProducts = await DatabaseHelper().getProducts();
      setState(() {
        products = dbProducts;
        filteredProducts = dbProducts;
      });
    } catch (e) {
      print('Error loading products: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar los productos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _searchProducts() {
    String codigo = codigoController.text.toLowerCase();
    String descripcion = descripcionController.text.toLowerCase();

    if (codigo.isEmpty && descripcion.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Buscar Producto'),
            content: Text('Debe agregar algún parámetro de búsqueda'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Aceptar'),
              ),
            ],
          );
        },
      );
      return;
    }

    List<Product> exactMatches = [];
    List<Product> partialMatches = [];

    for (var product in products) {
      bool matchesFilter = _activeFilter == null || product.activo == _activeFilter;
      if (!matchesFilter) continue;

      if (codigo.isNotEmpty) {
        if (product.codigo == codigo) {
          exactMatches.add(product);
        } else if (product.codigo.toLowerCase().contains(codigo)) {
          partialMatches.add(product);
        }
      } else if (descripcion.isNotEmpty) {
        if (product.descripcion.toLowerCase() == descripcion) {
          exactMatches.add(product);
        } else if (product.descripcion.toLowerCase().contains(descripcion)) {
          partialMatches.add(product);
        }
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilteredProductsScreen(
          exactMatches: exactMatches,
          partialMatches: partialMatches,
          hasExactMatch: exactMatches.isNotEmpty,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscador de Producto'),
        centerTitle: true,
        backgroundColor: Color(0xFF1A90D9),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: codigoController,
              decoration: InputDecoration(
                labelText: 'Código',
                labelStyle: TextStyle(
                  color: const Color(0xFF757c81),
                  fontSize: 16,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFF757c81)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFF1A90D9)),
                ),
                floatingLabelStyle: TextStyle(color: const Color(0xFF1A90D9)),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descripcionController,
              decoration: InputDecoration(
                labelText: 'Descripción',
                labelStyle: TextStyle(
                  color: const Color(0xFF757c81),
                  fontSize: 16,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFF757c81)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFF1A90D9)),
                ),
                floatingLabelStyle: TextStyle(color: const Color(0xFF1A90D9)),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<bool?>(
              decoration: InputDecoration(
                labelText: 'Activo',
                labelStyle: TextStyle(
                  color: const Color(0xFF757c81),
                  fontSize: 16,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFF757c81)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFF1A90D9)),
                ),
                floatingLabelStyle: MaterialStateTextStyle.resolveWith(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.focused)) {
                      return TextStyle(color: const Color(0xFF1A90D9));
                    }
                    return TextStyle(color: const Color(0xFF757c81));
                  },
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: null,
                  child: Text(''),
                ),
                DropdownMenuItem(
                  value: true,
                  child: Text('Si'),
                ),
                DropdownMenuItem(
                  value: false,
                  child: Text('No'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _activeFilter = value;
                });
              },
              value: _activeFilter,
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _searchProducts,
                child: Text('Buscar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 23, 123, 185),
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
    );
  }
}
