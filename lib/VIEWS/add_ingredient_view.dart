import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_pantry/DATA/ingredients.dart';
import 'package:smart_pantry/CONTROLLERS/pantry_controller.dart';
import 'package:smart_pantry/VIEWS/app_drawer.dart';

class AddIngredientView extends ConsumerStatefulWidget {
  const AddIngredientView({super.key});

  @override
  ConsumerState<AddIngredientView> createState() => _AddIngredientViewState();
}

class _AddIngredientViewState extends ConsumerState<AddIngredientView> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _expiryController = TextEditingController();

  void _saveItem() {
    final name = _nameController.text.trim();
    final quantity = double.tryParse(_quantityController.text.trim()) ?? 1.0;
    final unit = _unitController.text.trim();
    final expiry = _expiryController.text.trim();

    if (name.isNotEmpty) {
      final newItem = Ingredient(
        name: name,
        quantity: quantity,
        unit: unit.isEmpty ? 'pcs' : unit,
        expiryDate: expiry.isEmpty ? '2026-11-01' : expiry,
      );

      ref.read(pantryProvider.notifier).addIngredient(newItem);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Ingredient'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Ingredient Name (e.g., Tomatoes)'),
            ),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity (e.g., 2)'),
            ),
            TextField(
              controller: _unitController,
              decoration: const InputDecoration(labelText: 'Unit (e.g., kg, pcs, liters)'),
            ),
            TextField(
              controller: _expiryController,
              decoration: const InputDecoration(labelText: 'Expiry Date (YYYY-MM-DD)'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: _saveItem,
              child: const Text('Save to Pantry', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}