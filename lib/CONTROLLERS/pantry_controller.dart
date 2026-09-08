import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database_helper.dart';
import '../data/ingredients.dart';

// 1. THE CONTROLLER (THE LOGIC BRAIN)
class PantryNotifier extends StateNotifier<List<Ingredient>> {
  PantryNotifier() : super([]) {
    loadInventory(); // Load data automatically as soon as the app turns on
  }

  // Action A: Fetch all ingredients from the SQLite database
  Future<void> loadInventory() async {
    final rawData = await DatabaseHelper.instance.fetchAllIngredients();
    state = rawData.map((map) => Ingredient.fromMap(map)).toList();
  }

  // Action B: Add a new ingredient and refresh the screen instantly
  Future<void> addIngredient(Ingredient item) async {
    await DatabaseHelper.instance.insertIngredient(item.toMap());
    await loadInventory(); // Triggers the screen to refresh cleanly
  }

  // Action C: Delete an ingredient and update the view
  Future<void> removeIngredient(int id) async {
    await DatabaseHelper.instance.deleteIngredient(id);
    await loadInventory();
  }
}

// 2. THE GLOBAL PROVIDER KEY
// This is what our UI screens will tap into to look at the list of items
final pantryProvider =
    StateNotifierProvider<PantryNotifier, List<Ingredient>>((ref) {
  return PantryNotifier();
});
