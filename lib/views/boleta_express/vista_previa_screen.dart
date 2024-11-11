import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../models/boleta_item.dart';
import 'dart:io';
import '../../services/pdf_service.dart';
import 'package:share_plus/share_plus.dart';

class PreviewScreen extends StatelessWidget {
  final List<BoletaItem>? boletaItems;
  final File? pdfFile;
  final bool showAppBar;

  const PreviewScreen({
    this.boletaItems,
    this.pdfFile,
    this.showAppBar = false,
  });

  void _sharePDF() async {
    if (pdfFile != null) {
      await Share.shareXFiles([XFile(pdfFile!.path)]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              title: Center(
                child: Text('Documento'),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: _sharePDF,
                ),
              ],
            )
          : null,
      body: PdfPreview(
        build: (format) async {
          if (pdfFile != null) {
            return await pdfFile!.readAsBytes();
          }
          return await PDFService.generatePdf(boletaItems!);
        },
        useActions: false,
      ),
    );
  }
}
