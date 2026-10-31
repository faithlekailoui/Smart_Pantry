import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pantry/DATA/ingredients.dart';
import 'package:smart_pantry/SERVICES/recipe_engine.dart';

int _id = 0;
Ingredient _item(String name, {int days = 3}) => Ingredient(
      id: ++_id,
      name: name,
      quantity: 1,
      unit: 'pcs',
      expiryDate: Ingredient.formatDate(Ingredient.today().add(Duration(days: days))),
    );

List<String> _titles(List<Ingredient> box, {int max = 10}) =>
    RecipeEngine.cookable(box, max: max).map((m) => m.recipe.title).toList();

void main() {
  test('eggs, tomato and onion make mayai', () {
    final t = _titles([_item('Eggs'), _item('Tomatoes'), _item('Onion')]);
    expect(t, contains('Mayai with tomato and onion'));
  });

  test('maize flour and sukuma make ugali na sukuma', () {
    final t = _titles([_item('Unga Jogoo 2kg'), _item('Sukuma Wiki')]);
    expect(t, contains('Ugali na sukuma wiki'));
  });

  test('milk and tea make chai; milk and bananas make a milkshake', () {
    expect(_titles([_item('Milk'), _item('Ketepa Tea')]), contains('Kenyan milk tea (chai)'));
    expect(_titles([_item('Milk'), _item('Bananas')]), contains('Banana milkshake'));
  });

  test('rice and beef make pilau', () {
    expect(_titles([_item('Basmati Rice'), _item('Beef'), _item('Onions')]), contains('Pilau'));
  });

  test('three fruits make a fruit salad', () {
    expect(_titles([_item('Fresh Grapes'), _item('Kiwi Fruit'), _item('Strawberries')]),
        contains('Fruit salad'));
  });

  test('bread and spinach never produce a dish that mixes them', () {
    final matches = RecipeEngine.cookable([_item('Bread'), _item('Spinach')], max: 10);
    for (final m in matches) {
      final bread = m.usedItems.any((i) => i.name == 'Bread');
      final spinach = m.usedItems.any((i) => i.name == 'Spinach');
      expect(bread && spinach, isFalse, reason: m.recipe.title);
    }
  });

  test('a single required item missing gives an almost-there hint', () {
    final box = [_item('Tomatoes')];
    final almost = RecipeEngine.almost(box, max: 40);
    final k = almost.where((m) => m.recipe.title == 'Kachumbari');
    expect(k, isNotEmpty);
    expect(k.first.missingRequired.first.label, 'Onion');
  });

  test('meal filter limits the dishes', () {
    final box = [_item('Eggs'), _item('Tomatoes'), _item('Onion')];
    final breakfast = RecipeEngine.cookable(box, meal: 'breakfast', max: 10);
    expect(breakfast.every((m) => m.recipe.meals.contains('breakfast')), isTrue);
  });

  test('items closest to expiry are used first', () {
    final urgent = _item('Eggs', days: 1);
    final box = [_item('Potatoes', days: 20), urgent, _item('Onion', days: 20)];
    final first = RecipeEngine.cookable(box, max: 1).first;
    expect(first.usedItems.contains(urgent), isTrue);
  });
}
