import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_pantry/DATA/ingredients.dart';
import 'package:smart_pantry/CONTROLLERS/pantry_controller.dart';
import 'package:smart_pantry/VIEWS/app_drawer.dart';
import 'package:smart_pantry/VIEWS/add_ingredient_view.dart';

class PantryHomeView extends ConsumerWidget {
  const PantryHomeView({super.key});

  void _showEditDialog(BuildContext context, WidgetRef ref, Ingredient item, int index) {
    final nameController = TextEditingController(text: item.name);
    final qtyController = TextEditingController(text: item.quantity.toString());
    final unitController = TextEditingController(text: item.unit);
    final expiryController = TextEditingController(text: item.expiryDate);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Ingredient'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: qtyController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity')),
            TextField(controller: unitController, decoration: const InputDecoration(labelText: 'Unit')),
            TextField(controller: expiryController, decoration: const InputDecoration(labelText: 'Expiry Date')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () {
              final updated = Ingredient(
                id: item.id,
                name: nameController.text.trim(),
                quantity: double.tryParse(qtyController.text.trim()) ?? item.quantity,
                unit: unitController.text.trim(),
                expiryDate: expiryController.text.trim(),
              );
              ref.read(pantryProvider.notifier).updateIngredient(index, updated);
              Navigator.pop(ctx);
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ingredients = ref.watch(pantryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Pantry Inventory'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: ingredients.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.inventory_2_outlined, size: 70, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No items in your pantry yet.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  Text('Tap + to reduce waste and track your groceries!', style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                final item = ingredients[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.fastfood, color: Colors.white, size: 20),
                    ),
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Qty: ${item.quantity} ${item.unit} | Expires: ${item.expiryDate}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Quick Action: Consume / Reduce Quantity
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.orange),
                          tooltip: 'Use 1 item',
                          onPressed: () {
                            ref.read(pantryProvider.notifier).consumeIngredient(index, 1.0);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                          onPressed: () => _showEditDialog(context, ref, item, index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            ref.read(pantryProvider.notifier).removeIngredientAt(index);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddIngredientView()),
          );
        },
      ),
    );
  }
}
