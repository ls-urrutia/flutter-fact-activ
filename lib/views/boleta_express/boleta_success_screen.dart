import 'package:flutter/material.dart';
import 'dart:io';
import 'vista_previa_screen.dart';
import '../main_screen.dart';
import 'package:share_plus/share_plus.dart';
import '../../controllers/database_helper.dart';

class BoletaSuccessScreen extends StatelessWidget {
  final String folioNumber;
  final File pdfFile;

  const BoletaSuccessScreen({
    required this.folioNumber,
    required this.pdfFile,
  });

  void _viewPDF(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreviewScreen(
          pdfFile: pdfFile,
          showAppBar: true,
        ),
      ),
    );
  }

  void _sharePDF() async {
    await Share.shareXFiles([XFile(pdfFile.path)]);
  }

  void _navigateToMain(BuildContext context) async {
    // Clear the database before navigating
    final dbHelper = DatabaseHelper();
    final items = await dbHelper.getBoletaItems();
    for (var item in items) {
      await dbHelper.deleteBoletaItem(item.id!);
    }

    // Navigate to main screen and remove all previous routes
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
              // Success message with folio number
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
                      text:
                          ' ha sido ingresado al\nLibro de Ventas del período Noviembre 2024',
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
              // Check mark icon
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 50,
              ),
              SizedBox(height: 16),
              // Ver PDF button
              Container(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () => _viewPDF(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1565C0), // Darker blue
                    elevation: 0, // Remove shadow
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
              SizedBox(height: 8), // Reduced spacing
              // Compartir button
              Container(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: _sharePDF,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1565C0), // Darker blue
                    elevation: 0, // Remove shadow
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
              SizedBox(height: 8), // Reduced spacing
              // Aceptar button
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
