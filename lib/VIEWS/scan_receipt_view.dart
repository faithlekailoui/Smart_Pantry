import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_pantry/DATA/ingredients.dart';
import 'package:smart_pantry/CONTROLLERS/pantry_controller.dart';
import 'package:smart_pantry/VIEWS/app_drawer.dart';

class ScanReceiptView extends ConsumerStatefulWidget {
  const ScanReceiptView({super.key});

  @override
  ConsumerState<ScanReceiptView> createState() => _ScanReceiptViewState();
}

class _ScanReceiptViewState extends ConsumerState<ScanReceiptView> {
  String _scannedText = '';

  void _simulateScan() {
    // Simulated receipt OCR scan for demo
    final newItem = Ingredient(
      name: 'Scanned Tomatoes',
      quantity: 1.0,
      unit: 'kg',
      expiryDate: DateTime.now().add(const Duration(days: 7)).toString().split(' ')[0],
    );

    ref.read(pantryProvider.notifier).addIngredient(newItem);

    setState(() {
      _scannedText = 'Successfully scanned and added: Scanned Tomatoes (1.0 kg)';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR Receipt & List Scanner'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: _simulateScan,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Capture Receipt / List'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Extracted Text / Auto-Added Items:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                _scannedText.isEmpty
                    ? 'Tap the camera button to snap a photo of your receipt or ingredient list.'
                    : _scannedText,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
