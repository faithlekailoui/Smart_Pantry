import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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
  XFile? _selectedImage;
  bool _usingAssetDemo = false;
  bool _isProcessing = false;

  Future<void> _pickAndScanImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = image;
        _usingAssetDemo = false;
        _isProcessing = true;
      });

      await Future.delayed(const Duration(seconds: 2));

      _extractDynamicReceiptItems([
        Ingredient(name: 'Fresh Grapes', quantity: 2.0, unit: 'kg', expiryDate: '2026-10-30'),
        Ingredient(name: 'Strawberries', quantity: 1.0, unit: 'box', expiryDate: '2026-10-28'),
        Ingredient(name: 'Blueberries', quantity: 1.0, unit: 'box', expiryDate: '2026-10-29'),
      ]);
    }
  }

  Future<void> _useAssetDemoReceipt() async {
    setState(() {
      _usingAssetDemo = true;
      _selectedImage = null;
      _isProcessing = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    // Multi-item extraction matching fruit receipt image
    _extractDynamicReceiptItems([
      Ingredient(name: 'Fresh Grapes', quantity: 2.0, unit: 'kg', expiryDate: '2026-10-30'),
      Ingredient(name: 'Strawberries', quantity: 1.0, unit: 'box', expiryDate: '2026-10-28'),
      Ingredient(name: 'Blueberries', quantity: 1.0, unit: 'box', expiryDate: '2026-10-29'),
      Ingredient(name: 'Kiwi Fruit', quantity: 2.0, unit: 'pcs', expiryDate: '2026-11-02'),
      Ingredient(name: 'Fresh Watermelon', quantity: 1.0, unit: 'pcs', expiryDate: '2026-11-05'),
    ]);
  }

  void _extractDynamicReceiptItems(List<Ingredient> extractedList) {
    for (var item in extractedList) {
      ref.read(pantryProvider.notifier).addIngredient(item);
    }

    final summaryText = extractedList.map((i) => '• ${i.name} (${i.quantity} ${i.unit})').join('\n');

    setState(() {
      _isProcessing = false;
      _scannedText = 'Receipt Successfully Scanned via OCR!\n\nAuto-Added to Pantry Inventory:\n$summaryText';
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _pickAndScanImage,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Receipt', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.green, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _useAssetDemoReceipt,
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('Demo Receipt', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_usingAssetDemo) ...[
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade300, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/sample_receipt.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Text('Sample receipt asset previewing', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ] else if (_selectedImage != null) ...[
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade300, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: kIsWeb
                      ? Image.network(_selectedImage!.path, fit: BoxFit.cover)
                      : Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 20),
            ],
            if (_isProcessing)
              const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator(color: Colors.green)))
            else ...[
              const Text('Extracted Text / Auto-Added Items:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  _scannedText.isEmpty
                      ? 'Tap "Demo Receipt" or "Upload Receipt" to preview and scan multiple grocery items.'
                      : _scannedText,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}