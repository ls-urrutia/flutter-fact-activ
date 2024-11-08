import 'package:flutter/material.dart';
import '../../models/product.dart';
import 'boleta_express_screen.dart';

class FilteredProductsScreen extends StatelessWidget {
  final List<Product> filteredProducts;
  final bool hasExactMatch;

  const FilteredProductsScreen({
    Key? key,
    required this.filteredProducts,
    required this.hasExactMatch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscador de Producto'),
        backgroundColor: const Color(0xFF1A90D9),
      ),
      body: ListView.builder(
        itemCount: filteredProducts.length + (hasExactMatch ? 0 : 1),
        itemBuilder: (context, index) {
          if (hasExactMatch && index == 0) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.lightBlue[50],
                border: Border.all(color: Colors.grey, width: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListTile(
                title: Text(
                  filteredProducts[0].descripcion,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  filteredProducts[0].id.toString(),
                  style: const TextStyle(fontSize: 13),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${filteredProducts[0].precio.toString()}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BoletaExpressScreen(
                        codigo: filteredProducts[0].id.toString(),
                        descripcion: filteredProducts[0].descripcion,
                        precioUnitario: filteredProducts[0].precio,
                        cantidad: 1,
                        activateListener: true,
                      ),
                    ),
                  );
                },
              ),
            );
          } else if (!hasExactMatch && index == 0) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                border: Border.all(color: Colors.grey, width: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: const Text(
                'Otras Coincidencias',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          } else {
            final productIndex = hasExactMatch ? index : index - 1;
            final product = filteredProducts[productIndex];
            return Container(
              decoration: BoxDecoration(
                color: index % 2 == 0 ? Colors.white : Colors.lightBlue[50],
                border: Border.all(color: Colors.grey, width: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListTile(
                title: Text(
                  product.descripcion,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  product.id.toString(),
                  style: const TextStyle(fontSize: 13),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '\$${product.precio.toString()}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(width: 24),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BoletaExpressScreen(
                        codigo: product.id.toString(),
                        descripcion: product.descripcion,
                        precioUnitario: product.precio,
                        cantidad: 1,
                        activateListener: true,
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
