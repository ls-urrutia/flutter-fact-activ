import 'package:flutter/material.dart';
import '../../models/product.dart';
import 'productos_filtrados_screen.dart';

class BuscadorProductosScreen extends StatefulWidget {
  @override
  _BuscadorProductosScreenState createState() =>
      _BuscadorProductosScreenState();
}

class _BuscadorProductosScreenState extends State<BuscadorProductosScreen> {
  final List<Product> products = [
    Product(
        id: 1,
        stock: 10,
        descripcion: 'Coca Cola 2L',
        precio: 1800,
        bodega: 'Bodega CCU',
        activo: true),
    Product(
        id: 2,
        stock: 5,
        descripcion: 'Harina 1Kg Collico',
        precio: 1500,
        bodega: 'Bodega Collico',
        activo: false),
    Product(
        id: 3,
        stock: 0,
        descripcion: 'Bolsa basura 80x100, 10 Un',
        precio: 1000,
        bodega: 'Bodega Lider',
        activo: true),
  ];

  List<Product> filteredProducts = [];
  final TextEditingController codigoController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  bool? _activeFilter;

  @override
  void initState() {
    super.initState();
    filteredProducts = products;
  }

  void _searchProducts() {
    String codigo = codigoController.text.toLowerCase();
    String descripcion = descripcionController.text.toLowerCase();

    // Show alert only if both codigo and descripcion are empty
    if (codigo.isEmpty && descripcion.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Buscar Producto'),
            content: Text('Debe agregar algún parámetro de búsqueda'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Aceptar'),
              ),
            ],
          );
        },
      );
      return;
    }

    setState(() {
      // Exact matches
      List<Product> exactMatches = products.where((product) {
        return product.id.toString() == codigo &&
            product.descripcion.toLowerCase().contains(descripcion) &&
            (_activeFilter == null || product.activo == _activeFilter);
      }).toList();

      // Partial matches
      List<Product> partialMatches = products.where((product) {
        return product.id.toString().contains(codigo) &&
            product.descripcion.toLowerCase().contains(descripcion) &&
            (_activeFilter == null || product.activo == _activeFilter) &&
            product.id.toString() != codigo;
      }).toList();

      // Determine if we have an exact match
      bool hasExactMatch = exactMatches.isNotEmpty;

      // Combine results based on whether we have an exact match
      if (hasExactMatch) {
        filteredProducts = [...exactMatches, ...partialMatches];
      } else {
        filteredProducts = partialMatches;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FilteredProductsScreen(
            filteredProducts: filteredProducts,
            hasExactMatch: hasExactMatch,
          ),
        ),
      );
    });
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
