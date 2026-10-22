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
    final ingredientList = ingredients.map((i) => '${i.quantity} ${i.unit} ${i.name}').join(', ');

    if (ingredientList.isEmpty) {
      setState(() {
        _isLoading = false;
        _generatedRecipe = 'Your pantry is currently empty! Add ingredients first to generate recipes.';
      });
      return;
    }

    final recipeText = await AIService.generateRecipe(ingredientList);
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _isLoading ? null : _fetchRecipe,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate Recipe from Pantry', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: Colors.green))
            else if (_generatedRecipe.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(_generatedRecipe, style: const TextStyle(fontSize: 15, height: 1.5)),
                    ),
                  ),
                ),
              )
            else
              const Expanded(
                child: Center(
                  child: Text(
                    'Tap the button above to generate a zero-waste recipe using your stored items!',
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
