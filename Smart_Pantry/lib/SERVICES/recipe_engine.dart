// lib/SERVICES/recipe_engine.dart
//
// Matches the "mystery box" (pantry items the user chose) to the Kenyan recipe
// book. Works offline. A recipe is cookable when every required slot is filled
// by an item from the box; items closest to expiry score highest.
import 'package:smart_pantry/DATA/food_lexicon.dart';
import 'package:smart_pantry/DATA/ingredients.dart';
import 'package:smart_pantry/DATA/kenyan_recipes.dart';

enum RecipeSource { book, ai }

enum LineKind { pantry, optional, staple, extra }

class RecipeLine {
  final String text;
  final LineKind kind;
  const RecipeLine(this.text, this.kind);
}

/// What the screen shows, whether the recipe came from the book or from the AI.
class RecipeCard {
  final String title;
  final RecipeSource source;
  final int minutes;
  final int servings;
  final List<RecipeLine> lines;
  final List<String> steps;
  final String tip;
  final List<Ingredient> usedItems;
  final List<String> notes;
  const RecipeCard({
    required this.title,
    required this.source,
    required this.minutes,
    required this.servings,
    required this.lines,
    required this.steps,
    required this.usedItems,
    this.tip = '',
    this.notes = const [],
  });
}

class RecipeMatch {
  final BookRecipe recipe;
  final Map<RecipeSlot, List<Ingredient>> used;
  final List<RecipeSlot> missingRequired;
  final List<RecipeSlot> missingOptional;
  final double score;
  const RecipeMatch(this.recipe, this.used, this.missingRequired,
      this.missingOptional, this.score);

  bool get cookable => missingRequired.isEmpty && usedItems.isNotEmpty;

  List<Ingredient> get usedItems {
    final seen = <String>{};
    final out = <Ingredient>[];
    for (final slot in recipe.slots) {
      for (final i in used[slot] ?? const <Ingredient>[]) {
        if (seen.add('${i.id}-${i.name}')) out.add(i);
      }
    }
    return out;
  }

  RecipeCard toCard() {
    final lines = <RecipeLine>[];
    for (final slot in recipe.slots) {
      final items = used[slot];
      if (items != null && items.isNotEmpty) {
        final names = items.map((i) => i.name).join(', ');
        lines.add(RecipeLine(
            '${slot.label} - ${slot.amount} (your $names)', LineKind.pantry));
      } else if (!slot.required) {
        lines.add(RecipeLine(
            '${slot.label} - ${slot.amount} (optional, not in your box)',
            LineKind.optional));
      }
    }
    for (final s in recipe.staples) {
      lines.add(RecipeLine(s, LineKind.staple));
    }
    return RecipeCard(
      title: recipe.title,
      source: RecipeSource.book,
      minutes: recipe.minutes,
      servings: recipe.servings,
      lines: lines,
      steps: recipe.steps,
      tip: recipe.tip,
      usedItems: usedItems,
    );
  }
}

class RecipeEngine {
  RecipeEngine._();

  static double _weight(Ingredient i) => switch (i.risk) {
        RiskLevel.high => 4.0,
        RiskLevel.moderate => 2.0,
        RiskLevel.low => 1.0,
      };

  static List<Ingredient> _matching(RecipeSlot slot, List<Ingredient> box) {
    final list = box
        .where((i) => FoodLexicon.tagsFor(i.name).any(slot.tags.contains))
        .toList()
      ..sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
    return list;
  }

  /// Evaluates every recipe against the box. Expired items must be removed by
  /// the caller. meal is one of any, breakfast, lunch, dinner, snack.
  static List<RecipeMatch> evaluate(List<Ingredient> box, {String meal = 'any'}) {
    final results = <RecipeMatch>[];
    for (final recipe in kenyanRecipes) {
      if (meal != 'any' && !recipe.meals.contains(meal)) continue;

      final taken = <Ingredient>{};
      final used = <RecipeSlot, List<Ingredient>>{};
      final missingReq = <RecipeSlot>[];
      final missingOpt = <RecipeSlot>[];

      // required slots first so that optional slots cannot steal their items
      final ordered = [
        ...recipe.slots.where((s) => s.required),
        ...recipe.slots.where((s) => !s.required),
      ];
      for (final slot in ordered) {
        final free = _matching(slot, box).where((i) => !taken.contains(i)).toList();
        if (free.length >= slot.min) {
          final n = slot.min > 1 ? (free.length < 3 ? free.length : 3) : 1;
          final picked = free.take(n).toList();
          used[slot] = picked;
          taken.addAll(picked);
        } else if (slot.required) {
          missingReq.add(slot);
        } else {
          missingOpt.add(slot);
        }
      }

      var score = 0.0;
      for (final i in taken) {
        score += _weight(i);
      }
      score += (recipe.slots.where((s) => !s.required).length - missingOpt.length) * 0.6;
      score -= missingOpt.length * 0.25;

      if (taken.isEmpty) continue;
      results.add(RecipeMatch(recipe, used, missingReq, missingOpt, score));
    }
    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }

  static List<RecipeMatch> cookable(List<Ingredient> box,
      {String meal = 'any', int max = 3}) {
    return evaluate(box, meal: meal).where((m) => m.cookable).take(max).toList();
  }

  // Everyday items that are cheap and easy to pick up, so a recipe that only
  // lacks one of them is a better "almost there" suggestion than one that
  // lacks meat or fish.
  static const Set<String> _cheap = {
    'onion', 'tomato', 'egg', 'bread', 'milk', 'tea', 'flour_wheat', 'flour_maize',
    'potato', 'greens', 'cabbage', 'carrot', 'lemon', 'rice', 'banana',
  };

  /// Recipes that are only one required ingredient away from being cookable.
  static List<RecipeMatch> almost(List<Ingredient> box,
      {String meal = 'any', int max = 2}) {
    final list = evaluate(box, meal: meal)
        .where((m) => m.missingRequired.length == 1 && m.usedItems.isNotEmpty)
        .toList();
    bool cheap(RecipeMatch m) =>
        m.missingRequired.first.tags.any(_cheap.contains);
    list.sort((a, b) {
      final c = (cheap(b) ? 1 : 0).compareTo(cheap(a) ? 1 : 0);
      return c != 0 ? c : b.score.compareTo(a.score);
    });
    return list.take(max).toList();
  }
}
