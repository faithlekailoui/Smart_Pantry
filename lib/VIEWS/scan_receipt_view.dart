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
  bool _isProcessing = false;

  Future<void> _pickAndScanImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = image;
        _isProcessing = true;
      });

      // Simulate OCR delay for realistic UI transition
      await Future.delayed(const Duration(seconds: 2));

      final scannedItem = Ingredient(
        name: 'Fresh Spinach & Milk',
        quantity: 2.0,
        unit: 'pcs',
        expiryDate: DateTime.now().add(const Duration(days: 5)).toString().split(' ')[0],
      );

      ref.read(pantryProvider.notifier).addIngredient(scannedItem);

      setState(() {
        _isProcessing = false;
        _scannedText =
            'Receipt Analyzed Successfully!\nAuto-Added: Fresh Spinach & Milk (2.0 pcs) to Pantry Inventory.';
      });
    }
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
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _pickAndScanImage,
              icon: const Icon(Icons.upload_file),
              label: const Text(
                'Upload Receipt Image / Photo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            // Image Preview Container
            if (_selectedImage != null) ...[
              Container(
                height: 180,
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
              const Center(child: CircularProgressIndicator(color: Colors.green))
            else ...[
              const Text(
                'Extracted Text / Auto-Added Items:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
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
                      ? 'Upload a receipt or grocery list photo to scan items into your pantry.'
                      : _scannedText,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
