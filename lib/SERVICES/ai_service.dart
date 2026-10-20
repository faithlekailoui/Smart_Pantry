import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static const String _apiKey = 'YOUR_GEMINI_API_KEY'; // Insert API key here

    static Future<String> generateRecipe(List<String> ingredients) async {
        final model = GenerativeModel(
              model: 'gemini-1.5-flash',
                    apiKey: _apiKey,
                        );

                            final prompt = 'I have the following ingredients in my pantry: ${ingredients.join(", ")}. '
                                    'Suggest 2 simple, practical recipes to reduce food waste. Include step-by-step instructions.';

                                        final response = await model.generateContent([Content.text(prompt)]);
                                            return response.text ?? 'No recipe generated.';
                                              }
                                              }
                                              