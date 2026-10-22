import 'package:flutter/material.dart';
import 'package:smart_pantry/VIEWS/pantry_home_view.dart';
import 'package:smart_pantry/VIEWS/add_ingredient_view.dart';
import 'package:smart_pantry/VIEWS/scan_receipt_view.dart';
import 'package:smart_pantry/VIEWS/recipe_view.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green, Colors.teal],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.eco, size: 48, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  'Sous-Chef AI',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Zero-Waste Kitchen Assistant',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.kitchen, color: Colors.green),
            title: const Text('Pantry Inventory'),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const PantryHomeView()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline, color: Colors.green),
            title: const Text('Add Ingredient'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddIngredientView()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.qr_code_scanner, color: Colors.green),
            title: const Text('OCR Receipt Scanner'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScanReceiptView()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome, color: Colors.amber),
            title: const Text('Sous-Chef AI Recipes'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RecipeView()),
            ),
          ),
        ],
      ),
    );
  }
}
