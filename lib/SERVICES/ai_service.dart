import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_pantry/DATA/ingredients.dart';

class AIService {
  static const String _apiKey = 'YOUR_GEMINI_API_KEY';
  static const String _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  static Future<String> generateRecipe(List<Ingredient> ingredients) async {
    if (ingredients.isEmpty) {
      return 'Your pantry is empty! Add ingredients first to generate zero-waste recipes.';
    }

    // 1. Sort ingredients by expiry date so nearing-expiry items come first
    final sortedList = List<Ingredient>.from(ingredients);
    sortedList.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

    final urgentItem = sortedList.first;
    final ingredientSummary = sortedList
        .map((i) => '${i.quantity} ${i.unit} ${i.name} (Expires: ${i.expiryDate})')
        .join(', ');

    // 2. Build Zero-Waste Prompt targeting nearing expiry items
    final prompt = '''
You are Sous-Chef AI, a zero-waste culinary expert. 
The user needs a recipe urgently prioritizing these expiring items:
Primary Urgent Ingredient: ${urgentItem.name} (Expires: ${urgentItem.expiryDate}).
All Available Pantry Inventory: $ingredientSummary.

Generate a customized recipe formatted in Markdown with:
1. Recipe Title highlighting ${urgentItem.name}.
2. Priority Ingredients Used (mentioning which need urgent use).
3. Clear step-by-step cooking instructions explaining how to prep and cook ${urgentItem.name} first to prevent food waste.
''';

    try {
      final response = await http.post(
        Uri.parse('$_endpoint?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [{'text': prompt}]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      }
    } catch (e) {
      print('Gemini API call offline/fallback: $e');
    }

    // 3. Dynamic Fallback Recipe built around the nearest expiring item
    return '''
👨‍🍳 **Sous-Chef Zero-Waste Specialty: ${urgentItem.name.toUpperCase()} Rescue Recipe**

⚠️ **Priority Alert:** Your **${urgentItem.name}** is nearing expiration (${urgentItem.expiryDate})! Use it now to prevent waste.

**Ingredients Used:**
• **URGENT:** ${urgentItem.quantity} ${urgentItem.unit} ${urgentItem.name}
• Other Pantry Items: ${sortedList.skip(1).map((i) => i.name).join(', ')}

**Customized Zero-Waste Cooking Instructions:**
1. **Prep Priority:** Wash and chop the **${urgentItem.name}** first before prepping secondary pantry items.
2. **Sauté Base:** Warm 1 tbsp cooking oil in a skillet over medium heat. Sauté the **${urgentItem.name}** for 3–5 minutes until soft and fragrant.
3. **Combine:** Add remaining pantry ingredients (${sortedList.skip(1).take(2).map((i) => i.name).join(', ')}) into the pan.
4. **Simmer & Season:** Season with salt, pepper, and local herbs. Cook until tender.
5. **Serve Hot:** Enjoy your zero-waste meal! You just saved **${urgentItem.name}** from going to waste.
''';
  }
}
