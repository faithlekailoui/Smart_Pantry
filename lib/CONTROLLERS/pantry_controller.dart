import 'package:flutter/foundation.dart';
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
      debugPrint('Web fallback loading: $e');
    }
  }

  Future<void> addIngredient(Ingredient newItem) async {
    try {
      await DatabaseHelper.instance.insertIngredient(newItem.toMap());
    } catch (e) {
      debugPrint('Web fallback adding: $e');
    }
    state = [...state, newItem];
  }

  Future<void> updateIngredient(int index, Ingredient updatedItem) async {
    try {
      if (updatedItem.id != null) {
        await DatabaseHelper.instance.updateIngredient(updatedItem.toMap());
      }
    } catch (e) {
      debugPrint('Web fallback updating: $e');
    }
    final newState = List<Ingredient>.from(state);
    newState[index] = updatedItem;
    state = newState;
  }

  // Feature: Consume product quantity when used in cooking
  Future<void> consumeIngredient(int index, double amount) async {
    final item = state[index];
    final double newQty = item.quantity - amount;

    if (newQty <= 0) {
      // Auto-remove item when completely used up
      await removeIngredientAt(index);
    } else {
      final updated = Ingredient(
        id: item.id,
        name: item.name,
        quantity: double.parse(newQty.toStringAsFixed(1)),
        unit: item.unit,
        expiryDate: item.expiryDate,
      );
      await updateIngredient(index, updated);
      await DatabaseHelper.instance.logActivity('CONSUMED', 'Used $amount ${item.unit} of ${item.name}');
    }
  }

  Future<void> removeIngredientAt(int index) async {
    final item = state[index];
    if (item.id != null) {
      try {
        await DatabaseHelper.instance.deleteIngredient(item.id!);
      } catch (e) {
        debugPrint('Web deletion error: $e');
      }
    }
    state = state.whereIndexed((i, element) => i != index).toList();
  }
}

extension ListIndexedExtension<E> on List<E> {
  List<E> whereIndexed(bool Function(int index, E element) test) {
    final List<E> result = [];
    for (var i = 0; i < length; i++) {
      if (test(i, this[i])) result.add(this[i]);
    }
    return result;
  }
}