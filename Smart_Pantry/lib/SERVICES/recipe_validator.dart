// lib/SERVICES/recipe_validator.dart
//
// Checks an AI-written recipe against the household's mystery box BEFORE it is
// shown. A recipe that invents ingredients, uses too many "extras", has too few
// steps or contains nonsense such as washing bread is rejected.
// Pure Dart so it can be unit-tested.
import 'package:smart_pantry/DATA/food_lexicon.dart';
import 'package:smart_pantry/DATA/ingredients.dart';
import 'package:smart_pantry/SERVICES/recipe_engine.dart';

class RecipeValidation {
  final RecipeCard? card;
  final String? problem;
  const RecipeValidation.ok(RecipeCard this.card) : problem = null;
  const RecipeValidation.rejected(String this.problem) : card = null;
  bool get isOk => card != null;
}

class RecipeValidator {
  RecipeValidator._();

  static const Set<String> staples = {
    'water', 'salt', 'oil', 'cooking oil', 'pepper', 'black pepper', 'sugar',
  };
  static const int maxExtras = 2;

  static final RegExp _nonsense = RegExp(
      r'\b(wash|rinse|boil|soak)\s+(the\s+|your\s+)?(sliced\s+)?bread\b',
      caseSensitive: false);

  static Ingredient? _findInBox(String name, List<Ingredient> box) {
    final n = FoodLexicon.normalize(name);
    if (n.isEmpty) return null;
    final nTags = FoodLexicon.tagsFor(name);
    for (final item in box) {
      final m = FoodLexicon.normalize(item.name);
      if (m.contains(n) || n.contains(m)) return item;
      final common = FoodLexicon.tagsFor(item.name).intersection(nTags);
      common.remove('fruit');
      common.remove('greens');
      if (common.isNotEmpty) return item;
    }
    return null;
  }

  static bool _isStaple(String name) {
    final n = FoodLexicon.normalize(name);
    return staples.any((s) => n == s || n.endsWith(' $s') || n.startsWith('$s '));
  }

  static RecipeValidation check(Map<String, dynamic> json, List<Ingredient> box) {
    final title = (json['title'] as String?)?.trim() ?? '';
    if (title.length < 3 || title.length > 80) {
      return const RecipeValidation.rejected('it has no proper title');
    }

    final steps = <String>[
      for (final s in (json['steps'] as List? ?? const []))
        if (s is String && s.trim().isNotEmpty) s.trim(),
    ];
    if (steps.length < 3 || steps.length > 9) {
      return const RecipeValidation.rejected('it does not have 3 to 9 clear steps');
    }
    if (steps.any((s) => s.length < 12)) {
      return const RecipeValidation.rejected('some steps are too short to follow');
    }
    if (steps.any(_nonsense.hasMatch)) {
      return const RecipeValidation.rejected('it contains an impossible instruction');
    }

    final raw = json['ingredients'] as List? ?? const [];
    final lines = <RecipeLine>[];
    final used = <Ingredient>[];
    var extras = 0;

    for (final entry in raw) {
      if (entry is! Map) continue;
      final name = (entry['name'] as String?)?.trim() ?? '';
      final amount = (entry['amount'] as String?)?.trim() ?? '';
      if (name.isEmpty) continue;
      final amountText = amount.isEmpty ? '' : ' - $amount';

      final match = _findInBox(name, box);
      if (match != null) {
        if (!used.contains(match)) used.add(match);
        lines.add(RecipeLine('$name$amountText (your ${match.name})', LineKind.pantry));
      } else if (_isStaple(name)) {
        lines.add(RecipeLine('$name$amountText', LineKind.staple));
      } else {
        final source = (entry['source'] as String?)?.toLowerCase();
        if (source == 'pantry') {
          return RecipeValidation.rejected('it uses "$name", which is not in your box');
        }
        extras++;
        lines.add(RecipeLine('$name$amountText (extra: buy if you do not have it)', LineKind.extra));
      }
    }

    if (used.isEmpty) {
      return const RecipeValidation.rejected('it does not use any item from your box');
    }
    if (lines.length < 2) {
      return const RecipeValidation.rejected('its ingredient list is too short');
    }
    if (extras > maxExtras) {
      return RecipeValidation.rejected('it needs $extras extra ingredients');
    }

    return RecipeValidation.ok(RecipeCard(
      title: title,
      source: RecipeSource.ai,
      minutes: (json['minutes'] as num?)?.toInt() ?? 30,
      servings: (json['servings'] as num?)?.toInt() ?? 3,
      lines: lines,
      steps: steps,
      tip: (json['tip'] as String?)?.trim() ?? '',
      usedItems: used,
    ));
  }
}
