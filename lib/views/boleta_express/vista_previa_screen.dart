import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import '../../models/boleta_item.dart';

class PreviewScreen extends StatelessWidget {
  final List<BoletaItem> boletaItems;

  PreviewScreen({required this.boletaItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vista Previa'),
      ),
      body: PdfPreview(
        build: (format) => _generatePdf(format, boletaItems),
      ),
    );
  }

  Future<Uint8List> _generatePdf(
      PdfPageFormat format, List<BoletaItem> items) async {
    final pdf = pw.Document();

    // Load the vista previa image
    final vistaPreviaImageBytes =
        await _loadImageFromAssets('assets/images/vista_previa_barcode.png');
    final vistaPreviaImage = pw.MemoryImage(vistaPreviaImageBytes);

    // Create a fixed page size for the receipt
    final pageFormat = PdfPageFormat(
      21.0 * PdfPageFormat.cm, // Width: 21 cm
      29.7 * PdfPageFormat.cm, // Height: 29.7 cm (A4)
      marginAll: 1.0 * PdfPageFormat.cm,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header section with company info and receipt details
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Left side - Company information
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('SERVICIOS Y TECNOLOGIA',
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text(
                        'IMPORTACION Y EXPORTACION DE\nSOFTWARE, SUMINISTROS Y COMPUTADORES',
                        style: pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 8),
                    pw.Text(
                        'GRAN AVENIDA 5018, Depto. 208\nSAN MIGUEL - SANTIAGO',
                        style: pw.TextStyle(fontSize: 10)),
                    pw.Text('Fono: (56-2) 550 552 51',
                        style: pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 4),
                    pw.Text('CASA MATRIZ-GRAN AVENIDA 5018, Depto.',
                        style: pw.TextStyle(fontSize: 10)),
                  ],
                ),
                // Right side - Receipt details in red box
                pw.Container(
                  padding: pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.red, width: 1),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('R.U.T.: 77.574.330-1',
                          style:
                              pw.TextStyle(color: PdfColors.red, fontSize: 10)),
                      pw.SizedBox(height: 4),
                      pw.Text('BOLETA ELECTRONICA',
                          style:
                              pw.TextStyle(color: PdfColors.red, fontSize: 10)),
                      pw.Text('Nº SIN FOLIO',
                          style:
                              pw.TextStyle(color: PdfColors.red, fontSize: 10)),
                      pw.SizedBox(height: 4),
                      pw.Text('S.I.I. - SANTIAGO SUR',
                          style:
                              pw.TextStyle(color: PdfColors.red, fontSize: 10)),
                      pw.Text('Santiago, 08 de noviembre de 2024',
                          style: pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            // Client code section
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 0.5),
              ),
              padding: pw.EdgeInsets.all(8),
              child: pw.Row(
                children: [
                  pw.Text('COD. Cliente', style: pw.TextStyle(fontSize: 10)),
                  pw.SizedBox(width: 20),
                  pw.Text('APP_FACTURACION', style: pw.TextStyle(fontSize: 10)),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Items table
            pw.Table(
              border: pw.TableBorder.all(width: 0.5),
              columnWidths: {
                0: pw.FlexColumnWidth(0.5), // Item
                1: pw.FlexColumnWidth(1), // Código
                2: pw.FlexColumnWidth(2), // Descripción
                3: pw.FlexColumnWidth(0.5), // U.M
                4: pw.FlexColumnWidth(0.8), // Cantidad
                5: pw.FlexColumnWidth(1), // Precio Unit.
                6: pw.FlexColumnWidth(1), // Valor
              },
              children: [
                // Table header
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    'Item',
                    'Código',
                    'Descripción',
                    'U.M',
                    'Cantidad',
                    'Precio Unit.',
                    'Valor'
                  ]
                      .map((text) => pw.Container(
                            padding: pw.EdgeInsets.all(4),
                            child: pw.Text(text,
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold)),
                          ))
                      .toList(),
                ),
                // Table data
                ...items.map((item) => pw.TableRow(
                      children: [
                        pw.Container(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text((items.indexOf(item) + 1).toString(),
                              style: pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(item.codigo,
                              style: pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(item.descripcion,
                              style: pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(4),
                          child:
                              pw.Text('UN', style: pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(item.cantidad.toString(),
                              style: pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(item.precioUnitario.toStringAsFixed(2),
                              style: pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(item.valorTotal.toStringAsFixed(2),
                              style: pw.TextStyle(fontSize: 9)),
                        ),
                      ],
                    )),
              ],
            ),

            pw.Spacer(),

            // Footer section
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Image(
                  vistaPreviaImage,
                  width: 100, // Adjust size as needed
                  height: 50, // Adjust size as needed
                  fit: pw.BoxFit.contain,
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('IVA: \$ 58.710',
                        style: pw.TextStyle(fontSize: 10)),
                    pw.Text('TOTAL: \$ 367.710',
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 10),
                    pw.Text('Monto no fact: \$ 0',
                        style: pw.TextStyle(fontSize: 10)),
                    pw.Text('Valor a pagar: \$ 0',
                        style: pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 10),

            // Observations box
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 0.5),
              ),
              padding: pw.EdgeInsets.all(8),
              child: pw.Row(
                children: [
                  pw.Text('Observaciones: ', style: pw.TextStyle(fontSize: 9)),
                  pw.Text('null', style: pw.TextStyle(fontSize: 9)),
                ],
              ),
            ),

            pw.SizedBox(height: 10),

            // Website footer
            pw.Center(
              child: pw.Text('Desarrollado por www.facturacion.cl',
                  style: pw.TextStyle(fontSize: 8)),
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  // Helper function to load images from assets
  Future<Uint8List> _loadImageFromAssets(String path) async {
    final byteData = await rootBundle.load(path);
    return byteData.buffer.asUint8List();
  }
}
