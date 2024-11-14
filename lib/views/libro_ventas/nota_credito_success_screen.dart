import 'package:flutter/material.dart';
import 'dart:io';
import '../../widgets/pdf_screen.dart';
import '../main_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';

class NotaCreditoSuccessScreen extends StatelessWidget {
  final String folioNumber;
  final List<int> pdfBytes;

  const NotaCreditoSuccessScreen({
    required this.folioNumber,
    required this.pdfBytes,
  });

  void _viewPDF(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFScreen(pdfBytes: Uint8List.fromList(pdfBytes)),
      ),
    );
  }

  void _sharePDF() async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/nota_credito_$folioNumber.pdf');
    await file.writeAsBytes(pdfBytes);
    await Share.shareXFiles([XFile(file.path)]);
  }

  void _navigateToMain(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => MainScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _navigateToMain(context);
        return false;
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Folio N° $folioNumber',
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' ha sido ingresado al\nLibro de Ventas del período Noviembre 2024',
                      style: TextStyle(
                        color: Colors.blue[900],
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 50,
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () => _viewPDF(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1565C0),
                    elevation: 0,
                    padding: EdgeInsets.zero,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Ver PDF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: _sharePDF,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1565C0),
                    elevation: 0,
                    padding: EdgeInsets.zero,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.share, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Compartir',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () => _navigateToMain(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    'Aceptar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 