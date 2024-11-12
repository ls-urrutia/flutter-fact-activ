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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Libro de Ventas'),
        centerTitle: true,
        backgroundColor: Color(0xFF1A90D9),
      ),
      body: ListView.builder(
        itemCount: boletas.length,
        itemBuilder: (context, index) {
          final boleta = boletas[index];
          return Container(
            margin: EdgeInsets.symmetric(vertical: 1),
            color: index % 2 == 0 ? Colors.white : Color(0xFFE3F2FD),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              leading: Icon(Icons.insert_drive_file, size: 40, color: Colors.blue),
              title: Text(
                'Cliente Boleta',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('BOLETA ELECTRONICA', style: TextStyle(fontSize: 12)),
                  Text(
                    '${boleta.folio} / ${boleta.rut?.isEmpty ?? true ? "SIN REGISTRO" : boleta.rut}',
                    style: TextStyle(fontSize: 12)
                  ),
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
                        style: TextStyle(color: boleta.total < 0 ? Colors.red : Colors.black, fontSize: 14),
                      ),
                      Text(boleta.fecha, style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ],
              ),
              onTap: () => _showBoletaDetail(boleta),
            ),
          );
        },
      ),
    );
  }
}