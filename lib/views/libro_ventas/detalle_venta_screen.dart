import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/boleta_document.dart';
import 'dart:io';
import '../../views/boleta_express/vista_previa_screen.dart';
import '../../controllers/database_helper.dart';

class DetalleVentaScreen extends StatelessWidget {
  final BoletaRecord boleta;

  DetalleVentaScreen({required this.boleta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle Venta'),
        centerTitle: true,
        backgroundColor: Color(0xFF1A90D9),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                Text('Cliente Boleta',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BOLETA ELECTRONICA',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child:
                              Text('Folio: ', style: TextStyle(fontSize: 14)),
                        ),
                        SizedBox(width: 40),
                        Expanded(
                          child: Text(boleta.folio,
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text('Monto Total: ',
                              style: TextStyle(fontSize: 14)),
                        ),
                        SizedBox(width: 40),
                        Expanded(
                          child: Text(
                              '\$${NumberFormat('#,###', 'es_CL').format(boleta.total)}',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text('Estado DTE en SII: ',
                              style: TextStyle(fontSize: 14)),
                        ),
                        SizedBox(width: 40),
                        Expanded(
                          child: Text('✅ ${boleta.estado}',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text('Periodo',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text('Periodo Contable: ',
                              style: TextStyle(fontSize: 14)),
                        ),
                        SizedBox(width: 40),
                        Expanded(
                          child: Text(boleta.fecha.substring(0, 7),
                              style: TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text('Fecha documento: ',
                              style: TextStyle(fontSize: 14)),
                        ),
                        SizedBox(width: 40),
                        Expanded(
                          child: Text(boleta.fecha,
                              style: TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text('Sucursal: ',
                              style: TextStyle(fontSize: 14)),
                        ),
                        SizedBox(width: 40),
                        Expanded(
                          child: Text('SAN MIGUEL',
                              style: TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child:
                              Text('Usuario: ', style: TextStyle(fontSize: 14)),
                        ),
                        SizedBox(width: 40),
                        Expanded(
                          child: Text(boleta.usuario ?? "J.CAMPOS",
                              style: TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text('Fecha de ingreso: ',
                              style: TextStyle(fontSize: 14)),
                        ),
                        SizedBox(width: 40),
                        Expanded(
                          child: Text(
                              DateTime.now().toString().substring(0, 19),
                              style: TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 40),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PreviewScreen(
                          pdfFile: File(boleta.pdfPath),
                          showAppBar: true,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Ver PDF',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFF1A90D9),
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
                /* Commented out Anular Documento button for future use
                SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    // Show confirmation dialog
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Confirmar Eliminación'),
                        content: Text('¿Está seguro que desea eliminar este documento?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('Anular'),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      try {
                        final dbHelper = DatabaseHelper();
                        final success = await dbHelper.deleteBoletaRecord(boleta.folio);

                        if (success) {
                          Navigator.of(context).pop(true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Documento eliminado correctamente')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('No se pudo anular el documento. Intente nuevamente.')),
                          );
                        }
                      } catch (e) {
                        print('Error al anular documento: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al anular el documento: ${e.toString()}')),
                        );
                      }
                    }
                  },
                  child: Text(
                    'Anular Documento',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFFFF5252),
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
                */
              ],
            ),
          ),
        ],
      ),
    );
  }
}
