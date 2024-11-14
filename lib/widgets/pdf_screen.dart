import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class PDFScreen extends StatelessWidget {
  final Uint8List pdfBytes;

  const PDFScreen({Key? key, required this.pdfBytes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vista Previa'),
        backgroundColor: Color(0xFF1A90D9),
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () async {
              await Printing.layoutPdf(
                onLayout: (_) async => pdfBytes,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: PdfPreview(
          build: (format) => pdfBytes,
          canChangePageFormat: false,
          canDebug: false,
          allowPrinting: false,
          allowSharing: false,
          useActions: false,
          loadingWidget: Center(
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
          ),
          pdfPreviewPageDecoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
          ),
          previewPageMargin: EdgeInsets.all(16),
          actions: [],
          maxPageWidth: 800,
        ),
      ),
    );
  }
}
