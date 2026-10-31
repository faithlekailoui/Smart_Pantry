// lib/SERVICES/ai_service.dart
//
// The optional "AI chef". The recipe book (recipe_engine.dart) is the main
// source of recipes and works offline. This service asks Gemini for ONE extra
// idea built from the mystery box, forces a structured JSON answer, and then
// runs RecipeValidator on it. An answer that fails the check is never shown.
//
// Configure at build time (the key is NOT stored in source code):
//   flutter run --dart-define=GEMINI_API_KEY=your_key
// Optional: --dart-define=GEMINI_MODEL=<model name>  (default: gemini-flash-latest)
//
// NOTE: a key compiled into an app can be extracted from the APK. That is fine
// for a prototype; a production app should call Gemini through a backend.
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:smart_pantry/DATA/ingredients.dart';
import 'package:smart_pantry/SERVICES/recipe_engine.dart';
import 'package:smart_pantry/SERVICES/recipe_validator.dart';

class AiOutcome {
  final RecipeCard? card;
  final String? message;
  const AiOutcome({this.card, this.message});
}

class AIService {
  AIService._();

  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String _model =
      String.fromEnvironment('GEMINI_MODEL', defaultValue: 'gemini-flash-latest');
  static const Duration _timeout = Duration(seconds: 30);
  static const Duration _minInterval = Duration(seconds: 4);
  static const int _maxItems = 12;

  static bool get isConfigured => _apiKey.isNotEmpty;

  static final Map<String, RecipeCard> _cache = {};
  static DateTime? _lastCall;

  static Future<AiOutcome> suggest(
    List<Ingredient> box, {
    String meal = 'any',
    bool forceRefresh = false,
  }) async {
    final usable = box.where((i) => !i.isExpired).toList()
      ..sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
    if (usable.isEmpty) {
      return const AiOutcome(message: 'Put at least one item that has not expired in the box first.');
    }
    if (!isConfigured) {
      return const AiOutcome(
          message: 'The AI chef needs a Gemini API key in this build. The recipe book above works without it.');
    }

    final signature = '$meal|${usable.map((i) => '${i.name}:${i.expiryDate}').join(';')}';
    final cached = _cache[signature];
    if (!forceRefresh && cached != null) return AiOutcome(card: cached);

    final now = DateTime.now();
    if (_lastCall != null && now.difference(_lastCall!) < _minInterval) {
      return const AiOutcome(message: 'Please wait a few seconds between AI requests.');
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
                    {'text': _prompt(usable.take(_maxItems).toList(), meal)}
                  ]
                }
              ],
              'generationConfig': {
                'temperature': 0.6,
                'maxOutputTokens': 4096,
                'responseMimeType': 'application/json',
                'responseSchema': _schema,
              },
            }),
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        debugPrint('Gemini HTTP ${response.statusCode}: ${response.body}');
        final reason = switch (response.statusCode) {
          400 || 403 => 'The API key or request was rejected.',
          404 => 'The model "$_model" was not found - check GEMINI_MODEL.',
          429 => 'The free API quota was reached.',
          _ => 'The AI service returned error ${response.statusCode}.',
        };
        return AiOutcome(message: reason);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List?;
      final parts = (candidates != null && candidates.isNotEmpty)
          ? (candidates.first['content']?['parts'] as List?)
          : null;
      var text = parts?.map((p) => (p as Map)['text'] ?? '').join().trim() ?? '';
      text = text.replaceAll(RegExp(r'^```(json)?'), '').replaceAll(RegExp(r'```$'), '').trim();
      if (text.isEmpty) {
        return const AiOutcome(message: 'The AI returned an empty answer. Try again.');
      }

      final json = jsonDecode(text) as Map<String, dynamic>;
      final result = RecipeValidator.check(json, usable);
      if (!result.isOk) {
        return AiOutcome(
            message: 'The AI idea was not shown because ${result.problem}. Tap again for another idea.');
      }
      _cache[signature] = result.card!;
      return AiOutcome(card: result.card);
    } on TimeoutException {
      return const AiOutcome(message: 'The AI took too long to answer. Try again.');
    } on FormatException {
      return const AiOutcome(message: 'The AI answer could not be read. Tap again for another idea.');
    } catch (e) {
      debugPrint('Gemini call failed: $e');
      return const AiOutcome(message: 'You appear to be offline. The recipe book still works.');
    }
  }

  static const Map<String, dynamic> _schema = {
    'type': 'OBJECT',
    'properties': {
      'title': {'type': 'STRING'},
      'minutes': {'type': 'INTEGER'},
      'servings': {'type': 'INTEGER'},
      'ingredients': {
        'type': 'ARRAY',
        'items': {
          'type': 'OBJECT',
          'properties': {
            'name': {'type': 'STRING'},
            'amount': {'type': 'STRING'},
            'source': {'type': 'STRING'},
          },
          'required': ['name', 'amount', 'source'],
        },
      },
      'steps': {
        'type': 'ARRAY',
        'items': {'type': 'STRING'},
      },
      'tip': {'type': 'STRING'},
    },
    'required': ['title', 'minutes', 'servings', 'ingredients', 'steps'],
  };

  static String _prompt(List<Ingredient> box, String meal) {
    final lines = box
        .map((i) => '- ${i.name}, ${i.quantityLabel}, ${Ingredient.labelForDays(i.daysLeft).toLowerCase()}')
        .join('\n');
    final mealLine = meal == 'any' ? '' : 'The dish should suit $meal.\n';
    return '''
You are an experienced home cook in Nairobi, Kenya. This is a MasterChef-style "mystery box" challenge for a household.
Cook ONE real dish that Kenyan families actually eat, for example ugali na sukuma wiki, githeri, a stew, pilau, chapati, mandazi, mayai, kachumbari, uji, chai or mukimo.
Use at least one item from the MYSTERY BOX, and prefer the items that expire first. You do not have to use every item; leave out items that do not belong in the same dish.
These pantry staples are always available: water, salt, cooking oil, black pepper and sugar (use source "staple").
You may add at most 2 other common kitchen extras such as onion, tomato, garlic or royco (use source "extra"). Items from the box use source "pantry".
Rules: only combine ingredients that are normally eaten together. Use real cooking methods with heat levels and times. Never wash, boil or soak bread. Use metric amounts. Give 3 to 7 short steps.
$mealLine
MYSTERY BOX (item, quantity, expiry):
$lines

Return only the JSON recipe.
''';
  }
}
