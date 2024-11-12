import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/digitar_rut_widget.dart';
import '../../models/boleta_item.dart';
import '../../controllers/database_helper.dart';
import '../../views/boleta_express/boleta_express_screen.dart';
import '../../views/main_screen.dart';
import './vista_previa_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../views/boleta_express/boleta_success_screen.dart';
import '../../services/pdf_service.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DetalleBoletaScreen extends StatefulWidget {
  final String codigo;
  final int cantidad;
  final double precioUnitario;
  final double valorTotal;

  DetalleBoletaScreen({
    required this.codigo,
    required this.cantidad,
    required this.precioUnitario,
    required this.valorTotal,
  });

  @override
  _DetalleBoletaScreenState createState() => _DetalleBoletaScreenState();
}

class _DetalleBoletaScreenState extends State<DetalleBoletaScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Define a single formatter to use everywhere
  final formatter = NumberFormat('#,###', 'es_CL');

  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<BoletaItem> boletaItems = [];

  final TextEditingController _rutController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool emailEnabled = false;

  bool _rutEntered = false;

  @override
  void initState() {
    super.initState();
    _loadBoletaItems();
  }

  Future<void> _loadBoletaItems() async {
    final items = await _dbHelper.getBoletaItems();
    print('Loaded items: ${items.length}');
    if (mounted) {
      setState(() {
        boletaItems = items;
      });
    }
  }

  Future<void> _addBoletaItemToDatabase(BoletaItem item) async {
    await _dbHelper.insertBoletaItem(item);
    await _loadBoletaItems(); // Reload the list
  }

  Future<void> _updateItem(int id, BoletaItem item) async {
    await _dbHelper.updateBoletaItem(item);
    await _loadBoletaItems(); // Reload the list
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _addNewItem() async {
    final BoletaItem newItem = BoletaItem(
      codigo: widget.codigo,
      descripcion: '', // Add description to your widget parameters
      cantidad: widget.cantidad,
      precioUnitario: widget.precioUnitario,
      valorTotal: widget.valorTotal,
    );

    await _dbHelper.insertBoletaItem(newItem);
    await _loadBoletaItems();
  }

  void _editItem(int index) {
    final item = boletaItems[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BoletaExpressScreen(
          id: item.id.toString(),
          codigo: item.codigo,
          descripcion: item.descripcion,
          cantidad: item.cantidad,
          precioUnitario: item.precioUnitario,
          activateListener: true,
          onItemSaved: (BoletaItem updatedItem) async {
            try {
              await _dbHelper.updateBoletaItem(updatedItem);
              await _loadBoletaItems();
              Navigator.pop(context);
            } catch (e) {
              print('Error updating item: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al actualizar el item')),
              );
            }
          },
        ),
      ),
    );
  }

  // Add this method to handle item deletion
  Future<void> _deleteItem(int index) async {
    final item = boletaItems[index];
    await _dbHelper.deleteBoletaItem(item.id!);
    await _loadBoletaItems(); // Reload the list after deletion
  }

  double _calculateTotal() {
    return boletaItems.fold(0.0, (sum, item) => sum + item.valorTotal);
  }

  // Add this method to delete all items
  Future<void> _deleteAllItems() async {
    for (var item in boletaItems) {
      await _dbHelper.deleteBoletaItem(item.id!);
    }
    boletaItems.clear();
  }

  void _showLoadingDialog(BuildContext context, {String message = "Vista Previa..."}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text(message),
            ],
          ),
        );
      },
    );
  }

  // Add this method to generate the PDF
  Future<List<int>> _generatePdf(List<BoletaItem> items) async {
    // Implement your PDF generation logic here
    // Return the generated PDF as a list of bytes
    return []; // Placeholder return
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Show confirmation dialog
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('¿Desea volver al menú principal?'),
            content: const Text('Si regresa perderá los datos ingresados.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () async {
                  await _deleteAllItems(); // Delete all items
                  Navigator.pop(context, true); // Close dialog
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MainScreen()),
                    (route) => false,
                  );
                },
                child: const Text('Si'),
              ),
            ],
          ),
        );
        return result ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Boleta Express'),
          centerTitle: true,
          backgroundColor: Color(0xFF1A90D9),
          actions: _currentPage == 0
              ? [
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BoletaExpressScreen(
                            activateListener: true,
                            onItemSaved: (BoletaItem item) async {
                              try {
                                await _dbHelper.insertBoletaItem(item);
                                await _loadBoletaItems();
                              } catch (e) {
                                print('Error saving item: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error al guardar el item')),
                                );
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ]
              : [], // Empty list when on second page
        ),
        body: Stack(
          children: [
            // Main content
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          _currentPage == 0 ? 'Detalle' : 'Totales',
                          style: TextStyle(fontSize: 20, color: Colors.blue),
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_circle_left_outlined,
                                color: _currentPage == 1
                                    ? Color(0xFF1A90D9)
                                    : Colors.grey[300],
                                size: 24),
                            onPressed: _currentPage > 0
                                ? () => _pageController.previousPage(
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    )
                                : null,
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.circle,
                            color: Color(0xFF1A90D9),
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.circle,
                            color: _currentPage == 1
                                ? Color(0xFF1A90D9)
                                : Color(0xFF1A90D9).withOpacity(0.2),
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.arrow_circle_right_outlined,
                                color: _currentPage == 0
                                    ? Color(0xFF1A90D9)
                                    : Colors.grey[300],
                                size: 24),
                            onPressed: _currentPage < 1
                                ? () => _pageController.nextPage(
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    )
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    children: [
                      _buildDetallePage(),
                      _buildTotalesPage(),
                    ],
                  ),
                ),
              ],
            ),
            // Bottom bar that only shows on first page
            if (_currentPage == 0) // Only show when on first page
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        width: double.infinity,
                        color: Color.fromARGB(255, 3, 63, 141),
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Monto Total',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        width: double.infinity,
                        color: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          '\$${formatter.format(_calculateTotal())}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetallePage() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView.builder(
              itemCount: boletaItems.length,
              itemBuilder: (context, index) {
                final item = boletaItems[index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 1),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromARGB(255, 73, 73, 73)),
                    color: index % 2 == 0
                        ? Colors.white
                        : Color(0xFFE3F2FD), // Light blue tint for odd items
                  ),
                  child: InkWell(
                    onTap: () => _editItem(index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.descripcion,
                                  style: TextStyle(fontSize: 13),
                                ),
                                SizedBox(height: 2),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 136, // Fixed width for labels
                                      child: Text(
                                        'Cantidad: ',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                    ),
                                    Text(
                                      '${item.cantidad} UN',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 130, // Same fixed width for labels
                                      child: Text(
                                        'Precio unitario: ',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                    ),
                                    Text(
                                      '\$${formatter.format(item.precioUnitario)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 40),
                              Row(
                                children: [
                                  Text(
                                    'Valor Total: ',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                  SizedBox(width: 20),
                                  Text(
                                    '\$${formatter.format(item.valorTotal)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(width: 25),
                          // Menu button
                          PopupMenuButton(
                            icon: Icon(Icons.more_vert, size: 18),
                            padding: EdgeInsets.zero,
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Borrar'),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'delete') {
                                _deleteItem(index);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalesPage() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setPageState) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 8),
                color: Color.fromARGB(255, 25, 121, 180),
                child: Text(
                  'Valor Total',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 8),
                color: Colors.grey[200],
                child: Text(
                  '\$${formatter.format(_calculateTotal())}',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Enviar por correo'),
                  GestureDetector(
                    onTap: () async {
                      setPageState(() {
                        emailEnabled = !emailEnabled;
                        if (!emailEnabled) {
                          // Clear both fields when switch is turned off
                          _rutController.clear();
                          _emailController.clear();
                          _rutEntered = false;
                        }
                      });

                      if (emailEnabled) {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DigitarRutScreen(),
                          ),
                        );

                        setPageState(() {
                          if (result != null) {
                            _rutController.text = result;
                            _rutEntered = true;
                          } else {
                            emailEnabled = false;
                            _rutEntered = false;
                          }
                        });
                      }
                    },
                    child: Container(
                      width: 35,
                      height: 18,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: emailEnabled
                            ? Color.fromARGB(255, 241, 204, 162)
                            : const Color.fromARGB(255, 177, 177, 177),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AnimatedPositioned(
                            duration: Duration(milliseconds: 200),
                            left: emailEnabled ? 25 : -4,
                            top: -1,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: emailEnabled ? Color(0xFFFFB74D) : Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              TextField(
                controller: _rutController,
                enabled: emailEnabled,
                readOnly: true,
                onTap: emailEnabled ? () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DigitarRutScreen(),
                    ),
                  );

                  setPageState(() {
                    if (result != null) {
                      _rutController.text = result;
                      _rutEntered = true;
                    }
                  });
                } : null,
                decoration: InputDecoration(
                  hintText: 'RUT',
                  hintStyle: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: emailEnabled 
                      ? Color(0xFFE3F2FD)
                      : Colors.grey[300],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _emailController,
                enabled: emailEnabled && _rutEntered,
                decoration: InputDecoration(
                  hintText: 'Correo Electrónico',
                  hintStyle: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: emailEnabled && _rutEntered
                      ? Color(0xFFE3F2FD)
                      : Colors.grey[300],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              SizedBox(height: 24),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    _showLoadingDialog(context);
                    try {
                      Navigator.pop(context); // Close loading dialog first
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PreviewScreen(
                            boletaItems: boletaItems,
                            showAppBar: true,
                          ),
                        ),
                      );
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Error al generar la vista previa')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1A90D9),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 20),
                      SizedBox(width: 8),
                      Text('Vista Previa'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (emailEnabled && _emailController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Por favor ingrese un correo electrónico')),
                      );
                      return;
                    }

                    try {
                      _showLoadingDialog(context, message: 'Emitiendo...');

                      // Generate PDF first
                      final pdf = await PDFService.generatePdf(boletaItems);
                      final output = await getTemporaryDirectory();
                      final file = File('${output.path}/boleta.pdf');
                      await file.writeAsBytes(pdf);

                      // Send email if enabled
                      if (emailEnabled && _emailController.text.isNotEmpty) {
                        try {
                          // Validate email format
                          final emailPattern = r'^[^@]+@[^@]+\.[^@]+';
                          final isValidEmail = RegExp(emailPattern)
                              .hasMatch(_emailController.text);
                          if (!isValidEmail) {
                            throw Exception('Correo electrónico no válido');
                          }

                          // Check if file exists
                          if (!await file.exists()) {
                            throw Exception('El archivo PDF no existe');
                          }

                          final smtpServer = gmail(
                            dotenv.env['EMAIL_ADDRESS']!,
                            dotenv.env['EMAIL_PASSWORD']!
                          );

                          final message = Message()
                            ..from = Address(
                              dotenv.env['EMAIL_ADDRESS']!,
                              'SERVICIOS Y TECNOLOGIA LIMITADA'
                            )
                            ..recipients.add(_emailController.text)
                            ..subject = 'Boleta Electrónica'
                            ..html = '''
<div style="font-family: Arial, sans-serif;">
Le informamos que ha recibido un nuevo documento electrónico. A continuación, el detalle:<br><br>

<div style="font-family: monospace;">
<b>De     </b> : SERVICIOS Y TECNOLOGIA LIMITADA<br>
<b>Tipo   </b> : BOLETA ELECTRONICA<br>
<b>Folio  </b> : 328111<br>
<b>Monto  </b> : \$${formatter.format(_calculateTotal())}<br>
<b>Fecha  </b> : ${DateFormat('dd-MM-yyyy').format(DateTime.now())}<br>
</div><br>

En el siguiente botón podrá ver y descargar su documento electrónico:<br><br>

<b>Desis ws, saludos PRUEBA PRUEBA</b><br><br>

<b>probandpp</b><br><br>

Correo generado ${DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now())}<br><br>

<span style="font-size: 11px;">NOTA: El archivo adjunto con extensión XML es únicamente para fines de Facturación Electrónica.</span>
</div>'''
                            ..attachments = [FileAttachment(file)];

                          try {
                            final sendReport = await send(message, smtpServer);
                            print('Email sent: ' + sendReport.toString());
                          } on MailerException catch (e) {
                            print('Email not sent. \n' + e.toString());
                            throw Exception(
                                'Error al enviar el correo electrónico');
                          }
                        } catch (emailError) {
                          Navigator.pop(context); // Close loading dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Error al enviar el correo electrónico: $emailError'),
                            ),
                          );
                          return;
                        }
                      }

                      Navigator.pop(context); // Close loading dialog
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BoletaSuccessScreen(
                            folioNumber: '328111',
                            pdfFile: file,
                          ),
                        ),
                      );
                    } catch (e) {
                      Navigator.pop(context); // Close loading dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al emitir la boleta')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text('Emitir'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
