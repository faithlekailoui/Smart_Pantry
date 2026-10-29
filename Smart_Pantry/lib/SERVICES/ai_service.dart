// lib/SERVICES/ai_service.dart
//
// Recipe generation, grounded in the pantry ("local RAG"): the prompt is built
// ONLY from rows read from the local database, and the model is told to use
// nothing else. If the network/API is unavailable the app falls back to a
// rule-based recipe, and the UI says which one the user is looking at.
//
// Configure at build time - the key is NOT stored in source code:
//   flutter run --dart-define=GEMINI_API_KEY=your_key
//   flutter build apk --release --dart-define=GEMINI_API_KEY=your_key
// Optional: --dart-define=GEMINI_MODEL=<model name>   (default: gemini-flash-latest)
//
// NOTE: a key compiled into an app can be extracted from the APK. That is fine
// for a prototype/demo; a production app should call Gemini through a backend.
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:smart_pantry/DATA/ingredients.dart';

class RecipeResult {
  final String text;
  final bool fromAI;
  final String? note;
  const RecipeResult(this.text, {required this.fromAI, this.note});
}

class AIService {
  AIService._();

  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String _model =
      String.fromEnvironment('GEMINI_MODEL', defaultValue: 'gemini-flash-latest');
  static const Duration _timeout = Duration(seconds: 25);
  static const Duration _minInterval = Duration(seconds: 4); // throttling
  static const int _maxItemsInPrompt = 25;

  // Client-side cache: same pantry -> same answer, no extra API call.
  static final Map<String, String> _cache = {};
  static DateTime? _lastCall;

  static Future<RecipeResult> generateRecipe(
    List<Ingredient> all, {
    bool forceRefresh = false,
  }) async {
    if (all.isEmpty) {
      return const RecipeResult(
        'Your pantry is empty. Add some ingredients first and I will build a zero-waste recipe from them.',
        fromAI: false,
      );
    }

    // Food safety: never build recipes from expired items.
    final usable = all.where((i) => !i.isExpired).toList()
      ..sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
    if (usable.isEmpty) {
      return const RecipeResult(
        'Everything in your pantry has passed its expiry date, so I will not build a recipe from it. '
        'Please check and discard it safely, then add fresh items.',
        fromAI: false,
      );
    }

    final signature =
        usable.map((i) => '${i.name}|${i.expiryDate}|${i.quantity}').join(';');
    final cached = _cache[signature];
    if (!forceRefresh && cached != null) {
      return RecipeResult(cached,
          fromAI: true, note: 'Saved result for the same pantry (no new API call).');
    }

    if (_apiKey.isEmpty) {
      return _fallback(usable,
          'No Gemini API key was provided to this build, so this is an offline recipe.');
    }

    final now = DateTime.now();
    if (_lastCall != null && now.difference(_lastCall!) < _minInterval) {
      return _fallback(usable,
          'Please wait a few seconds between AI requests. Showing an offline recipe meanwhile.');
    }
    _lastCall = now;

    try {
      final response = await http
          .post(
            Uri.parse(
                'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent'),
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': _apiKey,
            },
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': _buildPrompt(usable)}
                  ]
                }
              ],
              'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 900},
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List?;
        final parts = (candidates != null && candidates.isNotEmpty)
            ? (candidates.first['content']?['parts'] as List?)
            : null;
        final text = parts?.map((p) => (p as Map)['text'] ?? '').join().trim();
        if (text != null && text.isNotEmpty) {
          _cache[signature] = text;
          return RecipeResult(text, fromAI: true);
        }
        return _fallback(usable, 'The AI returned an empty answer. Showing an offline recipe.');
      }

      debugPrint('Gemini HTTP ${response.statusCode}: ${response.body}');
      final reason = switch (response.statusCode) {
        400 || 403 => 'The API key was rejected.',
        404 => 'The model "$_model" was not found - check GEMINI_MODEL.',
        429 => 'The free API quota was reached.',
        _ => 'The AI service returned error ${response.statusCode}.',
      };
      return _fallback(usable, '$reason Showing an offline recipe.');
    } on TimeoutException {
      return _fallback(usable, 'The AI took too long to answer. Showing an offline recipe.');
    } catch (e) {
      debugPrint('Gemini call failed: $e');
      return _fallback(usable, 'You appear to be offline. Showing an offline recipe.');
    }
  }

  static String _buildPrompt(List<Ingredient> usable) {
    final lines = usable
        .take(_maxItemsInPrompt)
        .map((i) => '- ${i.name}, ${i.quantityLabel}, ${Ingredient.labelForDays(i.daysLeft).toLowerCase()}')
        .join('\n');
    return '''
You are Sous-Chef AI, a zero-waste home-cooking assistant for a Kenyan household.
Use ONLY the ingredients in the pantry list below, plus basic staples: water, salt, pepper and cooking oil.
Do not invent or assume any other ingredient. Prioritise the items that expire soonest.

PANTRY (item, quantity, expiry):
$lines

Write ONE simple recipe in plain text. Do not use markdown symbols such as * or #.
Format exactly like this:
Title (first line)
Uses soon-to-expire: (the urgent items this recipe rescues)
Ingredients: (with amounts, only from the pantry list and staples)
Steps: (numbered, at most 6 short steps)
Waste tip: (one sentence on storing or reusing leftovers)
''';
  }

  static RecipeResult _fallback(List<Ingredient> usable, String note) {
    final urgent = usable.first;
    final others = usable.skip(1).take(3).map((i) => i.name).toList();
    final otherText = others.isEmpty ? 'a pinch of salt' : others.join(', ');
    final text = '''
${urgent.name} Rescue Pan

Uses soon-to-expire: ${urgent.name} (${urgent.quantityLabel}) - ${Ingredient.labelForDays(urgent.daysLeft).toLowerCase()}.

Ingredients:
- ${urgent.quantityLabel} ${urgent.name}
- $otherText
- 1 tbsp cooking oil, salt and pepper

Steps:
1. Wash and chop the ${urgent.name} first, before the other items.
2. Heat the oil in a pan on medium heat.
3. Cook the ${urgent.name} for 3-5 minutes until it softens.
4. Add ${others.isEmpty ? 'a splash of water' : others.join(', ')} and cook until tender.
5. Season with salt and pepper, then serve hot.

Waste tip: cook extra and refrigerate the leftovers for tomorrow's lunch.
''';
    return RecipeResult(text, fromAI: false, note: note);
  }
}
