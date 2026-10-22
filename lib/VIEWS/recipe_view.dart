import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_pantry/CONTROLLERS/pantry_controller.dart';
import 'package:smart_pantry/SERVICES/ai_service.dart';
import 'package:smart_pantry/VIEWS/app_drawer.dart';

class RecipeView extends ConsumerStatefulWidget {
  const RecipeView({super.key});

  @override
  ConsumerState<RecipeView> createState() => _RecipeViewState();
}

class _RecipeViewState extends ConsumerState<RecipeView> {
  String _generatedRecipe = '';
  bool _isLoading = false;

  Future<void> _fetchRecipe() async {
    setState(() => _isLoading = true);
    final ingredients = ref.read(pantryProvider);

    if (ingredients.isEmpty) {
      setState(() {
        _isLoading = false;
        _generatedRecipe =
            'Your pantry is currently empty! Add ingredients first to generate zero-waste recipes.';
      });
      return;
    }

    final recipeText = await AIService.generateRecipe(ingredients);
    setState(() {
      _generatedRecipe = recipeText;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sous-Chef AI Recipes'),
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
                backgroundColor: Colors.amber.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _isLoading ? null : _fetchRecipe,
              icon: const Icon(Icons.auto_awesome),
              label: const Text(
                'Generate Zero-Waste Recipe',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: Colors.green))
            else if (_generatedRecipe.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(_generatedRecipe,
                          style: const TextStyle(fontSize: 15, height: 1.5)),
                    ),
                  ),
                ),
              )
            else
              const Expanded(
                child: Center(
                  child: Text(
                    'Tap the button above to generate a customized zero-waste recipe focused on your expiring ingredients!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}