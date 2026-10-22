import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_pantry/DATA/ingredients.dart';
import 'package:smart_pantry/DATA/database_helper.dart';

final pantryProvider = StateNotifierProvider<PantryNotifier, List<Ingredient>>((ref) {
  return PantryNotifier();
});

class PantryNotifier extends StateNotifier<List<Ingredient>> {
  PantryNotifier() : super([]) {
    loadInventory();
  }

  Future<void> loadInventory() async {
    try {
      final rawData = await DatabaseHelper.instance.fetchAllIngredients();
      if (rawData.isNotEmpty) {
        state = rawData.map((map) => Ingredient.fromMap(map)).toList();
      }
    } catch (e) {
      print('Web fallback loading: $e');
    }
  }

  Future<void> addIngredient(Ingredient newItem) async {
    try {
      await DatabaseHelper.instance.insertIngredient(newItem.toMap());
    } catch (e) {
      print('Web fallback adding: $e');
    }
    state = [...state, newItem];
  }

  Future<void> removeIngredient(int id) async {
    try {
      await DatabaseHelper.instance.deleteIngredient(id);
    } catch (e) {
      print('Web fallback deletion: $e');
    }
    state = state.where((item) => item.id != id).toList();
  }
}