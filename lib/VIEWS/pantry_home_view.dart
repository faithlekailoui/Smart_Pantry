import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_pantry/CONTROLLERS/pantry_controller.dart';
import 'package:smart_pantry/VIEWS/app_drawer.dart';
import 'package:smart_pantry/VIEWS/add_ingredient_view.dart';

class PantryHomeView extends ConsumerWidget {
  const PantryHomeView({super.key});

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
                  Text(
                    'No items in your pantry yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  Text(
                    'Tap + to reduce waste and track your groceries!',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
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
                    title: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Qty: ${item.quantity} ${item.unit} | Expires: ${item.expiryDate}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        if (item.id != null) {
                          ref.read(pantryProvider.notifier).removeIngredient(item.id!);
                        }
                      },
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