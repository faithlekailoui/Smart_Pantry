import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../DATA/database_helper.dart';

// StateNotifier to manage pantry items live
class PantryNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  PantryNotifier() : super(const AsyncValue.loading()) {
      loadItems();
        }

          Future<void> loadItems() async {
              try {
                    state = const AsyncValue.loading();
                          final items = await DatabaseHelper.instance.fetchAllIngrediants();
                                state = AsyncValue.data(items);
                                    } catch (e, st) {
                                          state = AsyncValue.error(e, st);
                                              }
                                                }

                                                  Future<void> addItem(Map<String, dynamic> item) async {
                                                      await DatabaseHelper.instance.insertIngredient(item);
                                                          loadItems(); // Refresh state instantly
                                                            }

                                                              Future<void> removeItem(int id) async {
                                                                  await DatabaseHelper.instance.deleteIngredient(id);
                                                                      loadItems(); // Refresh state instantly
                                                                        }
                                                                        }

                                                                        // Global provider to be watched inside your Inventory views
                                                                        final pantryProvider = StateNotifierProvider<PantryNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
                                                                          return PantryNotifier();
                                                                          });
                                                                          