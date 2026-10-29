import 'package:flutter/material.dart';
import 'package:smart_pantry/VIEWS/impact_view.dart';
import 'package:smart_pantry/VIEWS/pantry_home_view.dart';
import 'package:smart_pantry/VIEWS/profile_view.dart';
import 'package:smart_pantry/VIEWS/recipe_view.dart';

/// App shell with bottom navigation. IndexedStack keeps every tab alive, so
/// switching tabs is instant and each tab keeps its scroll position/state.
class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          PantryHomeView(),
          RecipeView(),
          ImpactView(),
          ProfileView(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.kitchen_outlined), selectedIcon: Icon(Icons.kitchen), label: 'Pantry'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'Alchemist'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Impact'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
