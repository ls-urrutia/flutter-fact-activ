import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import '../models/boleta_item.dart';
import 'package:intl/intl.dart';

class PDFService {
  static Future<Uint8List> generatePdf(List<BoletaItem> items) async {
    final pdf = pw.Document();
    final formatter = NumberFormat('#,###', 'es_CL');
    
    // Load the vista previa image
    final vistaPreviaImageBytes =
        await _loadImageFromAssets('assets/images/vista_previa_barcode.png');
    final vistaPreviaImage = pw.MemoryImage(vistaPreviaImageBytes);

    // Calculate totals
    double total = items.fold(0.0, (sum, item) => sum + item.valorTotal);
    double iva = total * 0.19;
    double totalConIva = total + iva;

    // Create page format
    final pageFormat = PdfPageFormat(
      21.0 * PdfPageFormat.cm,
      29.7 * PdfPageFormat.cm,
      marginAll: 1.0 * PdfPageFormat.cm,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: pw.EdgeInsets.all(1.0 * PdfPageFormat.cm),
        header: (context) => pw.Column(
          children: [
            // Header section (company info and receipt details)
            _buildHeader(),
            pw.SizedBox(height: 40),
            // Client code section
            _buildClientCode(),
            pw.SizedBox(height: 20),
          ],
        ),
        footer: (context) => pw.Column(
          children: [
            // Footer section with barcode and totals
            _buildFooter(vistaPreviaImage, formatter, total, iva),
            pw.SizedBox(height: 10),
            // Website footer
            pw.Center(
              child: pw.Text(
                'Desarrollado por www.facturacion.cl',
                style: pw.TextStyle(fontSize: 8),
              ),
            ),
          ],
        ),
        build: (context) => [
          // Table section (this will automatically flow to new pages if needed)
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 0.5),
            ),
            child: pw.Table(
              border: null,
              columnWidths: {
                0: pw.FlexColumnWidth(0.5),
                1: pw.FlexColumnWidth(1),
                2: pw.FlexColumnWidth(2),
                3: pw.FlexColumnWidth(0.5),
                4: pw.FlexColumnWidth(0.8),
                5: pw.FlexColumnWidth(1),
                6: pw.FlexColumnWidth(1),
                7: pw.FlexColumnWidth(1),
              },
              children: [
                // Table header
                _buildTableHeader(),
                // Table rows
                ...items.map((item) => _buildTableRow(item, formatter, items.indexOf(item))),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> _loadImageFromAssets(String path) async {
    final byteData = await rootBundle.load(path);
    return byteData.buffer.asUint8List();
  }

  static pw.Widget _buildHeader() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Left side - Company information
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('SERVICIOS Y TECNOLOGIA',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text(
                  'IMPORTACION Y EXPORTACION DE\nSOFTWARE, SUMINISTROS Y COMPUTADORES',
                  style: pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center),
              pw.SizedBox(height: 8),
              pw.Text(
                  'GRAN AVENIDA 5018, Depto. 208\nSAN MIGUEL - SANTIAGO',
                  style: pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center),
              pw.Text('Fono: (56-2) 550 552 51',
                  style: pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center),
              pw.SizedBox(height: 4),
              pw.Text('CASA MATRIZ-GRAN AVENIDA 5018, Depto.',
                  style: pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center),
            ],
          ),
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
                  style: pw.TextStyle(
                      color: PdfColors.redAccent, fontSize: 10)),
              pw.Text('Nº SIN FOLIO',
                  style: pw.TextStyle(
                      color: PdfColors.redAccent, fontSize: 10)),
              pw.SizedBox(height: 4),
              pw.Text('S.I.I. - SANTIAGO SUR',
                  style: pw.TextStyle(
                      color: PdfColors.redAccent, fontSize: 10)),
              pw.Text('Santiago, 08 de noviembre de 2024',
                  style: pw.TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildClientCode() {
    return pw.Container(
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
    );
  }

  static pw.Widget _buildFooter(pw.MemoryImage vistaPreviaImage, NumberFormat formatter, double total, double iva) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Image(
              vistaPreviaImage,
              width: 200, // Increased image size
              height: 100, // Increased image size
              fit: pw.BoxFit.contain,
            ),
            pw.SizedBox(height: 5),
            pw.Align(
              alignment: pw.Alignment.center, // Center the text
              child: pw.Column(
                children: [
                  pw.Text('Timbre Electronico S.I.I.',
                      style: pw.TextStyle(
                          fontSize: 8, fontWeight: pw.FontWeight.bold),
                      textAlign: pw.TextAlign.center), // Centered text
                  pw.Text('Resolucion Nro. 80 del 22-08-2014',
                      style: pw.TextStyle(fontSize: 8),
                      textAlign: pw.TextAlign.center), // Centered text
                  pw.Text(
                      'Verifique Documento: http://www.facturacion.cl/desiws/boleta',
                      style: pw.TextStyle(fontSize: 8),
                      textAlign: pw.TextAlign.center), // Centered text
                ],
              ),
            ),
            pw.SizedBox(height: 5),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Row(
              children: [
                pw.Text('IVA: \$', style: pw.TextStyle(fontSize: 10)),
                pw.SizedBox(width: 20),
                pw.Text('${formatter.format(iva)}',
                    style: pw.TextStyle(fontSize: 10)),
              ],
            ),
            pw.Row(
              children: [
                pw.Text('TOTAL: \$', style: pw.TextStyle(fontSize: 10)),
                pw.SizedBox(width: 20),
                pw.Text('${formatter.format(total)}',
                    style: pw.TextStyle(fontSize: 10)),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              children: [
                pw.Text('Monto no fact: \$',
                    style: pw.TextStyle(fontSize: 10)),
                pw.SizedBox(width: 20),
                pw.Text('0', style: pw.TextStyle(fontSize: 10)),
              ],
            ),
            pw.Row(
              children: [
                pw.Text('Valor a pagar: \$',
                    style: pw.TextStyle(fontSize: 10)),
                pw.SizedBox(width: 20),
                pw.Text('0', style: pw.TextStyle(fontSize: 10)),
              ],
            ),
            pw.SizedBox(height: 10),
            // Observations box
            pw.Container(
              width: 200, // Adjust width as needed
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 0.5),
              ),
              padding: pw.EdgeInsets.all(8),
              child: pw.Row(
                children: [
                  pw.Text('Observaciones: ',
                      style: pw.TextStyle(fontSize: 9)),
                  pw.Text('null', style: pw.TextStyle(fontSize: 9)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.TableRow _buildTableHeader() {
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColors.black),
      children: [
        'Item',
        'Código',
        'Descripción',
        'U.M',
        'Cantidad',
        'Precio Unit.',
        'Valor Exento',
        'Valor'
      ]
          .map((text) => pw.Container(
                padding: pw.EdgeInsets.all(4),
                child: pw.Text(text,
                    style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white)),
              ))
          .toList(),
    );
  }

  static pw.TableRow _buildTableRow(BoletaItem item, NumberFormat formatter, int index) {
    return pw.TableRow(
      children: [
        pw.Container(
          padding: pw.EdgeInsets.all(4),
          child: pw.Text(
              (index + 1).toString(),
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
          child: pw.Text('UN',
              style: pw.TextStyle(fontSize: 9)),
        ),
        pw.Container(
          padding: pw.EdgeInsets.all(4),
          child: pw.Text(item.cantidad.toString(),
              style: pw.TextStyle(fontSize: 9)),
        ),
        pw.Container(
          padding: pw.EdgeInsets.all(4),
          child: pw.Text(
              '\$ ${formatter.format(item.precioUnitario)}',
              style: pw.TextStyle(fontSize: 9)),
        ),
        pw.Container(
          padding: pw.EdgeInsets.all(4),
          child: pw.Text('0', // Valor Exento
              style: pw.TextStyle(fontSize: 9)),
        ),
        pw.Container(
          padding: pw.EdgeInsets.all(4),
          child: pw.Text(
              '\$ ${formatter.format(item.valorTotal)}',
              style: pw.TextStyle(fontSize: 9)),
        ),
      ],
    );
  }
}