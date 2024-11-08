import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/digitar_rut_widget.dart';
import '../../models/boleta_item.dart';
import '../../controllers/database_helper.dart';
import '../../views/boleta_express/boleta_express_screen.dart';
import '../../views/main_screen.dart';
import './vista_previa_screen.dart';

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

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Vista Previa..."),
            ],
          ),
        );
      },
    );
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
          actions: [
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
          ],
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
              '\$${formatter.format(widget.valorTotal)}',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16),
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Enviar por correo'),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          emailEnabled = !emailEnabled;
                        });
                        if (emailEnabled) {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DigitarRutScreen(),
                            ),
                          );
                          if (result != null) {
                            _rutController.text = result;
                          }
                        }
                      },
                      child: Container(
                        width: 35,
                        height: 18,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: emailEnabled
                              ? Colors.blue
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
                                  color: Colors.white,
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
              );
            },
          ),
          SizedBox(height: 8),
          TextField(
            controller: _rutController,
            enabled: emailEnabled,
            decoration: InputDecoration(
              hintText: 'RUT',
              filled: true,
              fillColor: emailEnabled ? Colors.lightBlue[50] : Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _emailController,
            enabled: emailEnabled,
            decoration: InputDecoration(
              hintText: 'Correo Electrónico',
              filled: true,
              fillColor: emailEnabled ? Colors.lightBlue[50] : Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              errorText: emailEnabled && _emailController.text.isEmpty
                  ? 'Campo Obligatorio'
                  : null,
            ),
          ),
          SizedBox(height: 24),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                _showLoadingDialog(context);

                try {
                  // Simulate data fetching
                  await Future.delayed(Duration(seconds: 2));

                  // Generate the document or view with the list of items
                  // For example, you can navigate to a new screen that shows the preview
                  Navigator.pop(context); // Close the loading dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PreviewScreen(boletaItems: boletaItems),
                    ),
                  );
                } catch (e) {
                  Navigator.pop(context); // Close the loading dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al generar la vista previa')),
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
              onPressed: () {
                // Handle Emitir
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
  }
}
