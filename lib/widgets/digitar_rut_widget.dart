import 'package:flutter/material.dart';

class DigitarRutScreen extends StatefulWidget {
  @override
  _DigitarRutScreenState createState() => _DigitarRutScreenState();
}

class _DigitarRutScreenState extends State<DigitarRutScreen> {
  String rutInput = '';
  final TextEditingController _rutController = TextEditingController();

  void _addNumber(String number) {
    setState(() {
      if (rutInput.length < 10) {
        // Remove any existing hyphens first
        String cleanInput = rutInput.replaceAll('-', '');
        cleanInput += number;

        // Format the RUT with a hyphen before the last digit
        if (cleanInput.length > 1) {
          rutInput = cleanInput.substring(0, cleanInput.length - 1) +
              '-' +
              cleanInput.substring(cleanInput.length - 1);
        } else {
          rutInput = cleanInput;
        }

        _rutController.text = rutInput;
        _rutController.selection = TextSelection.fromPosition(
          TextPosition(offset: _rutController.text.length),
        );
      }
    });
  }

  void _deleteNumber() {
    setState(() {
      if (rutInput.isNotEmpty) {
        // Remove the last character and any trailing hyphen
        String cleanInput = rutInput.replaceAll('-', '');
        cleanInput = cleanInput.substring(0, cleanInput.length - 1);

        // Reformat with hyphen if necessary
        if (cleanInput.length > 1) {
          rutInput = cleanInput.substring(0, cleanInput.length - 1) +
              '-' +
              cleanInput.substring(cleanInput.length - 1);
        } else {
          rutInput = cleanInput;
        }

        _rutController.text = rutInput;
        _rutController.selection = TextSelection.fromPosition(
          TextPosition(offset: _rutController.text.length),
        );
      }
    });
  }

  bool _isValidRut(String rut) {
    final regex = RegExp(r'^(\d{7,8})-([\dKk])$');
    if (!regex.hasMatch(rut)) return false;

    final match = regex.firstMatch(rut);
    final numbers = match?.group(1) ?? '';
    final givenVerifier = match?.group(2)?.toUpperCase() ?? '';

    final calculatedVerifier = calculateVerificationDigit(numbers);
    return givenVerifier == calculatedVerifier;
  }

  String calculateVerificationDigit(String rut) {
    int sum = 0;
    int multiplier = 2;

    // Reverse the RUT and iterate over each digit
    for (int i = rut.length - 1; i >= 0; i--) {
      sum += int.parse(rut[i]) * multiplier;
      multiplier = (multiplier == 7) ? 2 : multiplier + 1;
    }

    int remainder = 11 - (sum % 11);

    if (remainder == 11) return '0';
    if (remainder == 10) return 'K';
    return remainder.toString();
  }

  @override
  Widget build(BuildContext context) {
    bool isValidInput = _isValidRut(rutInput);

    return Scaffold(
      appBar: AppBar(
        title: Text('Digitar RUT'),
        centerTitle: true,
        backgroundColor: Color(0xFF1A90D9),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _rutController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'RUT',
                prefixIcon: Icon(
                  Icons.check_circle,
                  color: isValidInput ? Colors.green : Colors.grey[400],
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.backspace_outlined),
                  onPressed: _deleteNumber,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2,
                children: [
                  _buildButton('1'),
                  _buildButton('2'),
                  _buildButton('3'),
                  _buildButton('4'),
                  _buildButton('5'),
                  _buildButton('6'),
                  _buildButton('7'),
                  _buildButton('8'),
                  _buildButton('9'),
                  _buildButton('0'),
                  _buildButton('K'),
                  _buildDeleteButton(),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isValidInput
                    ? () => Navigator.pop(context, rutInput)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0D47A1),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  disabledBackgroundColor: Colors.grey,
                ),
                child: Text('Aceptar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text) {
    return ElevatedButton(
      onPressed: () => _addNumber(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF1A90D9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 20),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return ElevatedButton(
      onPressed: _deleteNumber,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: Text(
        'BORRAR',
        style: TextStyle(fontSize: 14),
      ),
    );
  }
}
