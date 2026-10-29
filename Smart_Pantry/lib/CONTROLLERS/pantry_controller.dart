// lib/CONTROLLERS/pantry_controller.dart
//
// State layer (Riverpod). The database is the single source of truth: every
// write goes to SQLite first (awaited), then the list is re-read and published.
// At pantry scale (tens to a few hundred rows, indexed) a re-read takes a few
// milliseconds, and it guarantees the screen can never disagree with the data
// on disk - the old "optimistic list + swallowed errors" approach could.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_pantry/DATA/database_helper.dart';
import 'package:smart_pantry/DATA/ingredients.dart';

class PantryNotifier extends AsyncNotifier<List<Ingredient>> {
  DatabaseHelper get _db => DatabaseHelper.instance;

  @override
  Future<List<Ingredient>> build() => _db.getIngredients();

  Future<void> _reload() async {
    state = AsyncData(await _db.getIngredients());
  }

  Future<void> add(Ingredient item) async {
    await _db.addOrMerge(item);
    await _reload();
  }

  Future<void> addAll(List<Ingredient> items) async {
    for (final item in items) {
      await _db.addOrMerge(item);
    }
    await _reload();
  }

  Future<void> updateIngredient(Ingredient item) async {
    await _db.updateIngredient(item);
    await _reload();
  }

  Future<void> use(Ingredient item, double amount) async {
    await _db.useQuantity(item, amount);
    await _reload();
  }

  Future<void> remove(Ingredient item, RemoveReason reason) async {
    await _db.removeIngredient(item, reason);
    await _reload();
  }
}

final pantryProvider =
    AsyncNotifierProvider<PantryNotifier, List<Ingredient>>(PantryNotifier.new);

// ---- UI filters -----------------------------------------------------------

final searchQueryProvider = StateProvider<String>((ref) => '');
final locationFilterProvider = StateProvider<String?>((ref) => null);

/// Pantry items after applying the search box and location chips.
final visibleIngredientsProvider = Provider<List<Ingredient>>((ref) {
  final all = ref.watch(pantryProvider).valueOrNull ?? const <Ingredient>[];
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final location = ref.watch(locationFilterProvider);
  return all
      .where((i) =>
          (location == null || i.location == location) &&
          (query.isEmpty || i.name.toLowerCase().contains(query)))
      .toList();
});

// ---- Statistics & history (recomputed whenever the pantry changes) --------

final statsProvider = FutureProvider.autoDispose<PantryStats>((ref) {
  ref.watch(pantryProvider);
  return DatabaseHelper.instance.getStats();
});

final recentLogsProvider = FutureProvider.autoDispose<List<ActivityLog>>((ref) {
  ref.watch(pantryProvider);
  return DatabaseHelper.instance.getActivityLogs(limit: 8);
});

final allLogsProvider = FutureProvider.autoDispose<List<ActivityLog>>((ref) {
  ref.watch(pantryProvider);
  return DatabaseHelper.instance.getActivityLogs(limit: 300);
});

// ---- Session ---------------------------------------------------------------

final userNameProvider = StateProvider<String>((ref) => '');
