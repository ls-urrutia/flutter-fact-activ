import 'package:flutter/material.dart';
import '../../models/product.dart';
import 'boleta_express_screen.dart';

class FilteredProductsScreen extends StatelessWidget {
  final List<Product> exactMatches;
  final List<Product> partialMatches;
  final bool hasExactMatch;

  const FilteredProductsScreen({
    Key? key,
    required this.exactMatches,
    required this.partialMatches,
    required this.hasExactMatch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemCount = exactMatches.length + 
                     (partialMatches.isEmpty ? 0 : 1) + 
                     partialMatches.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscador de Producto'),
        backgroundColor: const Color(0xFF1A90D9),
      ),
      body: ListView.builder(
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index < exactMatches.length) {
            final product = exactMatches[index];
            return _buildProductTile(context, product, Colors.lightBlue[50]);
          }
          
          if (index == exactMatches.length && partialMatches.isNotEmpty) {
            return _buildOtrasCoincidenciasHeader();
          }
          
          if (partialMatches.isNotEmpty) {
            final partialIndex = index - exactMatches.length - 1;
            final product = partialMatches[partialIndex];
            return _buildProductTile(
              context, 
              product, 
              partialIndex % 2 == 0 ? Colors.white : Colors.lightBlue[50]
            );
          }
          
          return SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProductTile(BuildContext context, Product product, Color? backgroundColor) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: Colors.grey, width: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ListTile(
        title: Text(
          product.descripcion,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${product.codigo}',
          style: const TextStyle(fontSize: 13),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '\$${product.precio % 1 == 0 ? product.precio.toInt() : product.precio}',
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
                codigo: product.codigo,
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

  Widget _buildOtrasCoincidenciasHeader() {
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
  }
}
