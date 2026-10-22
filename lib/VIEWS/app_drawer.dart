import 'package:flutter/material.dart';
import 'package:smart_pantry/VIEWS/pantry_home_view.dart';
import 'package:smart_pantry/VIEWS/add_ingredient_view.dart';
import 'package:smart_pantry/VIEWS/scan_receipt_view.dart';
import 'package:smart_pantry/VIEWS/recipe_view.dart';
import 'package:smart_pantry/VIEWS/welcome_view.dart';
import 'package:smart_pantry/VIEWS/profile_view.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
         const UserAccountsDrawerHeader(
            decoration:  BoxDecoration(
              gradient: LinearGradient(colors: [Colors.green, Colors.teal]),
            ),
            accountName:  Text('Sous-Chef AI User', style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail:  Text('zero-waste@smartpantry.ai'),
            currentAccountPicture:  CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.green, size: 36),
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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.account_circle, color: Colors.grey),
            title: const Text('My Profile'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileView()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined, color: Colors.grey),
            title: const Text('Welcome / Onboarding'),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const WelcomeView()),
            ),
          ),
        ],
      ),
    );
  }
}
