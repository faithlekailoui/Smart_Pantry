import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../CONTROLLERS/pantry_controller.dart';
import '../SERVICES/ai_service.dart';

class RecipeView extends ConsumerStatefulWidget {
  const RecipeView({super.key});

    @override
      ConsumerState<RecipeView> createState() => _RecipeViewState();
      }

      class _RecipeViewState extends ConsumerState<RecipeView> {
        bool _isLoading = false;
          String _recipeResult = 'Tap the button below to generate a waste-reduction recipe from your pantry items!';

            Future<void> _getRecipe() async {
                final pantryItems = ref.read(pantryProvider);
                    if (pantryItems.isEmpty) {
                          setState(() {
                                  _recipeResult = 'Your pantry is empty! Add some ingredients first.';
                                        });
                                              return;
                                                  }

                                                      setState(() {
                                                            _isLoading = true;
                                                                  _recipeResult = 'Consulting Sous-Chef AI...';
                                                                      });

                                                                          try {
                                                                                final ingredientNames = pantryItems.map((e) => e.name).toList();
                                                                                      final result = await AIService.generateRecipe(ingredientNames);
                                                                                            setState(() {
                                                                                                    _recipeResult = result;
                                                                                                          });
                                                                                                              } catch (e) {
                                                                                                                    setState(() {
                                                                                                                            _recipeResult = 'Error generating recipe. Check your API key or internet connection.';
                                                                                                                                  });
                                                                                                                                      } finally {
                                                                                                                                            setState(() {
                                                                                                                                                    _isLoading = false;
                                                                                                                                                          });
                                                                                                                                                              }
                                                                                                                                                                }

                                                                                                                                                                  @override
                                                                                                                                                                    Widget build(BuildContext context) {
                                                                                                                                                                        return Scaffold(
                                                                                                                                                                              appBar: AppBar(title: const Text('Sous-Chef AI Recipes')),
                                                                                                                                                                                    body: Padding(
                                                                                                                                                                                            padding: const EdgeInsets.all(16.0),
                                                                                                                                                                                                    child: Column(
                                                                                                                                                                                                              children: [
                                                                                                                                                                                                                          ElevatedButton.icon(
                                                                                                                                                                                                                                        onPressed: _isLoading ? null : _getRecipe,
                                                                                                                                                                                                                                                      icon: const Icon(Icons.auto_awesome),
                                                                                                                                                                                                                                                                    label: const Text('Generate Recipe from Pantry'),
                                                                                                                                                                                                                                                                                ),
                                                                                                                                                                                                                                                                                            const SizedBox(height: 20),
                                                                                                                                                                                                                                                                                                        Expanded(
                                                                                                                                                                                                                                                                                                                      child: SingleChildScrollView(
                                                                                                                                                                                                                                                                                                                                      child: Text(
                                                                                                                                                                                                                                                                                                                                                        _recipeResult,
                                                                                                                                                                                                                                                                                                                                                                          style: const TextStyle(fontSize: 16),
                                                                                                                                                                                                                                                                                                                                                                                          ),
                                                                                                                                                                                                                                                                                                                                                                                                        ),
                                                                                                                                                                                                                                                                                                                                                                                                                    ),
                                                                                                                                                                                                                                                                                                                                                                                                                              ],
                                                                                                                                                                                                                                                                                                                                                                                                                                      ),
                                                                                                                                                                                                                                                                                                                                                                                                                                            ),
                                                                                                                                                                                                                                                                                                                                                                                                                                                );
                                                                                                                                                                                                                                                                                                                                                                                                                                                  }
                                                                                                                                                                                                                                                                                                                                                                                                                                                  }
                                                                                                                                                                                                                                                                                                                                                                                                                                                  