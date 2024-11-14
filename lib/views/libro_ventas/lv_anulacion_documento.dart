import 'package:flutter/material.dart';
import '../../models/boleta_document.dart';
import '../../widgets/pdf_screen.dart';
import '../../services/pdf_service.dart';
import '../../controllers/database_helper.dart';
import '../../views/libro_ventas/nota_credito_success_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'dart:typed_data';

class AnulacionDocumentoScreen extends StatefulWidget {
  final BoletaRecord boleta;

  AnulacionDocumentoScreen({required this.boleta});

  @override
  _AnulacionDocumentoScreenState createState() =>
      _AnulacionDocumentoScreenState();
}

class _AnulacionDocumentoScreenState extends State<AnulacionDocumentoScreen> {
  final TextEditingController _motivoController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String? _errorMessage;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF1A90D9),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF1A90D9),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  bool get isFormValid => _motivoController.text.trim().isNotEmpty;

  // Add this method to show a loading dialog
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Vista Previa..."),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Anulación de documento'),
        centerTitle: true,
        backgroundColor: Color(0xFF1A90D9),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Mediante esta opción emitirá una Nota de Crédito, anulando el documento seleccionado',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(
                      text: "${selectedDate.toLocal()}".split(' ')[0],
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFE3F2FD),
                      labelText: 'Fecha Emisión',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.calendar_today,
                    color: Color(0xFF1A90D9),
                  ),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: _motivoController,
              onChanged: (value) {
                setState(() {
                  _errorMessage = null;
                });
              },
              maxLines: 3,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFE3F2FD),
                labelText: 'Motivo de anulación',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 12),
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      if (isFormValid) {
                        final pdfBytes = await PDFService.generateNotaCredito(widget.boleta);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PDFScreen(pdfBytes: Uint8List.fromList(pdfBytes)),
                          ),
                        );
                      } else {
                        setState(() {
                          _errorMessage = 'Por favor, ingrese un motivo de anulación.';
                        });
                      }
                    },
                    child: Text('Vista Previa', style: TextStyle(color: Colors.white)),
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xFF1A90D9),
                      minimumSize: Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      if (isFormValid) {
                        try {
                          _showLoadingDialog(context);
                          
                          // 1. Update original boleta status to 'Anulado'
                          final updatedBoleta = BoletaRecord(
                            id: widget.boleta.id,
                            folio: widget.boleta.folio,
                            rut: widget.boleta.rut,
                            total: widget.boleta.total,
                            fecha: widget.boleta.fecha,
                            pdfPath: widget.boleta.pdfPath,
                            estado: 'Anulado',
                            usuario: widget.boleta.usuario,
                          );
                          
                          await DatabaseHelper().updateBoletaRecord(updatedBoleta);
                          
                          // 2. Generate credit note PDF and get next folio
                          final nextFolio = await DatabaseHelper().getNextCreditNoteFolio();
                          final pdfBytes = await PDFService.generateNotaCredito(widget.boleta);
                          
                          // 3. Save PDF file
                          final directory = await getApplicationDocumentsDirectory();
                          final file = File('${directory.path}/nota_credito_$nextFolio.pdf');
                          await file.writeAsBytes(pdfBytes);
                          
                          // 4. Create new credit note record
                          final creditNoteRecord = BoletaRecord(
                            folio: nextFolio,
                            rut: widget.boleta.rut,
                            total: widget.boleta.total,
                            fecha: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                            pdfPath: file.path,
                            estado: 'Nota Credito',
                            usuario: widget.boleta.usuario,
                          );
                          
                          await DatabaseHelper().insertBoletaRecord(creditNoteRecord);
                          
                          Navigator.pop(context); // Close loading dialog
                          
                          // 5. Navigate to success screen
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotaCreditoSuccessScreen(
                                folioNumber: nextFolio,
                                pdfBytes: pdfBytes,
                              ),
                            ),
                          );
                        } catch (e) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al emitir la nota de crédito')),
                          );
                        }
                      } else {
                        setState(() {
                          _errorMessage = 'Por favor, ingrese un motivo de anulación.';
                        });
                      }
                    },
                    child: Text('Emitir', style: TextStyle(color: Colors.white)),
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xFF4CAF50),
                      minimumSize: Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
