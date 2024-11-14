import 'package:flutter/material.dart';
import '../../models/boleta_document.dart';
import '../../controllers/database_helper.dart';
import 'package:intl/intl.dart';
import '../../views/libro_ventas/detalle_venta_screen.dart';

class LibroVentasScreen extends StatefulWidget {
  @override
  _LibroVentasScreenState createState() => _LibroVentasScreenState();
}

class _LibroVentasScreenState extends State<LibroVentasScreen> {
  final formatter = NumberFormat('#,###', 'es_CL');
  List<BoletaRecord> boletas = [];
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    _loadBoletas();
  }

  Future<void> _loadBoletas() async {
    final records = await DatabaseHelper().getBoletaRecords();
    setState(() {
      boletas = records;
    });
  }

  void _showBoletaDetail(BoletaRecord boleta) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleVentaScreen(boleta: boleta),
      ),
    );

    if (result == true) {
      await _loadBoletas();
    }
  }

  String _formatFolioDisplay(String folio) {
    if (folio.startsWith('NC')) {
      return folio;
    } else {
      return folio.padLeft(6, '0');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Libro de Ventas'),
        centerTitle: true,
        backgroundColor: Color(0xFF1A90D9),
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart_outlined), // Statistics/bars icon
            onPressed: () {
              // Add statistics functionality here
            },
          ),
          IconButton(
            icon: Icon(Icons.search), // Search icon
            onPressed: () {
              // Add search functionality here
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: boletas.length,
        itemBuilder: (context, index) {
          final boleta = boletas[index];
          final isNotaCredito = boleta.estado == 'Nota Credito';
          final isSelected = selectedIndex == index;

          return Container(
            margin: EdgeInsets.symmetric(vertical: 0),
            color: index % 2 == 0 ? Colors.white : Color(0xFFE3F2FD),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              dense: true,
              leading: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.description,
                    size: 32,
                    color: isNotaCredito ? Colors.red : Colors.blue,
                  ),
                  if (isNotaCredito)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.remove,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              title: Text(
                'Cliente ${isNotaCredito ? "Nota Crédito" : "Boleta"}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isSelected ? Color(0xFF1A90D9) : Colors.black,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      isNotaCredito
                          ? 'NOTA DE CREDITO ELECTRONICA'
                          : 'BOLETA ELECTRONICA',
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Color(0xFF1A90D9) : Colors.black87,
                      )),
                  Text(
                      '${_formatFolioDisplay(boleta.folio)} / ${boleta.rut?.isEmpty ?? true ? "SIN REGISTRO" : boleta.rut}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Color(0xFF1A90D9) : Colors.black87,
                      )),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${formatter.format(boleta.total)}',
                        style: TextStyle(
                            color: isSelected
                                ? Color(0xFF1A90D9)
                                : (boleta.total < 0
                                    ? Colors.red
                                    : Colors.black),
                            fontSize: 13),
                      ),
                      Text(boleta.fecha,
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                isSelected ? Color(0xFF1A90D9) : Colors.black87,
                          )),
                    ],
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: isSelected
                        ? Color(0xFF1A90D9)
                        : Colors.black.withOpacity(0.3),
                    size: 20,
                  ),
                ],
              ),
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
                _showBoletaDetail(boleta);
              },
            ),
          );
        },
      ),
    );
  }
}
