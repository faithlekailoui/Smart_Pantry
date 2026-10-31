import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pantry/DATA/ingredients.dart';
import 'package:smart_pantry/SERVICES/recipe_validator.dart';

int _id = 100;
Ingredient _item(String name) => Ingredient(
      id: ++_id,
      name: name,
      quantity: 1,
      unit: 'pcs',
      expiryDate: Ingredient.formatDate(Ingredient.today().add(const Duration(days: 3))),
    );

Map<String, dynamic> _recipe({
  List<Map<String, String>>? ingredients,
  List<String>? steps,
}) =>
    {
      'title': 'Egg and tomato scramble',
      'minutes': 10,
      'servings': 2,
      'ingredients': ingredients ??
          [
            {'name': 'Eggs', 'amount': '4', 'source': 'pantry'},
            {'name': 'Tomato', 'amount': '2 chopped', 'source': 'pantry'},
            {'name': 'Cooking oil', 'amount': '1 tbsp', 'source': 'staple'},
            {'name': 'Salt', 'amount': 'a pinch', 'source': 'staple'},
          ],
      'steps': steps ??
          [
            'Heat the oil in a pan on medium heat.',
            'Cook the tomato for three minutes until soft.',
            'Beat the eggs with salt and pour them in.',
            'Stir gently for two minutes and serve hot.',
          ],
    };

void main() {
  final box = [_item('Eggs'), _item('Tomatoes'), _item('Onion')];

  test('accepts a recipe made from the box and staples', () {
    final r = RecipeValidator.check(_recipe(), box);
    expect(r.isOk, isTrue, reason: r.problem);
    expect(r.card!.usedItems.length, 2);
  });

  test('rejects an ingredient claimed to be in the pantry but missing', () {
    final r = RecipeValidator.check(
        _recipe(ingredients: [
          {'name': 'Eggs', 'amount': '4', 'source': 'pantry'},
          {'name': 'Chicken', 'amount': '500 g', 'source': 'pantry'},
        ]),
        box);
    expect(r.isOk, isFalse);
  });

  test('rejects more than two extra ingredients', () {
    final r = RecipeValidator.check(
        _recipe(ingredients: [
          {'name': 'Eggs', 'amount': '4', 'source': 'pantry'},
          {'name': 'Garlic', 'amount': '2', 'source': 'extra'},
          {'name': 'Ginger', 'amount': '1', 'source': 'extra'},
          {'name': 'Coriander', 'amount': '1', 'source': 'extra'},
        ]),
        box);
    expect(r.isOk, isFalse);
  });

  test('rejects nonsense such as washing bread', () {
    final r = RecipeValidator.check(
        _recipe(steps: [
          'Wash the bread under running water.',
          'Mix it with the chopped spinach.',
          'Serve immediately on a plate.',
        ]),
        box);
    expect(r.isOk, isFalse);
  });

  test('rejects recipes with too few steps', () {
    final r = RecipeValidator.check(_recipe(steps: ['Cook the eggs well.']), box);
    expect(r.isOk, isFalse);
  });

  test('rejects a recipe that uses nothing from the box', () {
    final r = RecipeValidator.check(
        _recipe(ingredients: [
          {'name': 'Cooking oil', 'amount': '1 tbsp', 'source': 'staple'},
          {'name': 'Salt', 'amount': '1 tsp', 'source': 'staple'},
        ]),
        box);
    expect(r.isOk, isFalse);
  });
}
