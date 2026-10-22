// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:smart_pantry/VIEWS/app_drawer.dart';
import 'package:smart_pantry/VIEWS/login_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundColor: Colors.green,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Faith Lekailo',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              'faith@smartpantry.ai',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.eco, color: Colors.green),
              title: const Text('Waste Reduction Score'),
              trailing: const Text('92%', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.restaurant, color: Colors.green),
              title: const Text('Recipes Generated'),
              trailing: const Text('14', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginView()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
